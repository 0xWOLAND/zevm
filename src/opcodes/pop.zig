const State = @import("../state.zig").State;

pub fn pop(state: *State) !void {
    try state.stack.pop();
    try state.consumeGas(2);
    state.pc += 1;
}
