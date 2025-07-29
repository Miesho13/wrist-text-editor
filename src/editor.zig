const std = @import("std");
const tui = @import("./tui.zig");
const fs = std.fs;

const print = std.debug.print;

pub const Editor = struct {
    x: i32,
    y: i32,
    allocator: std.mem.Allocator,
    list: std.ArrayList(std.ArrayList(u8)),

    pub fn init(allocator: std.mem.Allocator) Editor {
        return Editor {
            .x    = 0,
            .y    = 0,
            .allocator   = allocator,
            .buffer = std.ArrayList(std.ArrayList(u8)).init(allocator)
        };
    }

    pub fn putc(self: Editor, x: u32, y: u32) void {
        const line_size = self.list.size();

        if (y > line_size) {
                      
        }

    }

    pub fn open(self: *Editor, path: []const u8) !void {
        var cwd = fs.cwd();

        var file = try cwd.openFile(path, 
            fs.File.OpenFlags {.mode = .read_only});

        const buffer = try self.allocator.alloc(u8, @as(usize, (try file.stat()).size));

        _ = try file.read(buffer);
        print("file: {s}", .{buffer});
    }

    pub fn save(self: *Editor, path: []const u8) !void {
        self;
        path;
    }


};
