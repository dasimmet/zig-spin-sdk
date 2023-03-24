const std = @import("std");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();
var stdin = std.io.getStdIn().reader();

const spin = @import("spin");

pub fn main() !void {
    // request.debug = true;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // var store = sdk.KVStore.init(arena.allocator(), "default") catch @panic("WOLOLO");
    // try store.set("WOLOLO","ASDF");
    // const value = try store.get("WOLOLO");
    // try stderr.print("WOLOLO={s}\n", .{value});

    if (spin.request.debug) {
        const src = @src();
        try stderr.print("\nTrace: {s}:{d}:{d}: {s}\n", .{ src.file, src.line, src.column, src.fn_name });
    }

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content.Stream.type = "application/json";
    // response.content = .{.String=.{
    //     .buffer = "WOLOLO",
    //     .type = response.content.Stream.type,
    // }};
    // Sending response without buffer means we can stream json afterwards
    try spin.response.send(stdout);

    var env = try std.process.getEnvMap(arena.allocator());
    const obj = .{
        .env = env.hash_map,
        .request = spin.request,
        .response = spin.response,
    };

    try spin.json.Print(obj, stdout, true);
}
