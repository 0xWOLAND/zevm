const std = @import("std");
const State = @import("../state.zig").State;

pub fn address(state: *State) !void {
    // TODO: Implement actual contract address
    try state.stack.push(0);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn balance(state: *State) !void {
    _ = try state.stack.pop(); // address
    // TODO: Implement actual balance lookup
    try state.stack.push(100000);
    try state.consumeGas(2600); // TODO: 100 if warm
    state.pc += 1;
}

pub fn origin(state: *State) !void {
    try state.stack.push(state.sender);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn caller(state: *State) !void {
    try state.stack.push(state.sender);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn callvalue(state: *State) !void {
    try state.stack.push(state.value);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn calldataload(state: *State) !void {
    const i = try state.stack.pop();
    const offset = @as(usize, @intCast(i));
    
    var result: u256 = 0;
    const end = @min(offset + 32, state.calldata.items.len);
    if (offset < state.calldata.items.len) {
        for (state.calldata.items[offset..end]) |byte| {
            result = (result << 8) | byte;
        }
    }
    result <<= @intCast((32 - @min(32, if (offset >= state.calldata.items.len) 32 else end - offset)) * 8);
    
    try state.stack.push(result);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn calldatasize(state: *State) !void {
    try state.stack.push(state.calldata.items.len);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn calldatacopy(state: *State) !void {
    const destOffset = try state.stack.pop();
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    
    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), state.calldata.items.len);
    const data = if (src_start < state.calldata.items.len) 
        state.calldata.items[src_start..src_end] 
    else 
        &[_]u8{};
    
    const mem_cost = try state.memory.store(@intCast(destOffset), data);
    try state.consumeGas(3 + 3 * ((size + 31) / 32) + mem_cost);
    state.pc += 1;
}

pub fn codesize(state: *State) !void {
    try state.stack.push(state.program.items.len);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn codecopy(state: *State) !void {
    const destOffset = try state.stack.pop();
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    
    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), state.program.items.len);
    const data = if (src_start < state.program.items.len) 
        state.program.items[src_start..src_end] 
    else 
        &[_]u8{};
    
    const mem_cost = try state.memory.store(@intCast(destOffset), data);
    try state.consumeGas(3 + 3 * ((size + 31) / 32) + mem_cost);
    state.pc += 1;
}

pub fn gasprice(state: *State) !void {
    // TODO: Implement actual gas price
    try state.stack.push(0);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn extcodesize(state: *State) !void {
    _ = try state.stack.pop();
    // TODO: Implement external code storage
    try state.stack.push(0);
    try state.consumeGas(2600); // TODO: 100 if warm
    state.pc += 1;
}

pub fn extcodecopy(state: *State) !void {
    _ = try state.stack.pop();
    const destOffset = try state.stack.pop();
    _ = try state.stack.pop();
    const size = try state.stack.pop();
    
    // TODO: Implement external code storage
    const mem_cost = try state.memory.store(@intCast(destOffset), &[_]u8{});
    try state.consumeGas(2600 + 3 * ((size + 31) / 32) + mem_cost); // TODO: 100 if warm
    state.pc += 1;
}

pub fn returndatasize(state: *State) !void {
    try state.stack.push(state.returndata.items.len);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn returndatacopy(state: *State) !void {
    const destOffset = try state.stack.pop();
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    
    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), state.returndata.items.len);
    const data = if (src_start < state.returndata.items.len) 
        state.returndata.items[src_start..src_end] 
    else 
        &[_]u8{};
    
    const mem_cost = try state.memory.store(@intCast(destOffset), data);
    try state.consumeGas(3 + 3 * ((size + 31) / 32) + mem_cost);
    state.pc += 1;
}

pub fn extcodehash(state: *State) !void {
    _ = try state.stack.pop();
    // TODO: Implement external code hash storage
    try state.stack.push(0);
    try state.consumeGas(2600); // TODO: 100 if warm
    state.pc += 1;
}

pub fn blockhash(state: *State) !void {
    const blockNumber = try state.stack.pop();
    if (blockNumber > 256) return error.InvalidBlockNumber;
    // TODO: Implement block hash storage
    try state.stack.push(0x1cbcfa1ffb1ca1ca8397d4f490194db5fc0543089b9dee43f76cf3f962a185e8);
    try state.consumeGas(20);
    state.pc += 1;
}

pub fn coinbase(state: *State) !void {
    // TODO: Implement block context
    try state.stack.push(0x1cbcfa1ffb1ca1ca8397d4f490194db5fc0543089b9dee43f76cf3f962a185e8);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn timestamp(state: *State) !void {
    try state.stack.push(@intCast(std.time.timestamp()));
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn number(state: *State) !void {
    // TODO: Implement block context
    try state.stack.push(1);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn difficulty(state: *State) !void {
    // TODO: Implement block context (post-merge returns 0)
    try state.stack.push(0);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn gaslimit(state: *State) !void {
    // TODO: Implement block context
    try state.stack.push(30_000_000);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn chainid(state: *State) !void {
    // TODO: Make configurable
    try state.stack.push(1); // Mainnet
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn selfbalance(state: *State) !void {
    // TODO: Implement balance tracking
    try state.stack.push(0);
    try state.consumeGas(5);
    state.pc += 1;
}

pub fn basefee(state: *State) !void {
    // TODO: Implement block context
    try state.stack.push(0);
    try state.consumeGas(2);
    state.pc += 1;
}

pub fn gas(state: *State) !void {
    try state.stack.push(state.gas);
    try state.consumeGas(2);
    state.pc += 1;
}