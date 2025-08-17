const State = @import("../state.zig").State;

const JUMPDEST: u8 = 0x5b;

pub fn jump(state: *State) !void {
    const counter = try state.stack.pop();
    
    if (counter >= state.program.items.len or state.program.items[@intCast(counter)] != JUMPDEST) {
        return error.InvalidJump;
    }
    
    state.pc = @intCast(counter);
    try state.consumeGas(8);
}

pub fn jumpi(state: *State) !void {
    const counter = try state.stack.pop();
    const b = try state.stack.pop();
    
    if (b != 0) {
        if (counter >= state.program.items.len or state.program.items[@intCast(counter)] != JUMPDEST) {
            return error.InvalidJump;
        }
        state.pc = @intCast(counter);
    } else {
        state.pc += 1;
    }
    
    try state.consumeGas(10);
}

pub fn pc(state: *State) !void {
    try state.stack.push(state.pc);
    state.pc += 1;
    try state.consumeGas(2);
}

pub fn jumpdest(state: *State) !void {
    state.pc += 1;
    try state.consumeGas(1);
}