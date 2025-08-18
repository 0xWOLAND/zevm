const EVM = @import("../evm.zig").EVM;

pub fn swap(evm: *EVM, n: usize) !void {
    const value1 = try evm.stack.peek(0);
    const value2 = try evm.stack.peek(n);

    evm.stack.items.items[evm.stack.items.items.len - 1] = value2;
    evm.stack.items.items[evm.stack.items.items.len - 1 - n] = value1;

    evm.pc += 1;
    try evm.gasDec(3);
}
