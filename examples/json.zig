const std = @import("std");

var stdout = std.io.getStdOut().writer();

const spin = @import("spin");

// const lua = @import("lua");

const lua = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
});

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    try spin.request.parse_wagi_env(arena.allocator());

    spin.response.content.Stream.type = "application/json";
    try spin.response.send(stdout);

    var env = try std.process.getEnvMap(arena.allocator());

    // const info = @typeInfo(lua);
    // inline for (info.Struct.decls) |decl| {
    //     std.log.debug("Decl: {s}", .{decl.name});
    // }

    var L: *lua.lua_State = undefined;
    lua.luaL_openlibs(L, 1);
    // _ = lua.luaopen_base(L);
    // _ = lua.luaopen_table(L);
    // _ = lua.luaopen_io(L);
    // _ = lua.luaopen_string(L);
    // _ = lua.luaopen_math(L);

    const obj = .{
        .env = env.hash_map,
        .request = spin.request,
        .response = spin.response,
    };

    try spin.json.Print(obj, stdout, true);
}
