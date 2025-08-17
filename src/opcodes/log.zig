const State = @import("../state.zig").State;
const Log = @import("../log.zig").Log;

fn calcGas(topic_count: u64, size: u256) u64 {
    return 375 * topic_count + 8 * @as(u64, @intCast(size));
}

fn logN(state: *State, n: u8) !void {
    const offset = try state.stack.pop();
    const size = try state.stack.pop();
    
    var log = Log.init(state.allocator, 0); // TODO: Use actual contract address
    
    var i: u8 = 0;
    while (i < n) : (i += 1) {
        const topic = try state.stack.pop();
        try log.addTopic(topic);
    }
    
    const data = state.memory.access(@intCast(offset), @intCast(size));
    try log.setData(data);
    
    try state.logs.append(log);
    
    state.pc += 1;
    try state.consumeGas(calcGas(n, size));
}

pub fn log0(state: *State) !void { try logN(state, 0); }
pub fn log1(state: *State) !void { try logN(state, 1); }
pub fn log2(state: *State) !void { try logN(state, 2); }
pub fn log3(state: *State) !void { try logN(state, 3); }
pub fn log4(state: *State) !void { try logN(state, 4); }