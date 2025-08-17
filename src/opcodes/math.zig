const std = @import("std");
const State = @import("../state.zig").State;

pub fn add(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a +% b);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn sub(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a -% b);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn mul(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a *% b);
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn div(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(if (b == 0) 0 else a / b);
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn sdiv(state: *State) !void {
    const a: i256 = @bitCast(try state.stack.pop());
    const b: i256 = @bitCast(try state.stack.pop());
    try state.stack.push(@bitCast(if (b == 0) @as(i256, 0) else @divTrunc(a, b)));
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn mod(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(if (b == 0) 0 else a % b);
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn smod(state: *State) !void {
    const a: i256 = @bitCast(try state.stack.pop());
    const b: i256 = @bitCast(try state.stack.pop());
    try state.stack.push(@bitCast(if (b == 0) @as(i256, 0) else @rem(a, b)));
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn addmod(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    const N = try state.stack.pop();
    try state.stack.push(if (N == 0) 0 else @mod(a +% b, N));
    try state.consumeGas(8);
    state.pc += 1;
}

pub fn mulmod(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    const N = try state.stack.pop();
    // Use u512 to prevent overflow in multiplication
    const wide_a = @as(u512, a);
    const wide_b = @as(u512, b);
    const wide_N = @as(u512, N);
    try state.stack.push(if (N == 0) 0 else @as(u256, @truncate(@mod(wide_a * wide_b, wide_N))));
    try state.consumeGas(8);
    state.pc += 1;
}

fn sizeInBytes(n: u256) u64 {
    if (n == 0) return 1;
    const bits = @as(u64, 256) - @clz(n);
    return (bits + 7) / 8;
}

pub fn exp(state: *State) !void {
    const a = try state.stack.pop();
    const exponent = try state.stack.pop();
    try state.stack.push(std.math.pow(u256, a, exponent));
    try state.consumeGas(10 + (50 * sizeInBytes(exponent)));
    state.pc += 1;
}

pub fn signextend(state: *State) !void {
    const b = try state.stack.pop();
    const x = try state.stack.pop();
    const result = if (b <= 31) blk: {
        const testbit = b * 8 + 7;
        const sign_bit = @as(u256, 1) << @as(u8, @intCast(testbit));
        break :blk if (x & sign_bit != 0)
            x | (std.math.maxInt(u256) - sign_bit + 1)
        else
            x & (sign_bit - 1);
    } else x;
    try state.stack.push(result);
    try state.consumeGas(5);
    state.pc += 1;
}
