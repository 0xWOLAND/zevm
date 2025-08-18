const std = @import("std");
const opcodes = @import("opcodes.zig");

pub fn assemble(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var bytecode = std.ArrayList(u8).init(allocator);
    var iter = std.mem.tokenize(u8, source, " \n\r\t,");

    while (iter.next()) |token| {
        if (token[0] == ';') continue;

        if (opcodes.name_map.get(token)) |opcode| {
            try bytecode.append(opcode);
        } else if (token.len > 4 and std.mem.eql(u8, token[0..4], "PUSH")) {
            const n = try std.fmt.parseInt(u8, token[4..], 10);
            try bytecode.append(0x5F + n); // PUSH0 = 0x5F, PUSH1 = 0x60, etc

            if (n > 0) {
                const next = iter.next() orelse return error.MissingPushValue;
                const value = if (next.len > 2 and next[0] == '0' and next[1] == 'x')
                    try std.fmt.parseInt(u256, next[2..], 16)
                else
                    try std.fmt.parseInt(u256, next, 10);

                var i: u8 = n;
                while (i > 0) : (i -= 1) {
                    try bytecode.append(@truncate(value >> @intCast((i - 1) * 8)));
                }
            }
        } else if (token.len > 3 and std.mem.eql(u8, token[0..3], "DUP")) {
            const n = try std.fmt.parseInt(u8, token[3..], 10);
            try bytecode.append(0x7F + n); // DUP1 = 0x80
        } else if (token.len > 4 and std.mem.eql(u8, token[0..4], "SWAP")) {
            const n = try std.fmt.parseInt(u8, token[4..], 10);
            try bytecode.append(0x8F + n); // SWAP1 = 0x90
        }
    }

    return bytecode.toOwnedSlice();
}
