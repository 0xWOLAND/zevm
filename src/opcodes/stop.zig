const EVM = @import("../evm.zig").EVM;

pub fn stop(evm: *EVM) !void {
    evm.stop_flag = true;
    return;
}
