const std = @import("std");
const builtin = @import("builtin");
const sdk = @import("src/spinsdk/sdk.zig");

const examples = .{
    .{
        .name = "json",
    },
    .{
        .name = "html",
    },
    .{
        .name = "key-value",
    },
};

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

    const spin_module = b.addModule("spin", .{
        .source_file = .{ .path = "src/spin.zig" },
    });

    inline for (examples) |ex| {
        var exe: *std.build.CompileStep = b.addExecutable(.{
            .name = ex.name,
            .root_source_file = .{ .path = "examples/" ++ ex.name ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });
        inline for (modules) |mod| {
            const b_module = b.dependency(mod, .{}).module(mod);
            exe.addModule(mod, b_module);
            try spin_module.dependencies.put(mod, b_module);
        }
        exe.addModule("spin", spin_module);

        sdk.link(exe);
        exe.linkLibC();
        exe.install();

        const exe_step = b.step(ex.name, "Build and install " ++ ex.name);
        exe_step.dependOn(&exe.install_step.?.step);

        const run = b.addRunArtifact(exe);
        const run_step = b.step("run-" ++ ex.name, "Run the app in wasmtime");
        run_step.dependOn(&run.step);
    }
}
