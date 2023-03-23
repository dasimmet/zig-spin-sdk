
pub const SDK = @This();
const std = @import("std");

pub const c = @cImport({
    @cInclude("key-value.h");
});

pub const KVStore = struct{
    name: []u8,
    ptr: usize,
    pub fn init(alloc: std.mem.Allocator, name: []const u8) !*@This() {
        var self: *@This() = try alloc.create(@This());
        self.name = try alloc.alloc(u8, name.len);
        std.mem.copy(u8, self.name, name);
        
        var c_name : c.key_value_string_t = .{
            .ptr = self.name.ptr,
            .len = self.name.len,
        };
    
        var result: c.key_value_expected_store_error_t = undefined;
        c.key_value_open(&c_name, &result);

        if (result.is_err){
            return error.URMOM;
        }
        self.ptr = @as(usize, result.val.ok);
        return self;
    }
    pub fn get(self: *@This(), key: []const u8) ![]u8 {

        var c_key : c.key_value_string_t = .{
            .ptr = @constCast(key.ptr),
            .len = key.len,
        };

        var result: c.key_value_expected_list_u8_error_t = undefined;
        c.key_value_get(@as(c.key_value_store_t, self.ptr), &c_key, &result);

        if (result.is_err){
            return error.URMOM2;
        }
        var resultSlice: []u8 = undefined;
        resultSlice.ptr = result.val.ok.ptr;
        resultSlice.len = result.val.ok.len;
        return resultSlice;
    }

    pub fn set(self: *@This(), key: []const u8, value: []const u8) !void {
        
        var c_key : c.key_value_string_t = .{
            .ptr = @constCast(key.ptr),
            .len = key.len,
        };

        var c_value : c.key_value_list_u8_t = .{
            .ptr = @constCast(value.ptr),
            .len = value.len,
        };

        var result: c.key_value_expected_unit_error_t = undefined;
        c.key_value_set(@as(c.key_value_store_t, self.ptr), &c_key, &c_value, &result);

        if (result.is_err){
            return error.URMOM3;
        }
    }
};