const State = @import("../state.zig").State;

fn push(state: *State, n: u8) !void {
    state.pc += 1;
    try state.consumeGas(3);
    
    var value: u256 = 0;
    var i: u8 = 0;
    while (i < n) : (i += 1) {
        if (state.pc >= state.program.items.len) break;
        value = (value << 8) | state.program.items[state.pc];
        state.pc += 1;
    }
    try state.stack.push(value);
}

pub fn push1(state: *State) !void { try push(state, 1); }
pub fn push2(state: *State) !void { try push(state, 2); }
pub fn push3(state: *State) !void { try push(state, 3); }
pub fn push4(state: *State) !void { try push(state, 4); }
pub fn push5(state: *State) !void { try push(state, 5); }
pub fn push6(state: *State) !void { try push(state, 6); }
pub fn push7(state: *State) !void { try push(state, 7); }
pub fn push8(state: *State) !void { try push(state, 8); }
pub fn push9(state: *State) !void { try push(state, 9); }
pub fn push10(state: *State) !void { try push(state, 10); }
pub fn push11(state: *State) !void { try push(state, 11); }
pub fn push12(state: *State) !void { try push(state, 12); }
pub fn push13(state: *State) !void { try push(state, 13); }
pub fn push14(state: *State) !void { try push(state, 14); }
pub fn push15(state: *State) !void { try push(state, 15); }
pub fn push16(state: *State) !void { try push(state, 16); }
pub fn push17(state: *State) !void { try push(state, 17); }
pub fn push18(state: *State) !void { try push(state, 18); }
pub fn push19(state: *State) !void { try push(state, 19); }
pub fn push20(state: *State) !void { try push(state, 20); }
pub fn push21(state: *State) !void { try push(state, 21); }
pub fn push22(state: *State) !void { try push(state, 22); }
pub fn push23(state: *State) !void { try push(state, 23); }
pub fn push24(state: *State) !void { try push(state, 24); }
pub fn push25(state: *State) !void { try push(state, 25); }
pub fn push26(state: *State) !void { try push(state, 26); }
pub fn push27(state: *State) !void { try push(state, 27); }
pub fn push28(state: *State) !void { try push(state, 28); }
pub fn push29(state: *State) !void { try push(state, 29); }
pub fn push30(state: *State) !void { try push(state, 30); }
pub fn push31(state: *State) !void { try push(state, 31); }
pub fn push32(state: *State) !void { try push(state, 32); }