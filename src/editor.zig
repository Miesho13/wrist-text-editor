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
            .list = std.ArrayList(std.ArrayList(u8)).init(allocator)
        };
    }

    fn new_line(self: *Editor, line: u32) !void {
        const inner = std.ArrayList(u8).init(self.allocator);

        if (self.list.items.len > line) {
            try self.list.insert(line, inner);
        } else {
            try self.list.append(inner);
        }
    }

    pub fn putc(self: *Editor, ch: u8, x: u32, y: u32) !void {
        const line_size = self.list.capacity;

        if (y > line_size) {
            _ = try new_line(y);
        }

        var line = self.list[y];
        line[x] = ch;
    }

    pub fn puts(self: *Editor, s: []u8, x: u32, y: u32) !void {
        if (y >= self.list.items.len) {
            try self.new_line(y);
        }

        var line = &self.list.items[y];
        var offset = x;
        for (s) |ch| {
            if (offset >= line.items.len) {
                try line.append(ch);
            } else {
                line.items[offset] = ch;
            }
            offset += 1;
        }
    }

    pub fn println(self: *Editor, s: []u8, line: u32) !void {
        try self.puts(s, 0, line);
    }

    pub fn open(self: *Editor, path: []const u8) !void {
        var cwd = fs.cwd();

        var file = try cwd.openFile(path, 
            fs.File.OpenFlags {.mode = .read_only});

        const list = try self.allocator.alloc(u8, @as(usize, (try file.stat()).size));

        _ = try file.read(list);
        var lines = std.mem.splitScalar(u8, list, '\n');

        var line_number: u32 = 0;
        while (lines.next()) |line| {
            try self.println(@constCast(line), line_number);
            line_number += 1;
        }
    }

    pub fn get_frame_buffer(self: *Editor, frame_buffer: []u16, 
        width: u64, height: u64) !void {
        var line_u16: [1024]u16 = undefined;
        @memset(&line_u16, 0);

        var line_idx: u32 = 0;
        for (self.list.items) |line| {
            _ = tui.u8_to_u16_slice(&line_u16, line.items);
            _ = tui.FrameBufferBuilder.puts(frame_buffer, line_u16[0..line.items.len], 0, line_idx, width, height);
            line_idx += 1;
        }
    }

    pub fn save(self: *Editor, path: []const u8) !void {
        self;
        path;
    }


};
