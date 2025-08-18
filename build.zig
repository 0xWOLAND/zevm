const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zevm",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const asm_tests = b.addTest(.{
        .root_source_file = b.path("src/asm_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const test_asm_step = b.step("test-asm", "Test asm files");
    test_asm_step.dependOn(&b.addRunArtifact(asm_tests).step);

    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
}