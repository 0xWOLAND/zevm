const std = @import("std");
const State = @import("../state.zig").State;

pub fn sha3(state: *State) !void {
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    
    // Get data from memory and hash it
    const data = state.memory.access(@intCast(offset), @intCast(size));
    var hash: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(data, &hash, .{});
    
    // Convert to u256
    var result: u256 = 0;
    for (hash) |byte| result = (result << 8) | byte;
    
    try state.stack.push(result);
    try state.consumeGas(30 + 6 * ((size + 31) / 32));
    state.pc += 1;
}