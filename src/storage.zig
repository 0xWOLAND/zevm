const std = @import("std");

pub const Key = u256;
pub const Word = u256;
const ZERO: Word = 0;

pub const Storage = struct {
    map:  std.HashMapUnmanaged(Key, ?u32, std.hash_map.AutoContext(Key), 80),
    slab: std.ArrayListUnmanaged(Word),

    pub fn init() Storage {
        return .{ .map = .{}, .slab = .{} };
    }
    
    pub fn deinit(self: *Storage, a: std.mem.Allocator) void {
        self.map.deinit(a);
        self.slab.deinit(a);
    }

    pub fn reserve(self: *Storage, a: std.mem.Allocator, n_keys: usize) !void {
        try self.map.ensureTotalCapacity(a, n_keys);
        try self.slab.ensureTotalCapacity(a, n_keys);
    }

    pub fn load(self: *Storage, a: std.mem.Allocator, key: Key) !struct { warm: bool, value: Word } {
        if (self.map.getPtr(key)) |idx_opt| {
            return .{
                .warm = true,
                .value = if (idx_opt.*) |i| self.slab.items[i] else ZERO,
            };
        }
        const e = try self.map.getOrPut(a, key);
        e.value_ptr.* = null;
        return .{ .warm = false, .value = ZERO };
    }

    pub fn store(self: *Storage, a: std.mem.Allocator, key: Key, val: Word) !bool {
        const e = try self.map.getOrPut(a, key);
        const warm = e.found_existing;
        
        if (e.found_existing) {
            if (e.value_ptr.*) |i| {
                self.slab.items[i] = val;
            } else {
                const i: u32 = @intCast(self.slab.items.len);
                try self.slab.append(a, val);
                e.value_ptr.* = i;
            }
        } else {
            const i: u32 = @intCast(self.slab.items.len);
            try self.slab.append(a, val);
            e.value_ptr.* = i;
        }
        return warm;
    }

    pub fn resetTx(self: *Storage) void {
        self.map.clearRetainingCapacity();
        self.slab.clearRetainingCapacity();
    }
};

test "store and load" {
    const testing = std.testing;
    var storage = Storage.init();
    defer storage.deinit(testing.allocator);

    const key: Key = 0x01;
    const value: Word = 0x05;

    _ = try storage.store(testing.allocator, key, value);
    const result = try storage.load(testing.allocator, key);
    try testing.expectEqual(value, result.value);
}

test "warm/cold tracking" {
    const testing = std.testing;
    var storage = Storage.init();
    defer storage.deinit(testing.allocator);

    const key: Key = 0x42;
    const value: Word = 0x1a4;
    
    const result1 = try storage.load(testing.allocator, key);
    try testing.expect(!result1.warm);
    try testing.expectEqual(ZERO, result1.value);
    
    const result2 = try storage.load(testing.allocator, key);
    try testing.expect(result2.warm);
    
    const warm = try storage.store(testing.allocator, key, value);
    try testing.expect(warm);
    
    const result3 = try storage.load(testing.allocator, key);
    try testing.expect(result3.warm);
    try testing.expectEqual(value, result3.value);
    
    storage.resetTx();
    const result4 = try storage.load(testing.allocator, key);
    try testing.expect(!result4.warm);
    try testing.expectEqual(ZERO, result4.value);
}

test "empty storage" {
    const testing = std.testing;
    var storage = Storage.init();
    defer storage.deinit(testing.allocator);

    const key: Key = 0x01;
    const result = try storage.load(testing.allocator, key);
    try testing.expectEqual(ZERO, result.value);
}