const std = @import("std");
const tui = @import("./tui.zig");

const print = std.debug.print;

pub const Editor = struct {
    x: i32,
    y: i32,
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(std.ArrayList(u8)),

    pub fn load(self: *Editor, path: []const u8) void {

    }

    pub fn save(self: *Editor, path: []const u8) !void {

    }
};
