const State = @import("../state.zig").State;

pub fn byte(state: *State) !void {
    const i = try state.stack.pop();
    const x = try state.stack.pop();
    try state.stack.push(if (i >= 32) 0 else (x >> @as(u8, @intCast((31 - i) * 8))) & 0xFF);
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn shl(state: *State) !void {
    const shift = try state.stack.pop();
    const value = try state.stack.pop();
    try state.stack.push(if (shift >= 256) 0 else value << @as(u8, @intCast(shift)));
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn shr(state: *State) !void {
    const shift = try state.stack.pop();
    const value = try state.stack.pop();
    try state.stack.push(if (shift >= 256) 0 else value >> @as(u8, @intCast(shift)));
    try state.consumeGas(3);
    state.pc += 1;
}

pub fn sar(state: *State) !void {
    const shift = try state.stack.pop();
    const value: i256 = @bitCast(try state.stack.pop());
    const result = if (shift >= 256)
        (if (value < 0) @as(u256, @bitCast(@as(i256, -1))) else 0)
    else
        @as(u256, @bitCast(value >> @as(u8, @intCast(shift))));
    try state.stack.push(result);
    try state.consumeGas(3);
    state.pc += 1;
}
