const EVM = @import("../evm.zig").EVM;

pub fn pop(evm: *EVM) !void {
    _ = try evm.stack.pop();
    try evm.gasDec(2);
    evm.pc += 1;
}
