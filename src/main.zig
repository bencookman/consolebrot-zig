const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const ascii = std.ascii;
const complex = std.math.complex;

const c64 = complex.Complex(f64);
const esc = ascii.control_code.esc;

const mandelbrot = @import("mandelbrot.zig");
const io = @import("io.zig");

// print info line
// print initial mandelbrot
// move cursor back to top with extra info
// wait for user input
// parse user input:
// - w - move up
// - a - move left
// - s - move down
// - d - move right
// - i - zoom in
// - o - zoom out
// do it all again
pub fn main() !void {
    while (true) {
        try io.initTermSize();

        // Write info
        const topleft: c64 = io.view_window.getTopLeft();
        const centre: c64 = io.view_window.centre;
        const bottomright: c64 = io.view_window.getBottomRight();
        try stdout.print("Top left     = {} + i{}\n", .{ topleft.re, topleft.im });
        try stdout.print("Centre       = {} + i{}\n", .{ centre.re, centre.im });
        try stdout.print("Bottom right = {} + i{}\n", .{ bottomright.re, bottomright.im });

        // Show Mandelbrot set
        const r: usize = io.term_sz.height - 5;
        const c: usize = io.term_sz.width;
        const r_f: f64 = @floatFromInt(r);
        const c_f: f64 = @floatFromInt(c);
        for (0..r) |i| {
            for (0..c) |j| {
                const i_f: f64 = @floatFromInt(i);
                const j_f: f64 = @floatFromInt(j);
                const coord_re: f64 = topleft.re + j_f * (bottomright.re - topleft.re) / (c_f - 1);
                const coord_im: f64 = topleft.im + i_f * (bottomright.im - topleft.im) / (r_f - 1);
                const coord: c64 = c64{ .re = coord_re, .im = coord_im };
                try stdout.print("{c}", .{mandelbrot.charFromIterations(mandelbrot.runMandelbrot(coord))});
            }
            try stdout.print("\n", .{});
        }

        // Take input
        try stdout.print("\n{c}[1A{c}[s", .{ esc, esc });
        while (true) {
            const inputByte: u8 = try stdin.readByte();
            switch (inputByte) {
                io.InputVals.up => {
                    try stdout.print("\n", .{});
                    try io.windowMoveUp();
                    break;
                },
                io.InputVals.down => {
                    try stdout.print("\n", .{});
                    try io.windowMoveDown();
                    break;
                },
                io.InputVals.left => {
                    try stdout.print("\n", .{});
                    try io.windowMoveLeft();
                    break;
                },
                io.InputVals.right => {
                    try stdout.print("\n", .{});
                    try io.windowMoveRight();
                    break;
                },
                io.InputVals.in => {
                    try stdout.print("\n", .{});
                    try io.windowZoomIn();
                    break;
                },
                io.InputVals.out => {
                    try stdout.print("\n", .{});
                    try io.windowZoomOut();
                    break;
                },
                io.InputVals.refresh => {
                    try stdout.print("\n", .{});
                    // Change nothing
                    break;
                },
                io.InputVals.help => {
                    try stdout.print("CONTROLS:\n", .{});
                    try stdout.print("\tMOVE LEFT  = {c}\n", .{io.InputVals.left});
                    try stdout.print("\tMOVE RIGHT = {c}\n", .{io.InputVals.right});
                    try stdout.print("\tMOVE UP    = {c}\n", .{io.InputVals.up});
                    try stdout.print("\tMOVE DOWN  = {c}\n", .{io.InputVals.down});
                    try stdout.print("\tZOOM IN    = {c}\n", .{io.InputVals.in});
                    try stdout.print("\tZOOM OUT   = {c}\n", .{io.InputVals.out});
                    try stdout.print("\tREFRESH    = {c}\n", .{io.InputVals.refresh});
                    try stdout.print("\tHELP       = {c}\n", .{io.InputVals.help});
                    try stdout.print("\n", .{});
                },

                else => {
                    try stdout.print("{c}[u           {c}[u", .{ esc, esc });
                },
            }
        }
    }
}
