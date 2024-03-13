const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const ascii = std.ascii;
const complex = std.math.complex;

const c = @cImport({
    @cInclude("sys/ioctl.h");
});

const c128 = complex.Complex(f128);

const TermSize = struct { height: usize, width: usize };
pub var term_size: TermSize = .{ .height = 0, .width = 0 };
pub var term_ratio: f128 = 1.0;
pub var term_font_ratio: f128 = 1.75; // Could be changed by user input

const TIOCGWINSZ = c.TIOCGWINSZ; // ioctl flag

pub fn getTermSize(tty: std.os.fd_t) !TermSize {
    var winsz = c.winsize{ .ws_col = 0, .ws_row = 0, .ws_xpixel = 0, .ws_ypixel = 0 };
    const rv = std.os.system.ioctl(tty, TIOCGWINSZ, @intFromPtr(&winsz));
    const err = std.os.errno(rv);
    if (rv == 0) {
        return TermSize{ .height = winsz.ws_row, .width = winsz.ws_col };
    } else {
        return std.os.unexpectedErrno(err);
    }
}

const TermTooSmall = error{
    terminal_too_small,
};

pub fn initTermSize() !void {
    term_size = try getTermSize(stdout.context.handle);
    if (term_size.height < 2) return TermTooSmall.terminal_too_small;
    view_window.window_size = TermSize{ .height = term_size.height - 1, .width = term_size.width };
    const height_f: f128 = @floatFromInt(view_window.window_size.height); // Adjust for height of viewport in terminal
    const width_f: f128 = @floatFromInt(view_window.window_size.width);
    term_ratio = term_font_ratio * height_f / width_f;
}

pub const modes = enum { mandelbrot, calibrating };

pub var current_mode: modes = modes.mandelbrot;

pub const Window = struct {
    window_size: TermSize,
    centre: c128,
    size: f128,

    pub fn getTopLeft(self: Window) c128 {
        return .{ .re = self.centre.re - self.size, .im = self.centre.im + self.size * term_ratio };
    }
    pub fn getTopRight(self: Window) c128 {
        return .{ .re = self.centre.re + self.size, .im = self.centre.im + self.size * term_ratio };
    }
    pub fn getBottomLeft(self: Window) c128 {
        return .{ .re = self.centre.re - self.size, .im = self.centre.im - self.size * term_ratio };
    }
    pub fn getBottomRight(self: Window) c128 {
        return .{ .re = self.centre.re + self.size, .im = self.centre.im - self.size * term_ratio };
    }

    pub fn printDiagonalCoords(self: Window) !void {
        const topleft: c128 = self.getTopLeft();
        const centre: c128 = self.centre;
        const bottomright: c128 = self.getBottomRight();
        try stdout.print("Top left     = {} + i{}\n", .{ topleft.re, topleft.im });
        try stdout.print("Centre       = {} + i{}\n", .{ centre.re, centre.im });
        try stdout.print("Bottom right = {} + i{}\n", .{ bottomright.re, bottomright.im });
        try stdout.print("size = {}\n", .{self.size});
    }
};

pub var view_window: Window = Window{ .window_size = TermSize{ .height = 0, .width = 0 }, .centre = c128{ .re = -0.5, .im = 0.0 }, .size = 2.0 };

pub const InputKeysMandelbrot = struct {
    pub const up: u8 = "w"[0];
    pub const left: u8 = "a"[0];
    pub const down: u8 = "s"[0];
    pub const right: u8 = "d"[0];
    pub const in: u8 = "q"[0];
    pub const out: u8 = "e"[0];
    pub const refresh: u8 = "r"[0];
    pub const where: u8 = "f"[0];
    pub const help: u8 = "h"[0];
    pub const calibrate: u8 = "c"[0];
    // Add key to show position
};

pub fn printHelpMandelbrot() !void {
    try stdout.print("CONTROLS:\n", .{});
    try stdout.print("\tMOVE LEFT   = {c}\n", .{InputKeysMandelbrot.left});
    try stdout.print("\tMOVE RIGHT  = {c}\n", .{InputKeysMandelbrot.right});
    try stdout.print("\tMOVE UP     = {c}\n", .{InputKeysMandelbrot.up});
    try stdout.print("\tMOVE DOWN   = {c}\n", .{InputKeysMandelbrot.down});
    try stdout.print("\tZOOM IN     = {c}\n", .{InputKeysMandelbrot.in});
    try stdout.print("\tZOOM OUT    = {c}\n", .{InputKeysMandelbrot.out});
    try stdout.print("\tREFRESH     = {c}\n", .{InputKeysMandelbrot.refresh});
    try stdout.print("\tWHERE AM I? = {c}\n", .{InputKeysMandelbrot.where});
    try stdout.print("\tHELP        = {c}\n", .{InputKeysMandelbrot.help});
    try stdout.print("\tCALIBRATE Y AXIS FONT SCALING = {c}\n", .{InputKeysMandelbrot.calibrate});
}

pub const move_rate: f128 = 0.4;
pub const zoom_rate: f128 = 1.5;

pub fn windowMoveLeft() !void {
    view_window.centre = view_window.centre.sub(c128{ .re = move_rate * view_window.size, .im = 0 });
}
pub fn windowMoveRight() !void {
    view_window.centre = view_window.centre.add(c128{ .re = move_rate * view_window.size, .im = 0 });
}
pub fn windowMoveUp() !void {
    view_window.centre = view_window.centre.add(c128{ .re = 0, .im = move_rate * view_window.size });
}
pub fn windowMoveDown() !void {
    view_window.centre = view_window.centre.sub(c128{ .re = 0, .im = move_rate * view_window.size });
}
pub fn windowZoomIn() !void {
    view_window.size /= zoom_rate;
}
pub fn windowZoomOut() !void {
    view_window.size *= zoom_rate;
}

pub const InputKeysCalibrate = struct {
    pub const increase: u8 = "q"[0];
    pub const decrease: u8 = "e"[0];
    pub const refresh: u8 = "r"[0];
    pub const where: u8 = "f"[0];
    pub const help: u8 = "h"[0];
    pub const mandelbrot: u8 = "m"[0];
};

pub fn printHelpCalibrate() !void {
    try stdout.print("CONTROLS:\n", .{});
    try stdout.print("\tINCREASE FONT Y SCALING = {c}\n", .{InputKeysCalibrate.increase});
    try stdout.print("\tDECREASE FONT Y SCALING = {c}\n", .{InputKeysCalibrate.decrease});
    try stdout.print("\tREFRESH                 = {c}\n", .{InputKeysCalibrate.refresh});
    try stdout.print("\tPRINT CURRENT SCALING   = {c}\n", .{InputKeysCalibrate.where});
    try stdout.print("\tHELP                    = {c}\n", .{InputKeysCalibrate.help});
    try stdout.print("\tBACK TO MANDELBROT      = {c}\n", .{InputKeysCalibrate.mandelbrot});
}
