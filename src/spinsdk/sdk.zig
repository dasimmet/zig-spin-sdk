pub const SDK = @This();
const std = @import("std");
pub const KVStore = @import("key-value.zig");
pub const OutboundHTTP = @import("wasi-outbound-http.zig");

const c_sources = .{
    "key-value",
    "wasi-outbound-http",
};

pub fn link(exe: *std.Build.CompileStep) void {
    const dir = comptime std.fs.path.dirname(@src().file).?;
    exe.addIncludePath(dir);
    inline for (c_sources) |f| {
        exe.addCSourceFile(dir ++ "/" ++ f ++ ".c", &.{});
    }
}

pub const c = @cImport({
    inline for (c_sources) |f| {
        @cInclude(f ++ ".h");
    }
});
