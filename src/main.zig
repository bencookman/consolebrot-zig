const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const ascii = std.ascii;
const complex = std.math.complex;

const c128 = complex.Complex(f128);
const esc = ascii.control_code.esc;
const lf = ascii.control_code.lf;

const mandelbrot = @import("mandelbrot.zig");
const io = @import("io.zig");

pub fn main() !void {
    // Screen refresh loop
    while (true) {
        try io.initTermSize();

        switch (io.current_mode) {
            io.modes.mandelbrot => {
                try loopMandelbrot();
            },
            io.modes.calibrating => {
                try loopCalibrate();
            },
        }
    }
}

fn loopMandelbrot() !void {

    // Show Mandelbrot set
    const topleft: c128 = io.view_window.getTopLeft();
    const bottomright: c128 = io.view_window.getBottomRight();
    const r: usize = io.view_window.window_size.height;
    const c: usize = io.view_window.window_size.width;
    const r_f: f128 = @floatFromInt(r);
    const c_f: f128 = @floatFromInt(c);
    for (0..r) |i| {
        for (0..c) |j| {
            const i_f: f128 = @floatFromInt(i);
            const j_f: f128 = @floatFromInt(j);
            const coord_re: f128 = topleft.re + j_f * (bottomright.re - topleft.re) / (c_f - 1);
            const coord_im: f128 = topleft.im + i_f * (bottomright.im - topleft.im) / (r_f - 1);
            const coord: c128 = c128{ .re = coord_re, .im = coord_im };
            const coord_out: u8 = mandelbrot.charFromMandelbrotIters(mandelbrot.runMandelbrot(coord, io.view_window));
            try stdout.print("{c}", .{coord_out});
        }
        try stdout.print("\n", .{});
    }

    // Take input
    // io.InputVals.help is known at comptime so ++ operator is allowed
    const input_msg = "Press '" ++ [_]u8{io.InputKeysMandelbrot.help} ++ "' for help. ";
    try stdout.print("{s}", .{input_msg});

    input: while (true) {
        const input_byte: u8 = try stdin.readByte();
        switch (input_byte) {
            // Breaking means refreshing the screen
            io.InputKeysMandelbrot.up => {
                try io.windowMoveUp();
                break :input;
            },
            io.InputKeysMandelbrot.down => {
                try io.windowMoveDown();
                break :input;
            },
            io.InputKeysMandelbrot.left => {
                try io.windowMoveLeft();
                break :input;
            },
            io.InputKeysMandelbrot.right => {
                try io.windowMoveRight();
                break :input;
            },
            io.InputKeysMandelbrot.in => {
                try io.windowZoomIn();
                break :input;
            },
            io.InputKeysMandelbrot.out => {
                try io.windowZoomOut();
                break :input;
            },
            io.InputKeysMandelbrot.refresh => {
                break :input;
            },
            io.InputKeysMandelbrot.where => {
                try io.view_window.printDiagonalCoords();
            },
            io.InputKeysMandelbrot.help => {
                try io.printHelpMandelbrot();
            },
            io.InputKeysMandelbrot.calibrate => {
                io.current_mode = io.modes.calibrating;
                break :input;
            },
            lf => {},
            else => {},
        }
    }
}

fn loopCalibrate() !void {
    const topleft: c128 = io.view_window.getTopLeft();
    const centre: c128 = io.view_window.centre;
    const bottomright: c128 = io.view_window.getBottomRight();
    const r: usize = io.view_window.window_size.height;
    const c: usize = io.view_window.window_size.width;
    const r_f: f128 = @floatFromInt(r);
    const c_f: f128 = @floatFromInt(c);
    for (0..r) |i| {
        for (0..c) |j| {
            const i_f: f128 = @floatFromInt(i);
            const j_f: f128 = @floatFromInt(j);
            const coord_re: f128 = topleft.re + j_f * (bottomright.re - topleft.re) / (c_f - 1);
            const coord_im: f128 = topleft.im + i_f * (bottomright.im - topleft.im) / (r_f - 1);
            const coord: c128 = c128{ .re = coord_re, .im = coord_im };
            const dist_to_centre: f128 = coord.sub(centre).magnitude();
            const coord_char: u8 = if (dist_to_centre < io.view_window.size * io.term_ratio) "0"[0] else " "[0];
            try stdout.print("{c}", .{coord_char});
        }
        try stdout.print("\n", .{});
    }

    const input_msg = "Calibrate axes by making the shape above a circle. Press '" ++ [_]u8{io.InputKeysCalibrate.help} ++ "' for help. ";
    try stdout.print("{s}", .{input_msg});

    input: while (true) {
        const input_byte: u8 = try stdin.readByte();
        switch (input_byte) {
            io.InputKeysCalibrate.increase => {
                io.term_font_ratio += 0.05;
                break :input;
            },
            io.InputKeysCalibrate.decrease => {
                io.term_font_ratio -= 0.05;
                break :input;
            },
            io.InputKeysCalibrate.refresh => {
                break :input;
            },
            io.InputKeysCalibrate.where => {
                try stdout.print("Current scaling:\n", .{});
                // f128 do not support decimal printing
                try stdout.print("\tFont height is {} time taller than font width.\n", .{io.term_font_ratio});
            },
            io.InputKeysCalibrate.help => {
                try io.printHelpCalibrate();
            },
            io.InputKeysCalibrate.mandelbrot => {
                io.current_mode = io.modes.mandelbrot;
                break :input;
            },
            lf => {},
            else => {},
        }
    }
}
