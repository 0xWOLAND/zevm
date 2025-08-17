const State = @import("../state.zig").State;

pub fn stop(state: *State) !void {
    state.stop_flag = true;
    return;
}
