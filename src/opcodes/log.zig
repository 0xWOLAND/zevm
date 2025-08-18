const EVM = @import("../evm.zig").EVM;
const types = @import("../types.zig");

fn calcGas(topic_count: u64, size: types.Word) u64 {
    return 375 * topic_count + 8 * @as(u64, @intCast(size));
}

fn logN(evm: *EVM, n: u8) !void {
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    var topics = try evm.allocator.alloc(types.Word, n);
    defer evm.allocator.free(topics);

    var i: u8 = 0;
    while (i < n) : (i += 1) {
        topics[i] = try evm.stack.pop();
    }

    const data = evm.memory.access(@intCast(offset), @intCast(size));
    const data_copy = try evm.allocator.dupe(u8, data);

    try evm.logs.append(.{
        .address = 0, // TODO: Use actual contract address
        .topics = topics,
        .data = data_copy,
    });

    evm.pc += 1;
    try evm.gasDec(@intCast(calcGas(n, size)));
}

pub fn log0(evm: *EVM) !void {
    try logN(evm, 0);
}
pub fn log1(evm: *EVM) !void {
    try logN(evm, 1);
}
pub fn log2(evm: *EVM) !void {
    try logN(evm, 2);
}
pub fn log3(evm: *EVM) !void {
    try logN(evm, 3);
}
pub fn log4(evm: *EVM) !void {
    try logN(evm, 4);
}
