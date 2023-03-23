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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var store = sdk.KVStore.init(arena.allocator(), "default") catch @panic("WOLOLO");
    try std.json.stringify(store, .{
        .whitespace = std.json.StringifyOptions.Whitespace{},
    }, stderr);
    try stderr.print("\n", .{});
    
    try store.set("WOLOLO","ASDF");
    const value = try store.get("WOLOLO");
    try stderr.print("WOLOLO={s}\n", .{value});

    if (request.debug){
        const src = @src();
        try stderr.print("\nTrace: {s}:{d}:{d}: {s}\n", .{src.file, src.line, src.column, src.fn_name});
    }

    try request.parse_env(arena.allocator());


    if (request.method == structs.Method.POST){
        response.content = try stdin.readAllAlloc(arena.allocator(), request.content_length);
    } else {
        response.content = "WOLOLO\n";
    }
    try response.send(&stdout);
    try stdout.print(@embedFile("index.html"), .{response.content});
}