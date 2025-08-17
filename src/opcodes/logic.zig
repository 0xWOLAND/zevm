const State = @import("../state.zig").State;

// Bitwise operations
pub fn and_(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a & b);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn or_(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a | b);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn xor(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(a ^ b);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn not(state: *State) !void {
    const a = try state.stack.pop();
    try state.stack.push(~a);
    try state.consumeGas(3);
    state.pc += 1;
}
