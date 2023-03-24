const std = @import("std");

var stdout = std.io.getStdOut().writer();

const spin = @import("spin");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    if (spin.request.path != null and !std.mem.eql(u8, spin.request.path.?, "/index.html")) {
        // redirect to main page
        try stdout.writeAll("Location: /index.html\n");
        spin.response.status = 307;
    } else {
        spin.response.content = .{ .String = .{
            .buffer = @embedFile("html-example.html"),
            .type = "text/html; charset=utf-8",
        } };
    }
    try spin.response.send(stdout);
}
