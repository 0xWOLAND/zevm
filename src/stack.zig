const std = @import("std");
const types = @import("types.zig");

const Word = types.Word;
const MAX_STACK_DEPTH = types.MAX_STACK_DEPTH;

pub const Stack = struct {
    items: std.ArrayList(Word),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Stack {
        return Stack{
            .items = std.ArrayList(Word).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Stack) void {
        self.items.deinit();
    }

    pub fn push(self: *Stack, value: Word) !void {
        if (self.items.items.len >= MAX_STACK_DEPTH) {
            return error.StackOverflow;
        }
        try self.items.append(value);
    }

    pub fn pop(self: *Stack) !Word {
        if (self.items.items.len == 0) {
            return error.StackUnderflow;
        }
        return self.items.pop();
    }

    pub fn peek(self: *Stack, index: usize) !Word {
        if (index >= self.items.items.len) {
            return error.StackUnderflow;
        }
        return self.items.items[self.items.items.len - 1 - index];
    }

    pub fn swap(self: *Stack, index: usize) !void {
        if (index >= self.items.items.len) {
            return error.StackUnderflow;
        }
        const top_idx = self.items.items.len - 1;
        const swap_idx = top_idx - index;
        const temp = self.items.items[top_idx];
        self.items.items[top_idx] = self.items.items[swap_idx];
        self.items.items[swap_idx] = temp;
    }

    pub fn dup(self: *Stack, index: usize) !void {
        if (index >= self.items.items.len) {
            return error.StackUnderflow;
        }
        if (self.items.items.len >= MAX_STACK_DEPTH) {
            return error.StackOverflow;
        }
        const value = self.items.items[self.items.items.len - 1 - index];
        try self.items.append(value);
    }
};

test "stack ops" {
    const allocator = std.testing.allocator;

    var stack = Stack.init(allocator);
    defer stack.deinit();

    const val1: Word = 0x01;
    const val2: Word = 0x02;

    try stack.push(val1);
    try stack.push(val2);

    const popped = try stack.pop();
    try std.testing.expectEqual(val2, popped);

    try stack.push(val2);
    try stack.dup(0);

    const top = try stack.peek(0);
    try std.testing.expectEqual(val2, top);
}