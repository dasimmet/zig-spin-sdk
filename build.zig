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

    const lua = build_static_lua(b, target, optimize);

    // @import("tprint.zig").TPrint(std.Build.Module);

    inline for (examples) |ex| {
        var exe: *std.build.CompileStep = b.addExecutable(.{
            .name = ex.name,
            .root_source_file = .{ .path = "examples/" ++ ex.name ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });
        exe.addIncludePath("libs/lua");
        exe.addObject(lua);
        exe.step.dependOn(&lua.step);

        inline for (modules) |mod| {
            const b_module = b.dependency(mod, .{}).module(mod);
            exe.addModule(mod, b_module);
            try spin_module.dependencies.put(mod, b_module);
        }
        exe.addModule("spin", spin_module);

        sdk.link(exe);
        exe.linkLibC();
        exe.rdynamic = true;
        exe.install();

        const exe_step = b.step(ex.name, "Build and install " ++ ex.name);
        exe_step.dependOn(&exe.install_step.?.step);

        const run = b.addRunArtifact(exe);
        run.addArgs(b.args orelse &.{});
        const run_step = b.step("run-" ++ ex.name, "Run the app in wasmtime");
        run_step.dependOn(&run.step);
    }
}

fn build_static_lua(b: *std.Build, target: anytype, optimize: anytype) *std.Build.CompileStep {
    const lua_dir = "libs/lua/";
    var lib = b.addObject(.{
        .name = "lua",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(lua_dir);
    // lib.linkSystemLibrary("wasi-emulated-signal");

    inline for (.{
        "lapi.c",
        "lauxlib.c",
        "lbaselib.c",
        "lcode.c",
        "lcorolib.c",
        "lctype.c",
        "ldblib.c",
        "ldebug.c",
        // "ldo.c",
        "ldump.c",
        "lfunc.c",
        "lgc.c",
        "linit.c",
        "liolib.c",
        "llex.c",
        "lmathlib.c",
        "lmem.c",
        "loadlib.c",
        "lobject.c",
        "lopcodes.c",
        // "loslib.c",
        "lparser.c",
        "lstate.c",
        "lstring.c",
        "lstrlib.c",
        "ltable.c",
        "ltablib.c",
        // "ltests.c",
        "ltm.c",
        "lua.c",
        "lundump.c",
        "lutf8lib.c",
        "lvm.c",
        "lzio.c",
        // "onelua.c",
    }) |f| {
        lib.addCSourceFile(lua_dir ++ f, &.{
            "-std=gnu99",
            "-D_WASI_EMULATED_SIGNAL",
        });
    }
    return lib;
}
