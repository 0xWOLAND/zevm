const State = @import("../state.zig").State;

fn dup(state: *State, n: u8) !void {
    const value = try state.stack.peek(n - 1);
    try state.stack.push(value);
    state.pc += 1;
    try state.consumeGas(3);
}

pub fn dup1(state: *State) !void { try dup(state, 1); }
pub fn dup2(state: *State) !void { try dup(state, 2); }
pub fn dup3(state: *State) !void { try dup(state, 3); }
pub fn dup4(state: *State) !void { try dup(state, 4); }
pub fn dup5(state: *State) !void { try dup(state, 5); }
pub fn dup6(state: *State) !void { try dup(state, 6); }
pub fn dup7(state: *State) !void { try dup(state, 7); }
pub fn dup8(state: *State) !void { try dup(state, 8); }
pub fn dup9(state: *State) !void { try dup(state, 9); }
pub fn dup10(state: *State) !void { try dup(state, 10); }
pub fn dup11(state: *State) !void { try dup(state, 11); }
pub fn dup12(state: *State) !void { try dup(state, 12); }
pub fn dup13(state: *State) !void { try dup(state, 13); }
pub fn dup14(state: *State) !void { try dup(state, 14); }
pub fn dup15(state: *State) !void { try dup(state, 15); }
pub fn dup16(state: *State) !void { try dup(state, 16); }