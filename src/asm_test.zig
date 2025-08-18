const std = @import("std");
const zevm = @import("root.zig");

test "asm" {
    const tests = .{
        .{ "add", &[_]u256{3} },
        .{ "mul", &[_]u256{15} },
        .{ "compare", &[_]u256{0} },
        .{ "xor_cipher", &[_]u256{ 0xe3, 0x48 } },
        .{ "bit_shift", &[_]u256{0x1000} },
        .{ "modexp", &[_]u256{6} },
        .{ "addmod_simple", &[_]u256{1} },
        .{ "address_check", &[_]u256{ 0, 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe } },
        .{ "sha3_hash", &[_]u256{0x6b3dfaec148fb1bb2b066f10ec285e7c9bf402ab32aa78a5d38e34566810cd2} },
        .{ "hash_twice", &[_]u256{ 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470, 0x10ca3eff73ebec87d2394fc58560afeab86dac7a21f5e402ea0a55e5c8a6758f } },
        .{ "sha3_simple", &[_]u256{0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470} },
        .{ "addmod_crypto", &[_]u256{0xc1f940f620808011b3455e91dc9813afffb3b123d4537cf2f63a51eb1208ec50} },
        .{ "merkle_node", &[_]u256{0xace65c8f06f17e2eb0b192ca05d52c4c6ecd94211fb93b27e7b1c4384ef18bdf} },
    };
    
    var dir = try std.fs.cwd().openDir("test/asm", .{});
    defer dir.close();
    
    inline for (tests) |t| {
        const src = try dir.readFileAlloc(std.testing.allocator, t.@"0" ++ ".asm", 1024);
        defer std.testing.allocator.free(src);
        const code = try zevm.assembler.assemble(std.testing.allocator, src);
        defer std.testing.allocator.free(code);
        var evm = try zevm.EVM.init(std.testing.allocator, code, 21000, 0, &[_]u8{}, 0);
        defer evm.deinit();
        try evm.run();
        try std.testing.expectEqualSlices(u256, t.@"1", evm.stack.items.items);
    }
}