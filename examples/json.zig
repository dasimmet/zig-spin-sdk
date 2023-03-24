const std = @import("std");

var stdout = std.io.getStdOut().writer();

const spin = @import("spin");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content.Stream.type = "application/json";
    try spin.response.send(stdout);

    var env = try std.process.getEnvMap(arena.allocator());
    const obj = .{
        .env = env.hash_map,
        .request = spin.request,
        .response = spin.response,
    };

    try spin.json.Print(obj, stdout, true);
}
