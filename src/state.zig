const std = @import("std");
const types = @import("types.zig");
const Storage = @import("storage.zig").Storage;
const Memory = @import("memory.zig").Memory;
const Stack = @import("stack.zig").Stack;
const Log = @import("log.zig").Log;

const Word = types.Word;
const Address = types.Address;

pub const State = struct {
    pc: u32,
    
    stack: Stack,
    memory: Memory,
    storage: Storage,
    
    sender: Address,
    program: std.ArrayList(u8),
    gas: u64,
    value: Word,
    calldata: std.ArrayList(u8),
    
    stop_flag: bool,
    revert_flag: bool,
    
    returndata: std.ArrayList(u8),
    logs: std.ArrayList(Log),
    
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        sender: Address,
        program: []const u8,
        gas: u64,
        value: Word,
        calldata: []const u8,
    ) !State {
        var prog = std.ArrayList(u8).init(allocator);
        try prog.appendSlice(program);
        
        var call = std.ArrayList(u8).init(allocator);
        try call.appendSlice(calldata);
        
        return State{
            .pc = 0,
            .stack = Stack.init(allocator),
            .memory = Memory.init(allocator),
            .storage = Storage.init(allocator),
            .sender = sender,
            .program = prog,
            .gas = gas,
            .value = value,
            .calldata = call,
            .stop_flag = false,
            .revert_flag = false,
            .returndata = std.ArrayList(u8).init(allocator),
            .logs = std.ArrayList(Log).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *State) void {
        self.stack.deinit();
        self.memory.deinit();
        self.storage.deinit();
        self.program.deinit();
        self.calldata.deinit();
        self.returndata.deinit();
        
        for (self.logs.items) |*log| {
            log.deinit();
        }
        self.logs.deinit();
    }

    pub fn consumeGas(self: *State, amount: u64) !void {
        if (amount > self.gas) {
            return error.OutOfGas;
        }
        self.gas -= amount;
    }

    pub fn addLog(self: *State, address: Address) !*Log {
        const log = Log.init(self.allocator, address);
        try self.logs.append(log);
        return &self.logs.items[self.logs.items.len - 1];
    }

    pub fn stop(self: *State) void {
        self.stop_flag = true;
    }

    pub fn revert(self: *State) void {
        self.revert_flag = true;
    }

    pub fn isHalted(self: *State) bool {
        return self.stop_flag or self.revert_flag;
    }

    pub fn getNextByte(self: *State) ?u8 {
        if (self.pc >= self.program.items.len) {
            return null;
        }
        const byte = self.program.items[self.pc];
        self.pc += 1;
        return byte;
    }

    pub fn getNextBytes(self: *State, n: usize) ?[]u8 {
        if (self.pc + n > self.program.items.len) {
            return null;
        }
        const bytes = self.program.items[self.pc .. self.pc + n];
        self.pc += @intCast(n);
        return bytes;
    }
};

test "State initialization and gas" {
    const allocator = std.testing.allocator;
    
    const sender = types.address(&[_]u8{0x01});
    const program = [_]u8{ 0x60, 0x01, 0x60, 0x02, 0x01 };
    const gas: u64 = 100000;
    const value = types.ZERO_WORD;
    const calldata = [_]u8{ 0xaa, 0xbb, 0xcc };
    
    var state = try State.init(allocator, sender, &program, gas, value, &calldata);
    defer state.deinit();
    
    try std.testing.expect(state.pc == 0);
    try std.testing.expect(state.gas == 100000);
    
    try state.consumeGas(50000);
    try std.testing.expect(state.gas == 50000);
    
    try std.testing.expectError(error.OutOfGas, state.consumeGas(60000));
}

test "State program counter" {
    const allocator = std.testing.allocator;
    
    const sender = types.ZERO_ADDRESS;
    const program = [_]u8{ 0x60, 0x01, 0x60, 0x02 };
    const value = types.ZERO_WORD;
    
    var state = try State.init(allocator, sender, &program, 1000, value, &[_]u8{});
    defer state.deinit();
    
    const byte1 = state.getNextByte();
    try std.testing.expect(byte1.? == 0x60);
    try std.testing.expect(state.pc == 1);
    
    const bytes = state.getNextBytes(2);
    try std.testing.expectEqualSlices(u8, bytes.?, &[_]u8{ 0x01, 0x60 });
    try std.testing.expect(state.pc == 3);
}