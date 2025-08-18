const std = @import("std");
const EVM = @import("../evm.zig").EVM;

pub fn sha3(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();
    var hash: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(
        evm.memory.access(@intCast(offset), @intCast(size)),
        &hash,
        .{},
    );
    try evm.stack.push(std.mem.readInt(u256, &hash, .big));
    try evm.gasDec(@intCast(30 + 6 * ((size + 31) / 32)));
    evm.pc += 1;
}