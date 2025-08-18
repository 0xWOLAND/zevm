const std = @import("std");

pub const Memory = struct {
    buf: std.ArrayList(u8),

    pub fn init(a: std.mem.Allocator) Memory {
        return .{ .buf = std.ArrayList(u8).init(a) };
    }
    pub fn deinit(self: *Memory) void {
        self.buf.deinit();
    }

    fn ceilWords(bytes: usize) usize {
        return (bytes + 31) / 32;
    }

    fn memCost(words: usize) usize {
        const m = @as(u128, words);
        const quad = m * m / 512;
        return 3 * words + @as(usize, @intCast(quad));
    }

    fn growTo(self: *Memory, target_len: usize) !void {
        if (self.buf.items.len >= target_len) return;
        const need = target_len - self.buf.items.len;
        try self.buf.ensureTotalCapacity(self.buf.items.len + need);
        var i: usize = 0;
        while (i < need) : (i += 1) self.buf.appendAssumeCapacity(0);
    }

    pub fn access(self: *Memory, off: usize, size: usize) []u8 {
        if (off >= self.buf.items.len) return self.buf.items[0..0];
        const end = @min(self.buf.items.len, off + size);
        return self.buf.items[off..end];
    }

    pub fn load(self: *Memory, off: usize) []u8 {
        return self.access(off, 32);
    }

    pub fn store(self: *Memory, off: usize, val: []const u8) !usize {
        const old_bytes = self.buf.items.len;
        const new_bytes = @max(old_bytes, off + val.len);

        const old_cost = memCost(ceilWords(old_bytes));
        const new_cost = memCost(ceilWords(new_bytes));
        const delta = new_cost - old_cost;

        try self.growTo(new_bytes);
        @memcpy(self.buf.items[off .. off + val.len], val);
        return delta;
    }
};

test "memory" {
    const alloc = std.heap.page_allocator;
    var mem = Memory.init(alloc);
    defer mem.deinit();

    _ = mem.store(0, &.{ 0x01, 0x02, 0x03, 0x04 }) catch unreachable;
    
    try std.testing.expectEqualSlices(u8, mem.buf.items, &.{ 0x01, 0x02, 0x03, 0x04 });
}
