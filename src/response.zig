pub const Response = @This();
const std = @import("std");
status: u32 = 200,
content: Content = .{},

pub fn send(self: *const Response, writer: std.fs.File.Writer) !void {
    try writer.print("Content-Type: {s}\n", .{self.content.type});
    if (self.content.length != null) {
        try writer.print("Content-Length: {d}\n", .{self.content.length.?});
    }
    try writer.print("Status: {d}\n\n", .{self.status});
    try writer.writeAll(self.content.buffer);
}

pub const HTTPError = struct {
    msg: []const u8 = "",
    status: u32 = 404,

    pub fn send(writer: *std.fs.File.Writer, self: HTTPError) !void {
        const h = Response{
            .content_type = "text/plain",
            .status = self.status,
        };
        try h.send(writer);

        if (self.msg.len > 0) {
            try writer.print("Message: {d}\n", .{self.msg});
        }
    }
};

pub const Content = struct {
    buffer: []const u8 = &.{},
    type: []const u8 = "text/html; charset=UTF-8",
    length: ?usize = null,

    pub fn set(self: *@This(), value: []const u8) void {
        self.buffer = value;
        self.length = value.len;
    }
};
