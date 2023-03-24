const std = @import("std");

pub const Request = @import("request.zig");
pub const Response = @import("response.zig");
pub const json = @import("json.zig");

pub var request = Request{};
pub var response = Response{};
