const EVM = @import("../evm.zig").EVM;
const Word = @import("../types.zig").Word;

pub fn push(evm: *EVM, n: usize) !void {
    evm.pc += 1;
    try evm.gasDec(3);

    var value: Word = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        if (evm.pc >= evm.program.len) break;
        value = (value << 8) | evm.program[evm.pc];
        evm.pc += 1;
    }
    try evm.stack.push(value);
}
