const EVM = @import("../evm.zig").EVM;

pub fn lt(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(if (a < b) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn slt(evm: *EVM) !void {
    const a_unsigned = try evm.stack.pop();
    const b_unsigned = try evm.stack.pop();
    const a = @as(i256, @bitCast(a_unsigned));
    const b = @as(i256, @bitCast(b_unsigned));
    try evm.stack.push(if (a < b) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn gt(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(if (a > b) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn sgt(evm: *EVM) !void {
    const a_unsigned = try evm.stack.pop();
    const b_unsigned = try evm.stack.pop();
    const a = @as(i256, @bitCast(a_unsigned));
    const b = @as(i256, @bitCast(b_unsigned));
    try evm.stack.push(if (a > b) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn eq(evm: *EVM) !void {
    const a = try evm.stack.pop();
    const b = try evm.stack.pop();
    try evm.stack.push(if (a == b) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}

pub fn iszero(evm: *EVM) !void {
    const a = try evm.stack.pop();
    try evm.stack.push(if (a == 0) 1 else 0);
    try evm.gasDec(3);
    evm.pc += 1;
}
