const EVM = @import("../evm.zig").EVM;

pub fn sload(evm: *EVM) !void {
    const key = try evm.stack.pop();
    const result = try evm.storage.load(evm.allocator, key);
    try evm.stack.push(result.value);

    const gas: u64 = if (result.warm) 100 else 2100;
    try evm.gasDec(@intCast(gas));
    evm.pc += 1;
}

pub fn sstore(evm: *EVM) !void {
    const key = try evm.stack.pop();
    const value = try evm.stack.pop();

    const result = try evm.storage.load(evm.allocator, key);
    const old = result.value;
    const warm = try evm.storage.store(evm.allocator, key, value);

    const access_cost: u64 = if (warm) 100 else 2100;
    const dynamic_gas: u64 = if (value != old)
        (if (old == 0) 20000 else 2900)
    else
        0;

    try evm.gasDec(@intCast(access_cost + dynamic_gas));
    evm.pc += 1;
    // TODO: Implement refunds
}

pub fn tload(evm: *EVM) !void {
    const key = try evm.stack.pop();
    // TODO: Implement separate transient storage
    const result = try evm.storage.load(evm.allocator, key);
    try evm.stack.push(result.value);
    try evm.gasDec(100);
    evm.pc += 1;
}

pub fn tstore(evm: *EVM) !void {
    const key = try evm.stack.pop();
    const value = try evm.stack.pop();
    // TODO: Implement separate transient storage
    _ = try evm.storage.store(evm.allocator, key, value);
    try evm.gasDec(100);
    evm.pc += 1;
}
