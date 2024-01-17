const std = @import("std");

const jetzig = @import("root").jetzig;
const Request = jetzig.http.Request;
const Data = jetzig.data.Data;
const View = jetzig.views.View;

pub fn index(request: *Request, data: *Data) anyerror!View {
    var object = try data.object();
    try object.put("foo", data.string("hello"));
    return request.render(.ok);
}
