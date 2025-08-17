const std = @import("std");
const testing = std.testing;
const types = @import("types.zig");

const Word = types.Word;
const StorageMap = std.HashMap(Word, Word, std.hash_map.AutoContext(Word), std.hash_map.default_max_load_percentage);
const CacheList = std.ArrayList(Word);

pub const Storage = struct {
    storage: StorageMap,
    cache: CacheList,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Storage {
        return Storage{
            .storage = StorageMap.init(allocator),
            .cache = CacheList.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Storage) void {
        self.storage.deinit();
        self.cache.deinit();
    }

    pub fn store(self: *Storage, key: Word, value: Word) !void {
        try self.storage.put(key, value);
    }

    pub fn load(self: *Storage, key: Word) Word {
        // Check if key is in cache
        for (self.cache.items) |cached_key| {
            if (std.mem.eql(u8, &cached_key, &key)) {
                const value = self.storage.get(key);
                if (value) |v| {
                    return v;
                }
                return types.ZERO_WORD;
            }
        }

        // Key not in cache, add it
        self.cache.append(key) catch unreachable;

        const value = self.storage.get(key);
        if (value) |v| {
            return v;
        }

        return types.ZERO_WORD;
    }
};

test "store and load" {
    var storage = Storage.init(std.testing.allocator);
    defer storage.deinit();

    const key = types.word(&[_]u8{0x01});
    const value = types.word(&[_]u8{0x05});

    try storage.store(key, value);
}

test "try loading from empty storage" {
    var storage = Storage.init(std.testing.allocator);
    defer storage.deinit();

    const key = types.word(&[_]u8{0x01});
    const value = storage.load(key);
    const expected = types.ZERO_WORD;
    try testing.expectEqual(expected, value);
}
