const EVM = @import("../evm.zig").EVM;

// Bitwise operations
pub fn @"and"(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a & b);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn @"or"(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a | b);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn xor(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(a ^ b);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn not(evm: *EVM) !void {
    const a = try evm.stack.pop();
    try evm.stack.push(~a);
    try evm.gasDec(3);
    evm.pc += 1;
}
