const EVM = @import("../evm.zig").EVM;

// Stub implementations for contract operations
// These would need full implementation with contract creation and calling logic

pub fn create(evm: *EVM) !void {
    // Simplified stub - just pushes 0 address
    try evm.stack.push(0);
    evm.pc += 1;
}

pub fn call(evm: *EVM) !void {
    // Pop all required arguments
    _ = try evm.stack.pop(); // gas
    _ = try evm.stack.pop(); // address
    _ = try evm.stack.pop(); // value
    _ = try evm.stack.pop(); // argsOffset
    _ = try evm.stack.pop(); // argsSize
    _ = try evm.stack.pop(); // retOffset
    _ = try evm.stack.pop(); // retSize

    // Push success (1 for now)
    try evm.stack.push(1);
    evm.pc += 1;
}

pub fn callcode(evm: *EVM) !void {
    // Similar to call
    _ = try evm.stack.pop(); // gas
    _ = try evm.stack.pop(); // address
    _ = try evm.stack.pop(); // value
    _ = try evm.stack.pop(); // argsOffset
    _ = try evm.stack.pop(); // argsSize
    _ = try evm.stack.pop(); // retOffset
    _ = try evm.stack.pop(); // retSize

    try evm.stack.push(1);
    evm.pc += 1;
}

pub fn @"return"(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    const data = evm.memory.access(@intCast(offset), @intCast(size));
    try evm.returndata.appendSlice(data);

    evm.stop_flag = true;
    evm.pc += 1;
}

pub fn delegatecall(evm: *EVM) !void {
    _ = try evm.stack.pop(); // gas
    _ = try evm.stack.pop(); // address
    _ = try evm.stack.pop(); // argsOffset
    _ = try evm.stack.pop(); // argsSize
    _ = try evm.stack.pop(); // retOffset
    _ = try evm.stack.pop(); // retSize

    try evm.stack.push(1);
    evm.pc += 1;
}

pub fn create2(evm: *EVM) !void {
    _ = try evm.stack.pop(); // value
    _ = try evm.stack.pop(); // offset
    _ = try evm.stack.pop(); // size
    _ = try evm.stack.pop(); // salt

    try evm.stack.push(0);
    evm.pc += 1;
}

pub fn staticcall(evm: *EVM) !void {
    _ = try evm.stack.pop(); // gas
    _ = try evm.stack.pop(); // address
    _ = try evm.stack.pop(); // argsOffset
    _ = try evm.stack.pop(); // argsSize
    _ = try evm.stack.pop(); // retOffset
    _ = try evm.stack.pop(); // retSize

    try evm.stack.push(1);
    evm.pc += 1;
}

pub fn revert(evm: *EVM) !void {
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    const data = evm.memory.access(@intCast(offset), @intCast(size));
    try evm.returndata.appendSlice(data);

    evm.stop_flag = true;
    evm.revert_flag = true;
    evm.pc += 1;
}

pub fn invalid(_: *EVM) !void {
    return error.InvalidOpcode;
}

pub fn selfdestruct(evm: *EVM) !void {
    _ = try evm.stack.pop(); // beneficiary address
    evm.stop_flag = true;
    evm.pc += 1;
}
