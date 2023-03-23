const std = @import("std");
const sqlite = @import("sqlite");
const structs = @import("struct.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");
const sdk = @import("spinsdk/sdk.zig");
// const Method = struct_file.Method;

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

    response.content.type = "application/json";
    try response.send(stdout);

    var env = try std.process.getEnvMap(arena.allocator());
    const obj = .{
        .env = structs.JsonMap(@TypeOf(env.hash_map)){ .map = env.hash_map },
        .request = request,
        .response = response,
    };

    // try std.json.stringify(obj, .{
    //     .whitespace = std.json.StringifyOptions.Whitespace{},
    // }, stdout);
    // try stdout.writeByte('\n');

    try structs.jsonDebug(obj, stdout);
}
