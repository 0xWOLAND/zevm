const std = @import("std");
const zevm = @import("zevm");
const EVM = zevm.EVM;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Simple bytecode: PUSH1 0x01, PUSH1 0x02, ADD
    // This pushes 1 and 2 onto the stack, then adds them
    const bytecode = [_]u8{
        0x60, 0x01, // PUSH1 0x01
        0x60, 0x02, // PUSH1 0x02
        0x01, // ADD
        0x00, // STOP
    };

    const gas = 21000;
    const sender: zevm.types.Address = 0xdeadbeef; // Example sender address

    // Create and run the EVM
    var evm = try EVM.init(allocator, &bytecode, gas, 0, &[_]u8{}, sender);
    defer evm.deinit();

    try evm.run();

    // Print the result
    std.debug.print("Stack after execution:\n", .{});
    for (evm.stack.items.items, 0..) |value, i| {
        std.debug.print("  [{d}]: {d} (0x{x})\n", .{ i, value, value });
    }
    std.debug.print("\nGas used: {d}\n", .{21000 - evm.gas});
}
