const std = @import("std");

const builtin = @import("builtin");

const types = @import("types.zig");

const codes = .{
    .escape = "\x1b[",
    .reset = "0;0",
    .black = "0;30",
    .red = "0;31",
    .green = "0;32",
    .yellow = "0;33",
    .blue = "0;34",
    .purple = "0;35",
    .cyan = "0;36",
    .white = "0;37",
};

pub fn colorize(color: std.io.tty.Color, buf: []u8, input: []const u8, target: std.fs.File) ![]const u8 {
    const config = std.io.tty.detectConfig(target);
    var stream = std.io.fixedBufferStream(buf);
    const writer = stream.writer();
    try config.setColor(writer, color);
    try writer.writeAll(input);
    try config.setColor(writer, .white);

    return stream.getWritten();
}

fn wrap(comptime attribute: []const u8, comptime message: []const u8) []const u8 {
    if (builtin.os.tag == .windows) {
        return message;
    } else {
        return codes.escape ++ attribute ++ "m" ++ message ++ codes.escape ++ codes.reset ++ "m";
    }
}

fn runtimeWrap(allocator: std.mem.Allocator, attribute: []const u8, message: []const u8) ![]const u8 {
    if (builtin.os.tag == .windows) {
        return try allocator.dupe(u8, message);
    } else {
        return try std.mem.join(
            allocator,
            "",
            &[_][]const u8{ codes.escape, attribute, "m", message, codes.escape, codes.reset, "m" },
        );
    }
}

pub fn black(comptime message: []const u8) []const u8 {
    return wrap(codes.black, message);
}

pub fn runtimeBlack(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.black, message);
}

pub fn red(comptime message: []const u8) []const u8 {
    return wrap(codes.red, message);
}

pub fn runtimeRed(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.red, message);
}

pub fn green(comptime message: []const u8) []const u8 {
    return wrap(codes.green, message);
}

pub fn runtimeGreen(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.green, message);
}

pub fn yellow(comptime message: []const u8) []const u8 {
    return wrap(codes.yellow, message);
}

pub fn runtimeYellow(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.yellow, message);
}

pub fn blue(comptime message: []const u8) []const u8 {
    return wrap(codes.blue, message);
}

pub fn runtimeBlue(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.blue, message);
}

pub fn purple(comptime message: []const u8) []const u8 {
    return wrap(codes.purple, message);
}

pub fn runtimePurple(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.purple, message);
}

pub fn cyan(comptime message: []const u8) []const u8 {
    return wrap(codes.cyan, message);
}

pub fn runtimeCyan(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.cyan, message);
}

pub fn white(comptime message: []const u8) []const u8 {
    return wrap(codes.white, message);
}

pub fn runtimeWhite(allocator: std.mem.Allocator, message: []const u8) ![]const u8 {
    return try runtimeWrap(allocator, codes.white, message);
}

pub fn duration(buf: *[256]u8, delta: i64) ![]const u8 {
    const code = if (delta < 1000000)
        codes.green
    else if (delta < 5000000)
        codes.yellow
    else
        codes.red;
    return try std.fmt.bufPrint(
        buf,
        "{s}{s}m{}{s}{s}m",
        .{ codes.escape, code, std.fmt.fmtDurationSigned(delta), codes.escape, codes.reset },
    );
}
