const std = @import("std");
const memory = @import("memory.zig");

pub fn main() !void {
    var mem = memory.Memory.init(std.heap.page_allocator);
    defer mem.deinit();
}