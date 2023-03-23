
pub const Request = @This();
const structs = @import("struct.zig");
const std = @import("std");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();
var stdin = std.io.getStdIn().reader();

method: structs.Method = .GET,
content_length: usize = 0,
debug: bool = false,

pub fn parse_env(self: *Request, allocator: std.mem.Allocator) !void {

    if (self.debug){
        try stderr.print("Env:\n", .{});
    }
    const env_map = try std.process.getEnvMap(allocator);

    var env = env_map.iterator();
    while (env.next()) |it| {
        if (self.debug) {
            try stderr.print("{s}={s}\n", .{it.key_ptr.*, it.value_ptr.*});
        }

        if (std.mem.eql(u8, it.key_ptr.*, "REQUEST_METHOD")) {
            inline for (@typeInfo(structs.Method).Enum.fields) |f| {
                if (std.mem.eql(u8, it.value_ptr.*, f.name)) {
                    self.method = @intToEnum(structs.Method, f.value);
                }
            }
        } else if (std.mem.eql(u8, it.key_ptr.*, "HTTP_CONTENT_LENGTH")) {
            self.content_length = try std.fmt.parseUnsigned(usize, it.value_ptr.*, 10);
        }
    }
}