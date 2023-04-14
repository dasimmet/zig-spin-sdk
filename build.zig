const std = @import("std");
const builtin = @import("builtin");
const sdk = @import("src/spinsdk/sdk.zig");

const examples = .{
    .{
        .name = "html",
    },
    .{
        .name = "bog",
        .modules = .{
            "tres",
        },
    },
    .{
        .name = "json",
        .link_sdk = true,
    },
    .{
        .name = "key-value",
        .link_sdk = true,
    },
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
    const bog_module = b.addModule("bog", .{
        .source_file = .{ .path = "libs/bog/src/bog.zig" },
    });

    // bog options
    const lib_options = b.addOptions();
    lib_options.addOption(
        bool,
        "no_std",
        b.option(bool, "NO_ADD_STD", "Do not export bog_Vm_addStd to reduce binary size") orelse false,
    );
    lib_options.addOption(
        bool,
        "no_std_no_io",
        b.option(bool, "NO_ADD_STD_NO_IO", "Do not export bog_Vm_addStd to reduce binary size") orelse false,
    );
    // bog options

    const test_step = b.step("test", "Run tests");

    inline for (examples) |ex| {
        const source = .{ .path = "examples/" ++ ex.name ++ ".zig" };

        var exe: *std.build.CompileStep = b.addExecutable(.{
            .name = ex.name,
            .root_source_file = source,
            .target = target,
            .optimize = optimize,
        });
        if (@hasField(@TypeOf(ex), "modules")) {
            inline for (ex.modules) |mod| {
                const b_module = b.dependency(mod, .{}).module(mod);
                exe.addModule(mod, b_module);
                try spin_module.dependencies.put(mod, b_module);
            }
        }
        exe.addModule("spin", spin_module);
        exe.addModule("bog", bog_module);
        exe.addOptions("build_options", lib_options);

        if (@hasField(@TypeOf(ex), "link_sdk") and ex.link_sdk) {
            sdk.link(exe);
            exe.linkLibC();
        }
        exe.rdynamic = true;
        b.installArtifact(exe);

        const exe_step = b.step(ex.name, "Build and install " ++ ex.name);
        exe_step.dependOn(&b.addInstallArtifact(exe).step);

        const run = b.addRunArtifact(exe);
        run.addArgs(b.args orelse &.{});
        const run_step = b.step("run-" ++ ex.name, "Run the app in wasmtime");
        run_step.dependOn(&run.step);

        const exe_test = b.addTest(.{
            .name = ex.name,
            .root_source_file = source,
        });

        test_step.dependOn(&exe_test.step);
    }
}
