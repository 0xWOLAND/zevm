const std = @import("std");
const EVM = @import("../evm.zig").EVM;

pub fn add(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a +% b);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn sub(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a -% b);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn mul(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a *% b);
    try evm.gasDec(5);
    evm.pc += 1;
}

pub fn div(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(if (b == 0) 0 else a / b);
    try evm.gasDec(5);
    evm.pc += 1;
}

pub fn sdiv(evm: *EVM) !void {
    const a: i256 = @bitCast(try evm.stack.pop());
    const b: i256 = @bitCast(try evm.stack.pop());
    try evm.stack.push(@bitCast(if (b == 0) @as(i256, 0) else @divTrunc(a, b)));
    try evm.gasDec(5);
    evm.pc += 1;
}

pub fn mod(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(if (b == 0) 0 else a % b);
    try evm.gasDec(5);
    evm.pc += 1;
}

pub fn smod(evm: *EVM) !void {
    const a: i256 = @bitCast(try evm.stack.pop());
    const b: i256 = @bitCast(try evm.stack.pop());
    try evm.stack.push(@bitCast(if (b == 0) @as(i256, 0) else @rem(a, b)));
    try evm.gasDec(5);
    evm.pc += 1;
}

pub fn addmod(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    const N = try evm.stack.pop();
    try evm.stack.push(if (N == 0) 0 else @mod(a +% b, N));
    try evm.gasDec(8);
    evm.pc += 1;
}

pub fn mulmod(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    const N = try evm.stack.pop();
    // Use u512 to prevent overflow in multiplication
    const wide_a = @as(u512, a);
    const wide_b = @as(u512, b);
    const wide_N = @as(u512, N);
    try evm.stack.push(if (N == 0) 0 else @as(u256, @truncate(@mod(wide_a * wide_b, wide_N))));
    try evm.gasDec(8);
    evm.pc += 1;
}

fn sizeInBytes(n: u256) u64 {
    if (n == 0) return 1;
    const bits = @as(u64, 256) - @clz(n);
    return (bits + 7) / 8;
}

pub fn exp(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const exponent = try evm.stack.pop();
    try evm.stack.push(std.math.pow(u256, a, exponent));
    try evm.gasDec(@intCast(10 + (50 * sizeInBytes(exponent))));
    evm.pc += 1;
}

pub fn signextend(evm: *EVM) !void {
    const b = try evm.stack.pop();
    const x = try evm.stack.pop();
    const result = if (b <= 31) blk: {
        const testbit = b * 8 + 7;
        const sign_bit = @as(u256, 1) << @as(u8, @intCast(testbit));
        break :blk if (x & sign_bit != 0)
            x | (std.math.maxInt(u256) - sign_bit + 1)
        else
            x & (sign_bit - 1);
    } else x;
    try evm.stack.push(result);
    try evm.gasDec(5);
    evm.pc += 1;
}
