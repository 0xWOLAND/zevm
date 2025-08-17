const State = @import("../state.zig").State;

pub fn sload(state: *State) !void {
    const key = try state.stack.pop();
    const result = try state.storage.load(state.allocator, key);
    try state.stack.push(result.value);
    
    const gas: u64 = if (result.warm) 100 else 2100;
    try state.consumeGas(gas);
    state.pc += 1;
}

pub fn sstore(state: *State) !void {
    const key = try state.stack.pop();
    const value = try state.stack.pop();
    
    const result = try state.storage.load(state.allocator, key);
    const old = result.value;
    const warm = try state.storage.store(state.allocator, key, value);
    
    const access_cost: u64 = if (warm) 100 else 2100;
    const dynamic_gas: u64 = if (value != old) 
        (if (old == 0) 20000 else 2900) 
    else 0;
    
    try state.consumeGas(access_cost + dynamic_gas);
    state.pc += 1;
    // TODO: Implement refunds
}

pub fn tload(state: *State) !void {
    const key = try state.stack.pop();
    // TODO: Implement separate transient storage
    const result = try state.storage.load(state.allocator, key);
    try state.stack.push(result.value);
    try state.consumeGas(100);
    state.pc += 1;
}

pub fn tstore(state: *State) !void {
    const key = try state.stack.pop();
    const value = try state.stack.pop();
    // TODO: Implement separate transient storage
    _ = try state.storage.store(state.allocator, key, value);
    try state.consumeGas(100);
    state.pc += 1;
}