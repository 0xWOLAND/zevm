const EVM = @import("../evm.zig").EVM;

pub fn dup(evm: *EVM, n: usize) !void {
    const value = try evm.stack.peek(n - 1);
    try evm.stack.push(value);
    evm.pc += 1;
    try evm.gasDec(3);
}
