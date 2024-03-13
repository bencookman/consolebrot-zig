const std = @import("std");
const complex = std.math.complex;

const c128 = complex.Complex(f128);

const io = @import("io.zig");

const MIN_ITERS: u64 = 100;
const MAX_RADIUS: f128 = 2.0;

const FractalIters = struct {
    i: u64,
    i_max: u64,
};

pub fn charFromMandelbrotIters(iters: FractalIters) u8 {
    if (iters.i == iters.i_max) {
        return "0"[0];
    } else {
        return " "[0];
    }
}
fn windowMandelbrotMaxIters(window: io.Window) u64 {
    const size_f64: f64 = @floatCast(window.size);
    const i_max_float: f64 = std.math.pow(f64, 10, 1 - @log10(size_f64) / 6);
    const i_max: u64 = @intFromFloat(@round(i_max_float));
    return if (i_max < MIN_ITERS) MIN_ITERS else i_max;
}

pub fn runMandelbrot(c: c128, window: io.Window) FractalIters {
    var iters: FractalIters = FractalIters{ .i = 0, .i_max = windowMandelbrotMaxIters(window) };
    var z_n: c128 = c128{ .re = 0, .im = 0 };

    while (iters.i < iters.i_max) : (iters.i += 1) {
        z_n = c.add(z_n.mul(z_n)); // z_{n+1} = z_n^2 + c
        if (z_n.re * z_n.re + z_n.im * z_n.im > MAX_RADIUS * MAX_RADIUS) {
            break;
        }
    }

    return iters;
}
