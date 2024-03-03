const std = @import("std");
const complex = std.math.complex;

const c128 = complex.Complex(f128);

const MAX_ITERATIONS: u64 = 100;
const MAX_RADIUS: f128 = 10.0;

pub fn charFromIterations(n_iterations: u64) u8 {
    if (n_iterations == MAX_ITERATIONS) {
        return "0"[0];
    } else {
        return " "[0];
    }
}

pub fn runMandelbrot(c: c128) u64 {
    var n_iterations: u64 = 0;
    var z_n: c128 = c128{ .re = 0, .im = 0 };

    while (n_iterations < MAX_ITERATIONS) : (n_iterations += 1) {
        z_n = c.add(z_n.mul(z_n)); // z_{n+1} = z_n^2 + c
        if (z_n.re * z_n.re + z_n.im * z_n.im > MAX_RADIUS * MAX_RADIUS) {
            break;
        }
    }

    return n_iterations;
}
