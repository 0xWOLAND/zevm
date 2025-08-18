const std = @import("std");
const types = @import("types.zig");

const Word = types.Word;
const Address = types.Address;

pub const Log = struct {
    address: Address,
    topics: std.ArrayList(Word),
    data: std.ArrayList(u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, address: Address) Log {
        return Log{
            .address = address,
            .topics = std.ArrayList(Word).init(allocator),
            .data = std.ArrayList(u8).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Log) void {
        self.topics.deinit();
        self.data.deinit();
    }

    pub fn addTopic(self: *Log, topic: Word) !void {
        try self.topics.append(topic);
    }

    pub fn setData(self: *Log, data: []const u8) !void {
        try self.data.appendSlice(data);
    }
};

test "Log creation and topics" {
    const allocator = std.testing.allocator;

    const address: Address = 0xaa;
    var log = Log.init(allocator, address);
    defer log.deinit();

    const topic1: Word = 0x01;
    const topic2: Word = 0x02;

    try log.addTopic(topic1);
    try log.addTopic(topic2);
    try log.setData(&[_]u8{ 0xff, 0xee, 0xdd });

    try std.testing.expect(log.topics.items.len == 2);
    try std.testing.expect(log.data.items.len == 3);
}
