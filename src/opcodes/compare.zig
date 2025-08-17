const State = @import("../state.zig").State;

pub fn lt(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(if (a < b) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn slt(state: *State) !void {
    const a = @as(i256, try state.stack.pop());
    const b = @as(i256, try state.stack.pop());
    try state.stack.push(if (a < b) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn gt(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(if (a > b) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn sgt(state: *State) !void {
    const a = @as(i256, try state.stack.pop());
    const b = @as(i256, try state.stack.pop());
    try state.stack.push(if (a > b) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn eq(state: *State) !void {
    const a = try state.stack.pop();
    const b = try state.stack.pop();
    try state.stack.push(if (a == b) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn iszero(state: *State) !void {
    const a = try state.stack.pop();
    try state.stack.push(if (a == 0) 1 else 0);
    try state.consumeGas(3);
    state.pc += 1;
}
