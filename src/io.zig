const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const ascii = std.ascii;
const complex = std.math.complex;

const c = @cImport({
    @cInclude("sys/ioctl.h");
});

const c128 = complex.Complex(f128);

const TermSz = struct { height: usize, width: usize };
pub var term_sz: TermSz = .{ .height = 0, .width = 0 }; // set via initTermSz
pub var term_ratio: f128 = 1.0;
const TERM_FONT_RATIO: f128 = 2.0;

const TIOCGWINSZ = c.TIOCGWINSZ; // ioctl flag

pub fn getTermSz(tty: std.os.fd_t) !TermSz {
    var winsz = c.winsize{ .ws_col = 0, .ws_row = 0, .ws_xpixel = 0, .ws_ypixel = 0 };
    const rv = std.os.system.ioctl(tty, TIOCGWINSZ, @intFromPtr(&winsz));
    const err = std.os.errno(rv);
    if (rv == 0) {
        return TermSz{ .height = winsz.ws_row, .width = winsz.ws_col };
    } else {
        return std.os.unexpectedErrno(err);
    }
}

pub fn initTermSize() !void {
    term_sz = try getTermSz(stdout.context.handle);
    const height_f: f128 = @floatFromInt(term_sz.height);
    const width_f: f128 = @floatFromInt(term_sz.width);
    term_ratio = TERM_FONT_RATIO * height_f / width_f;
}

const Window = struct {
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
};

pub var view_window: Window = Window{ .centre = c128{ .re = -0.5, .im = 0.0 }, .size = 1.0 };

pub const InputVals = struct {
    pub const up: u8 = "w"[0];
    pub const left: u8 = "a"[0];
    pub const down: u8 = "s"[0];
    pub const right: u8 = "d"[0];
    pub const in: u8 = "q"[0];
    pub const out: u8 = "e"[0];
    pub const help: u8 = "h"[0];
    pub const refresh: u8 = "r"[0];
};

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
