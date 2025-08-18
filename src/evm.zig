const std = @import("std");
const types = @import("types.zig");
const Stack = @import("core/stack.zig").Stack;
const Memory = @import("core/memory.zig").Memory;
const Storage = @import("core/storage.zig").Storage;

const Word = types.Word;

pub const EVM = struct {
    pc: usize,
    stack: Stack,
    memory: Memory,
    storage: Storage,

    program: []const u8,
    gas: i64,
    value: Word,
    calldata: []const u8,
    sender: types.Address,

    stop_flag: bool,
    revert_flag: bool,

    returndata: std.ArrayList(u8),
    logs: std.ArrayList(Log),

    allocator: std.mem.Allocator,

    pub const Log = struct {
        address: types.Address,
        topics: []Word,
        data: []u8,
    };

    pub fn init(
        allocator: std.mem.Allocator,
        program: []const u8,
        gas: i64,
        value: Word,
        calldata: []const u8,
        sender: types.Address,
    ) !EVM {
        return EVM{
            .pc = 0,
            .stack = Stack.init(allocator),
            .memory = Memory.init(allocator),
            .storage = Storage.init(),
            .program = program,
            .gas = gas,
            .value = value,
            .calldata = calldata,
            .sender = sender,
            .stop_flag = false,
            .revert_flag = false,
            .returndata = std.ArrayList(u8).init(allocator),
            .logs = std.ArrayList(Log).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *EVM) void {
        self.stack.deinit();
        self.memory.deinit();
        self.storage.deinit(self.allocator);
        self.returndata.deinit();
        self.logs.deinit();
    }

    pub fn peek(self: *const EVM) ?u8 {
        if (self.pc >= self.program.len) return null;
        return self.program[self.pc];
    }

    pub fn gasDec(self: *EVM, amount: i64) !void {
        if (self.gas < amount) return error.OutOfGas;
        self.gas -= amount;
    }

    pub fn run(self: *EVM) !void {
        while (self.pc < self.program.len and !self.stop_flag and !self.revert_flag) {
            const op = self.program[self.pc];
            if (handlers[op]) |handler| {
                try handler(self);
            } else {
                return error.UnknownOpcode;
            }
        }
    }

    pub fn reset(self: *EVM) void {
        self.pc = 0;
        self.stack.deinit();
        self.stack = Stack.init(self.allocator);
        self.memory.deinit();
        self.memory = Memory.init(self.allocator);
        self.storage.deinit(self.allocator);
        self.storage = Storage.init();
        self.stop_flag = false;
        self.revert_flag = false;
        self.returndata.clearRetainingCapacity();
        self.logs.clearRetainingCapacity();
    }
};

// Build dispatch table at compile time
const handlers = blk: {
    const math = @import("opcodes/math.zig");
    const compare = @import("opcodes/compare.zig");
    const logic = @import("opcodes/logic.zig");
    const bit = @import("opcodes/bit.zig");
    const misc = @import("opcodes/misc.zig");
    const env = @import("opcodes/environment.zig");
    const memory = @import("opcodes/memory.zig");
    const storage = @import("opcodes/storage.zig");
    const jump = @import("opcodes/jump.zig");
    const push = @import("opcodes/push.zig");
    const dup = @import("opcodes/dup.zig");
    const swap = @import("opcodes/swap.zig");
    const log = @import("opcodes/log.zig");
    const contract = @import("opcodes/contract.zig");
    const pop = @import("opcodes/pop.zig");
    const stop = @import("opcodes/stop.zig");

    var table: [256]?*const fn (*EVM) anyerror!void = [_]?*const fn (*EVM) anyerror!void{null} ** 256;

    // Stop & Math
    table[0x00] = stop.stop;
    table[0x01] = math.add;
    table[0x02] = math.mul;
    table[0x03] = math.sub;
    table[0x04] = math.div;
    table[0x05] = math.sdiv;
    table[0x06] = math.mod;
    table[0x07] = math.smod;
    table[0x08] = math.addmod;
    table[0x09] = math.mulmod;
    table[0x0A] = math.exp;
    table[0x0B] = math.signextend;

    // Comparison & Logic
    table[0x10] = compare.lt;
    table[0x11] = compare.gt;
    table[0x12] = compare.slt;
    table[0x13] = compare.sgt;
    table[0x14] = compare.eq;
    table[0x15] = compare.iszero;
    table[0x16] = logic.@"and";
    table[0x17] = logic.@"or";
    table[0x18] = logic.xor;
    table[0x19] = logic.not;

    // Bit & SHA3
    table[0x1A] = bit.byte;
    table[0x1B] = bit.shl;
    table[0x1C] = bit.shr;
    table[0x1D] = bit.sar;
    table[0x20] = misc.sha3;

    // Environment
    table[0x30] = env.address;
    table[0x31] = env.balance;
    table[0x32] = env.origin;
    table[0x33] = env.caller;
    table[0x34] = env.callvalue;
    table[0x35] = env.calldataload;
    table[0x36] = env.calldatasize;
    table[0x37] = env.calldatacopy;
    table[0x38] = env.codesize;
    table[0x39] = env.codecopy;
    table[0x3A] = env.gasprice;
    table[0x3B] = env.extcodesize;
    table[0x3C] = env.extcodecopy;
    table[0x3D] = env.returndatasize;
    table[0x3E] = env.returndatacopy;
    table[0x3F] = env.extcodehash;
    table[0x40] = env.blockhash;
    table[0x41] = env.coinbase;
    table[0x42] = env.timestamp;
    table[0x43] = env.number;
    table[0x44] = env.difficulty;
    table[0x45] = env.gaslimit;
    table[0x46] = env.chainid;
    table[0x47] = env.selfbalance;
    table[0x48] = env.basefee;

    // Stack, Memory & Storage
    table[0x50] = pop.pop;
    table[0x51] = memory.mload;
    table[0x52] = memory.mstore;
    table[0x53] = memory.mstore8;
    table[0x54] = storage.sload;
    table[0x55] = storage.sstore;

    // Jump & Transient Storage
    table[0x56] = jump.jump;
    table[0x57] = jump.jumpi;
    table[0x58] = jump.pc;
    table[0x59] = storage.tload;
    table[0x5A] = storage.tstore;
    table[0x5B] = jump.jumpdest;

    // Push operations (0x60-0x7F)
    for (0..32) |n| {
        table[0x60 + n] = struct {
            fn f(evm: *EVM) anyerror!void {
                try push.push(evm, n + 1);
            }
        }.f;
    }

    // Dup operations (0x80-0x8F)
    for (0..16) |n| {
        table[0x80 + n] = struct {
            fn f(evm: *EVM) anyerror!void {
                try dup.dup(evm, n + 1);
            }
        }.f;
    }

    // Swap operations (0x90-0x9F)
    for (0..16) |n| {
        table[0x90 + n] = struct {
            fn f(evm: *EVM) anyerror!void {
                try swap.swap(evm, n + 1);
            }
        }.f;
    }

    // Logs
    table[0xA0] = log.log0;
    table[0xA1] = log.log1;
    table[0xA2] = log.log2;
    table[0xA3] = log.log3;
    table[0xA4] = log.log4;

    // Contract operations
    table[0xF0] = contract.create;
    table[0xF1] = contract.call;
    table[0xF2] = contract.callcode;
    table[0xF3] = contract.@"return";
    table[0xF4] = contract.delegatecall;
    table[0xF5] = contract.create2;
    table[0xFA] = contract.staticcall;
    table[0xFD] = contract.revert;
    table[0xFE] = contract.invalid;
    table[0xFF] = contract.selfdestruct;

    break :blk table;
};

test {
    // Include tests from opcode modules
    _ = @import("opcodes/stop.zig");
    _ = @import("opcodes/math.zig");
    _ = @import("opcodes/compare.zig");
    _ = @import("opcodes/logic.zig");
    _ = @import("opcodes/bit.zig");
    _ = @import("opcodes/misc.zig");
    _ = @import("opcodes/environment.zig");
    _ = @import("opcodes/memory.zig");
    _ = @import("opcodes/storage.zig");
    _ = @import("opcodes/jump.zig");
    _ = @import("opcodes/push.zig");
    _ = @import("opcodes/dup.zig");
    _ = @import("opcodes/swap.zig");
    _ = @import("opcodes/log.zig");
    _ = @import("opcodes/contract.zig");
    _ = @import("opcodes/pop.zig");
}
