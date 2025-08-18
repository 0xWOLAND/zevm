const EVM = @import("../evm.zig").EVM;

const JUMPDEST: u8 = 0x5b;

pub fn jump(evm: *EVM) !void {
    const counter = try evm.stack.pop();

    if (counter >= evm.program.len or evm.program[@intCast(counter)] != JUMPDEST) {
        return error.InvalidJump;
    }

    evm.pc = @intCast(counter);
    try evm.gasDec(8);
}

pub fn jumpi(evm: *EVM) !void {
    const counter = try evm.stack.pop();
    const b = try evm.stack.pop();

    if (b != 0) {
        if (counter >= evm.program.len or evm.program[@intCast(counter)] != JUMPDEST) {
            return error.InvalidJump;
        }
        evm.pc = @intCast(counter);
    } else {
        evm.pc += 1;
    }

    try evm.gasDec(10);
}

pub fn pc(evm: *EVM) !void {
    try evm.stack.push(evm.pc);
    evm.pc += 1;
    try evm.gasDec(2);
}

pub fn jumpdest(evm: *EVM) !void {
    evm.pc += 1;
    try evm.gasDec(1);
}
