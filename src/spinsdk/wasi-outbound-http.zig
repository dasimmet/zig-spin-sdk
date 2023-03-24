pub const OutboundHTTP = @This();
const std = @import("std");
const c = @import("sdk.zig").c;

pub const Request = struct {
    URL: []const u8,
};

pub const Response = struct {};

pub fn send(req: Request) !Response {
    var spinReq: c.wasi_outbound_http_request_t = undefined;
    var spinRes: c.wasi_outbound_http_response_t = undefined;

    spinReq.method = @as(u8, 0);
    spinReq.uri = c.wasi_outbound_http_uri_t{
        .ptr = req.URL.ptr,
        .len = req.URL.len,
    };
    spinReq.headers = req.Header;
    spinReq.body = req.Body;

    _ = c.wasi_outbound_http_request(&spinReq, &spinRes);

    return Response{};
}
