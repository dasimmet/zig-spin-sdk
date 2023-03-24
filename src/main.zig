const std = @import("std");
const structs = @import("struct.zig");
const json = @import("json.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");
// const sdk = @import("spinsdk/sdk.zig");

var stdout = std.io.getStdOut().writer();
var stderr = std.io.getStdErr().writer();
var stdin = std.io.getStdIn().reader();

var request = Request{};
var response = Response{};

pub fn main() !void {
    // request.debug = true;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // var store = sdk.KVStore.init(arena.allocator(), "default") catch @panic("WOLOLO");
    // try store.set("WOLOLO","ASDF");
    // const value = try store.get("WOLOLO");
    // try stderr.print("WOLOLO={s}\n", .{value});

    if (request.debug) {
        const src = @src();
        try stderr.print("\nTrace: {s}:{d}:{d}: {s}\n", .{ src.file, src.line, src.column, src.fn_name });
    }

    try request.parse_wagi_env(arena.allocator());

    response.content.Stream.type = "application/json";
    // response.content = .{.String=.{
    //     .buffer = "WOLOLO",
    //     .type = response.content.Stream.type,
    // }};
    // Sending response without buffer means we can stream json afterwards
    try response.send(stdout);

    var env = try std.process.getEnvMap(arena.allocator());
    const obj = .{
        .env = json.Map(@TypeOf(env.hash_map)){ .map = env.hash_map },
        .request = request,
        .response = response,
    };

    try json.Debug(obj, stdout);
}
