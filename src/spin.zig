const std = @import("std");

pub const Request = @import("request.zig");
pub const Response = @import("response.zig");
pub const json = @import("json.zig");
pub const structs = @import("struct.zig");
pub const sdk = @import("spinsdk/sdk.zig");

pub var request = Request{};
pub var response = Response{};
