const EVM = @import("../evm.zig").EVM;

pub fn byte(evm: *EVM) !void {
    const i = try evm.stack.pop();
    const x = try evm.stack.pop();
    try evm.stack.push(if (i >= 32) 0 else (x >> @as(u8, @intCast((31 - i) * 8))) & 0xFF);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn shl(evm: *EVM) !void {
    const shift = try evm.stack.pop();
    const value = try evm.stack.pop();
    try evm.stack.push(if (shift >= 256) 0 else value << @as(u8, @intCast(shift)));
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn shr(evm: *EVM) !void {
    const shift = try evm.stack.pop();
    const value = try evm.stack.pop();
    try evm.stack.push(if (shift >= 256) 0 else value >> @as(u8, @intCast(shift)));
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn sar(evm: *EVM) !void {
    const shift = try evm.stack.pop();
    const value: i256 = @bitCast(try evm.stack.pop());
    const result = if (shift >= 256)
        (if (value < 0) @as(u256, @bitCast(@as(i256, -1))) else 0)
    else
        @as(u256, @bitCast(value >> @as(u8, @intCast(shift))));
    try evm.stack.push(result);
    try evm.gasDec(3);
    evm.pc += 1;
}
