const State = @import("../state.zig");

pub fn revert(state: *State) !void {
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    state.returndata = state.memory.access(offset, size);

    state.stop_flag = true;
    state.revert_flag = true;
    state.pc += 1;
}
