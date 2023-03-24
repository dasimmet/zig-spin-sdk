const std = @import("std");
const builtin = @import("builtin");
const sdk = @import("src/spinsdk/sdk.zig");

const modules = .{
    "tres",
};

pub fn build(b: *std.Build) !void {
    const target = .{
        .cpu_arch = .wasm32,
        .os_tag = .wasi,
    };
    b.enable_wasmtime = true;

    const optimize = b.standardOptimizeOption(.{});

    const app_name = "spinapp";
    var exe: *std.build.CompileStep = b.addExecutable(.{
        .name = app_name,
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    inline for (modules) |mod| {
        const b_module = b.dependency(mod, .{}).module(mod);
        exe.addModule(mod, b_module);
    }

    sdk.link(exe);
    exe.linkLibC();
    exe.install();

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app in wasmtime");
    run_step.dependOn(&run.step);
}
