
pub const Response = @This();
const std = @import("std");

content_type: []const u8 = "text/html; charset=UTF-8",
status: u32 = 200,
content: []const u8 = "",

pub fn send(self: *const Response, writer: *std.fs.File.Writer) !void {
    try writer.print("Content-Type: {s}\n", .{self.content_type});
    try writer.print("Status: {d}\n\n", .{self.status});
}


pub const HTTPError = struct{
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
