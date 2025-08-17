const std = @import("std");

pub const Word = [32]u8;
pub const Address = [20]u8;

pub const WORD_SIZE = 32;
pub const ADDRESS_SIZE = 20;
pub const MAX_STACK_DEPTH = 1024;

pub inline fn zero(comptime T: type) T {
    return std.mem.zeroes(T);
}

pub inline fn word(bytes: []const u8) Word {
    var w = zero(Word);
    @memcpy(w[0..@min(bytes.len, WORD_SIZE)], bytes[0..@min(bytes.len, WORD_SIZE)]);
    return w;
}

pub inline fn address(bytes: []const u8) Address {
    var a = zero(Address);
    @memcpy(a[0..@min(bytes.len, ADDRESS_SIZE)], bytes[0..@min(bytes.len, ADDRESS_SIZE)]);
    return a;
}

pub const ZERO_WORD = zero(Word);
pub const ZERO_ADDRESS = zero(Address);

test "types" {
    const w = word(&[_]u8{ 0xAA, 0xBB });
    try std.testing.expectEqual(@as(u8, 0xAA), w[0]);
    try std.testing.expectEqual(@as(u8, 0xBB), w[1]);
    try std.testing.expectEqual(@as(u8, 0x00), w[2]);

    const a = address(&[_]u8{0x42});
    try std.testing.expectEqual(@as(u8, 0x42), a[0]);
    try std.testing.expectEqual(@as(u8, 0x00), a[1]);
}
