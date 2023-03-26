const std = @import("std");

pub inline fn TPrint(comptime T: type) void {
    @setEvalBranchQuota(100000);
    return TPrintImpl(T, 0);
}

inline fn TPrintImpl(comptime T: type, depth: usize) void {
    const Tinfo = @typeInfo(T);
    printIndent(depth, "Type: {s}\n", .{@typeName(T)});

    switch (Tinfo) {
        .Struct => |Struct| {
            printIndent(depth, "struct_fields:\n", .{});
            inline for (Struct.fields) |f| {
                printIndent(depth + 1, "{s}: \"{any}\"\n", .{ f.name, f.type });
                TPrintImpl(f.type, depth + 2);
            }
            inline for (Struct.decls) |d| {
                const is_pub = if (d.is_pub) "pub " else "";
                printIndent(depth, "Decl: \"{s}{s}\"\n", .{ is_pub, d.name });
            }
        },
        else => {},
    }
}

inline fn printIndent(
    depth: usize,
    comptime fmt: []const u8,
    args: anytype,
) void {
    var i: usize = 0;
    while (i < depth) : (i += 1) {
        std.debug.print("    ", .{});
    }
    std.debug.print(fmt, args);
}
