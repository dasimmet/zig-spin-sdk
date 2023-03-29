const std = @import("std");

var stdout = std.io.getStdOut().writer();

const spin = @import("spin");

const routes = .{
    .{ .route = "/", .file = @embedFile("html-example.html") },
    .{
        .route = "/index.js",
        .file = @embedFile("html-example.js"),
        .type = "application/javascript; charset=utf-8",
    },
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    if (spin.request.path == null) {
        // redirect to main page
        try stdout.writeAll("Location: /\n");
        spin.response.status = 307;
    } else {
        inline for (routes) |r| {
            if (std.mem.eql(u8, spin.request.path.?, r.route)) {
                const t = if (@hasDecl(@TypeOf(r), "type"))
                    r.type
                else
                    "text/html; charset=utf-8";
                spin.response.content = .{ .String = .{
                    .buffer = r.file,
                    .type = t,
                } };
            }
        }
    }
    try spin.response.send(stdout);
}
