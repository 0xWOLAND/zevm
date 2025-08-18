const std = @import("std");
const EVM = @import("../evm.zig").EVM;

pub fn mload(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const data = evm.memory.access(@intCast(offset), 32);

    var value: u256 = 0;
    for (data) |byte| {
        value = (value << 8) | byte;
    }

    try evm.stack.push(value);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn mstore(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const value = try evm.stack.pop();

    var bytes: [32]u8 = undefined;
    var val = value;
    var i: usize = 32;
    while (i > 0) : (i -= 1) {
        bytes[i - 1] = @truncate(val);
        val >>= 8;
    }

    const mem_cost = try evm.memory.store(@intCast(offset), &bytes);
    try evm.gasDec(@intCast(3 + @as(i64, @intCast(mem_cost))));
    evm.pc += 1;
}

pub fn mstore8(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const value = try evm.stack.pop();

    const byte = @as(u8, @truncate(value));
    const mem_cost = try evm.memory.store(@intCast(offset), &[_]u8{byte});

    try evm.gasDec(@intCast(3 + @as(i64, @intCast(mem_cost))));
    evm.pc += 1;
}

pub fn msize(evm: *EVM) !void {
    try evm.stack.push(evm.memory.buf.items.len);
    try evm.gasDec(2);
    evm.pc += 1;
}
