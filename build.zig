const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = .{
        .cpu_arch=.wasm32,
        .os_tag=.wasi,
    };
    b.enable_wasmtime = true;

    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode=.ReleaseSafe });

    const app_name = "spinapp";
    var exe: *std.build.CompileStep = b.addExecutable(.{
        .name=app_name,
        .root_source_file = .{.path="src/main.zig"},
        .target=target,
        .optimize=optimize,
    });
    exe.addIncludePath("src/spinsdk/");
    exe.addCSourceFile("src/spinsdk/key-value.c", &.{});
    exe.linkLibC();
    exe.install();

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app in wasmtime");
    run_step.dependOn(&run.step);
}