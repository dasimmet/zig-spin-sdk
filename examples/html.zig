const std = @import("std");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();
var stdin = std.io.getStdIn().reader();

const spin = @import("spin");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content = .{ .String = .{
        .buffer = @embedFile("html-example.html"),
        .type = spin.response.content.Stream.type,
    } };
    // Sending response without buffer means we can stream json afterwards
    try spin.response.send(stdout);
}
