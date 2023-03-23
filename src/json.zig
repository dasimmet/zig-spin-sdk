const std = @import("std");

pub fn Debug(obj: anytype, writer: anytype) !void {
    try std.json.stringify(obj, .{
        .whitespace = std.json.StringifyOptions.Whitespace{},
    }, writer);
    try writer.writeByte('\n');
}

pub fn Map(comptime T: type) type {
    return struct {
        map: T,

        pub fn jsonStringify(self: @This(), options: std.json.StringifyOptions, out_stream: anytype) !void {
            return stringifyMap(self.map, options, out_stream);
        }
    };
}

pub fn stringifyMap(self: anytype, options: std.json.StringifyOptions, out_stream: anytype) !void {
    var env = self.iterator();
    try out_stream.writeByte('{');
    var child_options = options;
    if (child_options.whitespace) |*child_whitespace| {
        child_whitespace.indent_level += 1;
    }
    var field_output = false;
    while (env.next()) |it| {
        if (!field_output) {
            field_output = true;
        } else {
            try out_stream.writeByte(',');
        }
        if (child_options.whitespace) |child_whitespace| {
            try child_whitespace.outputIndent(out_stream);
        }
        try std.json.encodeJsonString(it.key_ptr.*, options, out_stream);
        try out_stream.writeByte(':');
        try std.json.stringify(it.value_ptr.*, child_options, out_stream);
    }
    if (field_output) {
        if (options.whitespace) |whitespace| {
            try whitespace.outputIndent(out_stream);
        }
    }
    try out_stream.writeByte('}');
}

pub fn stringifyEnum(self: anytype, options: std.json.StringifyOptions, out_stream: anytype) !void {
    _ = options;
    inline for (@typeInfo(@TypeOf(self)).Enum.fields) |f| {
        if (f.value == @enumToInt(self)) return out_stream.writeAll("\"" ++ f.name ++ "\"");
    }
    @panic("Enum Value not found for: " ++ @typeName(@This()));
}
