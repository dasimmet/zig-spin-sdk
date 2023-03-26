const std = @import("std");
const json = @import("json.zig");

pub const Method = enum {
    GET,
    POST,
    pub fn jsonStringify(self: @This(), options: std.json.StringifyOptions, out_stream: anytype) !void {
        return json.stringifyEnum(self, options, out_stream);
    }
};

pub const Content = union(enum) {
    Stream: struct {
        type: ?[]const u8 = null,
        length: ?usize = null,
    },
    String: struct {
        buffer: []const u8,
        type: ?[]const u8 = null,
    },
};

pub const Server = struct {
    name: ?[]const u8 = null,
    port: ?u16 = null,
};

pub const Client = struct {
    name: ?[]const u8 = null,
    address: ?[]const u8 = null,
    port: ?u32 = null,
};
