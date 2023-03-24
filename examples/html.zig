const std = @import("std");

var stdout = std.io.getStdOut().writer();

const spin = @import("spin");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content = .{ .String = .{
        .buffer = @embedFile("html-example.html"),
        .type = "text/html; charset=utf-8",
    } };
    // Sending response without buffer means we can stream json afterwards
    try spin.response.send(stdout);
}
