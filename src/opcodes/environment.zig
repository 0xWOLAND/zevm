const std = @import("std");
const EVM = @import("../evm.zig").EVM;
const types = @import("../types.zig");

pub fn address(evm: *EVM) !void {
    // Returns the address of the account currently executing
    try evm.stack.push(evm.sender);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn balance(evm: *EVM) !void {
    _ = try evm.stack.pop(); // address
    // Mock implementation - always return same balance
    try evm.stack.push(99999999999);
    evm.pc += 1;
    try evm.gasDec(2600); // TODO: 100 if warm
}

pub fn origin(evm: *EVM) !void {
    // tx.origin - for us it's always equal to msg.sender
    try evm.stack.push(evm.sender);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn caller(evm: *EVM) !void {
    // For simplicity, using a hardcoded address as in the spec
    try evm.stack.push(0x414b60745072088d013721b4a28a0559b1A9d213);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn callvalue(evm: *EVM) !void {
    try evm.stack.push(evm.value);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn calldataload(evm: *EVM) !void {
    const i = try evm.stack.pop();
    const offset = @as(usize, @intCast(i));

    // Build 32 bytes, padding with zeros if needed
    var result: types.Word = 0;
    var bytes_read: usize = 0;

    while (bytes_read < 32) : (bytes_read += 1) {
        const byte_idx = offset + bytes_read;
        const byte: u8 = if (byte_idx < evm.calldata.len)
            evm.calldata[byte_idx]
        else
            0x00;

        result = (result << 8) | byte;
    }

    try evm.stack.push(result);
    evm.pc += 1;
    try evm.gasDec(3);
}

pub fn calldatasize(evm: *EVM) !void {
    try evm.stack.push(evm.calldata.len);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn calldatacopy(evm: *EVM) !void {
    const destOffset = try evm.stack.pop();
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), evm.calldata.len);
    const data = if (src_start < evm.calldata.len)
        evm.calldata[src_start..src_end]
    else
        &[_]u8{};

    const mem_cost = try evm.memory.store(@intCast(destOffset), data);

    const static_gas = 3;
    const minimum_word_size = (size + 31) / 32;
    const dynamic_gas = 3 * minimum_word_size + @as(types.Word, mem_cost);

    try evm.gasDec(@intCast(static_gas + dynamic_gas));
    evm.pc += 1;
}

pub fn codesize(evm: *EVM) !void {
    try evm.stack.push(evm.program.len);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn codecopy(evm: *EVM) !void {
    const destOffset = try evm.stack.pop();
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), evm.program.len);
    const data = if (src_start < evm.program.len)
        evm.program[src_start..src_end]
    else
        &[_]u8{};

    const mem_cost = try evm.memory.store(@intCast(destOffset), data);

    const static_gas = 3;
    const minimum_word_size = (size + 31) / 32;
    const dynamic_gas = 3 * minimum_word_size + @as(types.Word, mem_cost);

    try evm.gasDec(@intCast(static_gas + dynamic_gas));
    evm.pc += 1;
}

pub fn gasprice(evm: *EVM) !void {
    // Running locally, gas price is 0
    try evm.stack.push(0x00);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn extcodesize(evm: *EVM) !void {
    _ = try evm.stack.pop(); // address
    // No other programs in our simplified world
    try evm.stack.push(0x00);
    evm.pc += 1;
    try evm.gasDec(2600); // TODO: 100 if warm
}

pub fn extcodecopy(evm: *EVM) !void {
    _ = try evm.stack.pop(); // address
    const destOffset = try evm.stack.pop();
    _ = try evm.stack.pop(); // offset
    const size = try evm.stack.pop();

    // No external code, store empty
    const mem_cost = try evm.memory.store(@intCast(destOffset), &[_]u8{});

    const minimum_word_size = (size + 31) / 32;
    const dynamic_gas = 3 * minimum_word_size + @as(types.Word, mem_cost);
    const address_access_cost = 2600; // TODO: 100 if warm

    try evm.gasDec(@intCast(dynamic_gas + address_access_cost));
    evm.pc += 1;
}

pub fn returndatasize(evm: *EVM) !void {
    // No previous return data in our single execution
    try evm.stack.push(0x00);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn returndatacopy(evm: *EVM) !void {
    const destOffset = try evm.stack.pop();
    const offset = try evm.stack.pop();
    const size = try evm.stack.pop();

    // Using program as mock return data (as in spec)
    const src_start = @as(usize, @intCast(offset));
    const src_end = @min(src_start + @as(usize, @intCast(size)), evm.program.len);
    const data = if (src_start < evm.program.len)
        evm.program[src_start..src_end]
    else
        &[_]u8{};

    const mem_cost = try evm.memory.store(@intCast(destOffset), data);

    const minimum_word_size = (size + 31) / 32;
    const dynamic_gas = 3 * minimum_word_size + @as(types.Word, mem_cost);

    try evm.gasDec(@intCast(3 + dynamic_gas));
    evm.pc += 1;
}

pub fn extcodehash(evm: *EVM) !void {
    _ = try evm.stack.pop(); // address
    // No other programs, return 0
    try evm.stack.push(0x00);
    evm.pc += 1;
    try evm.gasDec(2600); // TODO: 100 if warm
}

pub fn blockhash(evm: *EVM) !void {
    const blockNumber = try evm.stack.pop();
    if (blockNumber > 256) return error.InvalidBlockNumber;

    // Mock blockhash
    try evm.stack.push(0x1cbcfa1ffb1ca1ca8397d4f490194db5fc0543089b9dee43f76cf3f962a185e8);
    evm.pc += 1;
    try evm.gasDec(20);
}

pub fn coinbase(evm: *EVM) !void {
    // Mock miner address
    try evm.stack.push(0x1cbcfa1ffb1ca1ca8397d4f490194db5fc0543089b9dee43f76cf3f962a185e8);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn timestamp(evm: *EVM) !void {
    // Mock timestamp
    try evm.stack.push(1234567890);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn number(evm: *EVM) !void {
    // Mock block number
    try evm.stack.push(12345);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn difficulty(evm: *EVM) !void {
    // Mock difficulty
    try evm.stack.push(1000000);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn gaslimit(evm: *EVM) !void {
    // Mock gas limit
    try evm.stack.push(8000000);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn chainid(evm: *EVM) !void {
    // Mock chain ID (1 for mainnet)
    try evm.stack.push(1);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn selfbalance(evm: *EVM) !void {
    // Mock self balance
    try evm.stack.push(1000000000);
    evm.pc += 1;
    try evm.gasDec(5);
}

pub fn basefee(evm: *EVM) !void {
    // Mock base fee
    try evm.stack.push(1000000000);
    evm.pc += 1;
    try evm.gasDec(2);
}
