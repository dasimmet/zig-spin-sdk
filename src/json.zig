const std = @import("std");
const tres = @import("tres");

pub fn Print(obj: anytype, writer: anytype, whitespace: bool) !void {
    const space = if (whitespace) std.json.StringifyOptions.Whitespace{} else null;

    try tres.stringify(obj, .{
        .whitespace = space,
    }, writer);
    try writer.writeByte('\n');
}

pub fn stringifyEnum(self: anytype, options: std.json.StringifyOptions, out_stream: anytype) !void {
    _ = options;
    inline for (@typeInfo(@TypeOf(self)).Enum.fields) |f| {
        if (f.value == @enumToInt(self)) return out_stream.writeAll("\"" ++ f.name ++ "\"");
    }
    @panic("Enum Value not found for: " ++ @typeName(@This()));
}
