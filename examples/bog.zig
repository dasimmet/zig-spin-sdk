const std = @import("std");
const bog = @import("bog");

var stdout = std.io.getStdOut().writer();
var stdin = std.io.getStdIn().reader();
var stderr = std.io.getStdErr().writer();

const spin = @import("spin");

pub fn main() !void {
    spin.response.content.Stream.type = "application/json";

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    try spin.request.parse_wagi_env(allocator);

    if (!(spin.request.method == .POST)) {
        try spin.response.send(stdout);
        const obj = .{
            .@"error" = "POST ONLY ENDPOINT\n",
        };
        try spin.json.Print(obj, stdout, true);
    } else {
        // bog from zig example
        var vm = bog.Vm.init(allocator, .{});
        defer vm.deinit();
        try vm.addStdNoIo();
        try vm.addPackage("bogmod", @import("bogmod.zig"));

        const source = try stdin.readAllAlloc(allocator, spin.request.content.Stream.length orelse 9999);

        var mod = bog.compile(vm.gc.gpa, source, "main", &vm.errors) catch |err| {
            return bog_error(&vm, &allocator, err);
        };
        var frame = bog.Vm.Frame{
            .this = bog.Value.Null,
            .mod = &mod,
            .body = mod.main,
            .caller_frame = null,
            .module_frame = undefined,
            .captures = &.{},
            .params = 0,
        };
        errdefer frame.deinit(&vm);

        const res = vm.run(&frame) catch |err| {
            return bog_error(&vm, &allocator, err);
        };

        const obj: Result = switch (res.*) {
            .null => .{},
            .int => .{
                .result = .{ .int = res.bogToZig(i64, frame.ctx(&vm)) catch |err| {
                    return bog_error(&vm, &allocator, err);
                } },
            },
            .num => .{
                .result = .{ .num = res.bogToZig(f64, frame.ctx(&vm)) catch |err| {
                    return bog_error(&vm, &allocator, err);
                } },
            },
            .str => .{
                .result = .{ .str = res.bogToZig([]const u8, frame.ctx(&vm)) catch |err| {
                    return bog_error(&vm, &allocator, err);
                } },
            },
            else => .{},
        };
        try spin.response.send(stdout);

        try spin.json.Print(obj, stdout, true);
    }
}

const Result = struct { result: ?union(enum) {
    int: i64,
    num: f64,
    str: []const u8,
} = null };

pub fn bog_error(vm: *bog.Vm, allocator: *std.mem.Allocator, err: anytype) !void {
    var err_buf = std.ArrayList(u8).init(allocator.*);
    try vm.errors.render(err_buf.writer());

    const obj = .{ .@"error" = .{
        .trace = err_buf.items,
        .name = @errorName(err),
    } };

    spin.response.status = 500;
    try spin.response.send(stdout);
    try spin.json.Print(obj, stderr, true);
    try spin.json.Print(obj, stdout, true);
}
