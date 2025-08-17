const std = @import("std");
const State = @import("../state.zig").State;

pub fn mload(state: *State) !void {
    const offset = try state.stack.pop();
    const data = state.memory.access(@intCast(offset), 32);

    var value: u256 = 0;
    for (data) |byte| {
        value = (value << 8) | byte;
    }

    try state.stack.push(value);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn mstore(state: *State) !void {
    const offset = try state.stack.pop();
    const value = try state.stack.pop();

    var bytes: [32]u8 = undefined;
    var val = value;
    var i: usize = 32;
    while (i > 0) : (i -= 1) {
        bytes[i - 1] = @truncate(val);
        val >>= 8;
    }

    const mem_cost = try state.memory.store(@intCast(offset), &bytes);
    try state.consumeGas(3 + mem_cost);
    state.pc += 1;
}

pub fn mstore8(state: *State) !void {
    const offset = try state.stack.pop();
    const value = try state.stack.pop();

    const byte = @as(u8, @truncate(value));
    const mem_cost = try state.memory.store(@intCast(offset), &[_]u8{byte});

    try state.consumeGas(3 + mem_cost);
    state.pc += 1;
}

pub fn msize(state: *State) !void {
    try state.stack.push(state.memory.buf.items.len);
    try state.consumeGas(2);
    state.pc += 1;
}
