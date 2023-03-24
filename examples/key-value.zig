const std = @import("std");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();

const spin = @import("spin");

pub fn main() !void {
    spin.request.debug = true;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var store = spin.sdk.KVStore.init(arena.allocator(), "default") catch @panic("WOLOLO");

    _ = store.get("WOLOLO") catch {
        try store.set("WOLOLO", "ASDF");
    };

    const value = try store.get("WOLOLO");

    if (spin.request.debug) {
        const src = @src();
        try stderr.print("\nTrace: {s}:{d}:{d}: {s}\n", .{ src.file, src.line, src.column, src.fn_name });
    }

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content.Stream.type = "application/json";
    // Sending response without buffer means we can stream json afterwards
    try spin.response.send(stdout);

    const obj = .{
        .WOLOLO = value,
    };

    try spin.json.Print(obj, stdout, true);
}
