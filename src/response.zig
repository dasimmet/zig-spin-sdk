pub const Response = @This();
const std = @import("std");
const structs = @import("struct.zig");
status: u32 = 200,
content: structs.Content = .{ .Stream = .{} },

pub fn send(self: *const Response, writer: std.fs.File.Writer) !void {
    try writer.print("Status: {d}\n", .{self.status});
    switch (self.content) {
        .Stream => {
            try writer.print("Content-Type: {s}\n", .{self.content.Stream.type.?});
        },
        .String => {
            try writer.print("Content-Type: {s}\n", .{self.content.String.type.?});
            try writer.print("Content-Length: {d}\n", .{self.content.String.buffer.len});
        },
    }
    try writer.writeByte('\n');
    switch (self.content) {
        .String => {
            try writer.writeAll(self.content.String.buffer);
        },
        else => {},
    }
    if (self.content == structs.Content.String) {}
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
