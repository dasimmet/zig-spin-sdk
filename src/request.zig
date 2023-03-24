pub const Request = @This();
const structs = @import("struct.zig");
const std = @import("std");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();
var stdin = std.io.getStdIn().reader();

client: structs.Client = .{},
content: structs.Content = .{ .Stream = .{} },
debug: bool = false,
method: structs.Method = .GET,
path: ?[]const u8 = null,
query: ?[]const u8 = null,
route: ?[]const u8 = null,
server: structs.Server = .{},
url: ?[]const u8 = null,

// pub fn jsonStringify(self: @This(), options: std.json.StringifyOptions, out_stream: anytype) !void {
// }

pub fn parse_wagi_env(self: *Request, allocator: std.mem.Allocator) !void {
    if (self.debug) {
        try stderr.print("Env:\n", .{});
    }
    const env_map = try std.process.getEnvMap(allocator);

    var env = env_map.iterator();
    while (env.next()) |it| {
        if (self.debug) {
            try stderr.print("{s}={s}\n", .{ it.key_ptr.*, it.value_ptr.* });
        }

        if (std.mem.eql(u8, it.key_ptr.*, "REQUEST_METHOD")) {
            inline for (@typeInfo(structs.Method).Enum.fields) |f| {
                if (std.mem.eql(u8, it.value_ptr.*, f.name)) {
                    self.method = @intToEnum(structs.Method, f.value);
                }
            }
        } else if (std.mem.eql(u8, it.key_ptr.*, "HTTP_CONTENT_LENGTH")) {
            self.content.Stream.length = try std.fmt.parseUnsigned(usize, it.value_ptr.*, 10);
        } else if (std.mem.eql(u8, it.key_ptr.*, "HTTP_CONTENT_TYPE")) {
            self.content.Stream.type = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "SERVER_NAME")) {
            self.server.name = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "SERVER_PORT")) {
            self.server.port = try std.fmt.parseUnsigned(usize, it.value_ptr.*, 10);
        } else if (std.mem.eql(u8, it.key_ptr.*, "REMOTE_ADDR")) {
            self.client.address = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "REMOTE_HOST")) {
            self.client.name = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "QUERY_STRING")) {
            self.query = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "PATH_TRANSLATED")) {
            self.path = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "X_COMPONENT_ROUTE")) {
            self.route = it.value_ptr.*;
        } else if (std.mem.eql(u8, it.key_ptr.*, "X_FULL_URL")) {
            self.url = it.value_ptr.*;
        }
    }
}
