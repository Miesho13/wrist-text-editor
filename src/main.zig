const std = @import("std");
const print = std.debug.print;
const heap = std.heap.page_allocator;
const line = std.ArrayList(u8).init(heap);

const c = @cImport({
    @cInclude("termios.h");
    @cInclude("unistd.h");
});


const CLEAR_TERMINAL = "\x1b[2J\x1b[H";

const Editor = struct {
    x: i32,
    y: i32,
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(std.ArrayList(u8)),

    pub fn init(allocator : std.mem.Allocator) Editor {
        return Editor {
            .x    = 0,
            .y    = 0,
            .allocator   = allocator,
            .buffer = std.ArrayList(std.ArrayList(u8)).init(allocator)
        };
    }

    pub fn putc(self: *Editor, ch: u8) !void {
        try self.buffer
            .items[@intCast(self.x)].insert(@intCast(self.y), ch);
    }

    pub fn new_line(self: *Editor) !void {
        if (self.x == self.buffer.items.len) {
            try self.buffer.append(std.ArrayList(u8).init(self.allocator));
        }
        try self.buffer
            .insert(@intCast(self.x), std.ArrayList(u8).init(self.allocator));
    }

    pub fn mv_cursor(self: *Editor, x: i32, y: i32) void {
        self.x += x;
        if (self.x < 0) {
            self.x = 0;
        } else if (self.x > self.buffer.items.len) {
            self.x = @intCast(self.buffer.items.len);
        }

        self.y += y;
        if (self.y < 0) {
            self.y = 0;
        } else if (self.y > self.buffer.items[@intCast(self.x)].items.len) {
            self.y = @intCast(self.buffer.items[@intCast(self.x)].items.len);
        }
    }

    pub fn popc(self: *Editor) !void {
        _ = self.buffer.items[@intCast(self.x)].orderedRemove(@intCast(self.y));
    }

    pub fn load() void {

    }

    pub fn save(self: *Editor, path: []const u8) !void {
        var file = try std.fs.cwd().createFile(path, .{
            .truncate = true,
        });
        defer file.close();

        for (self.buffer.items) |itm| {
            try file.writeAll(itm.items);
        }
    }

    pub fn debug_print(self: *Editor) void {
        for (self.buffer.items) |item| {
            print("{s}\n",.{item.items});
        }
    }

};

pub fn enable_raw_mod() void {
    var raw: c.struct_termios = undefined;
    _ = c.tcgetattr(c.STDIN_FILENO, &raw);

    raw.c_lflag &= ~(@as(c.tcflag_t, c.ECHO));
    raw.c_lflag &= ~(@as(c.tcflag_t, c.ICANON));

    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, &raw);
}

fn disableRawMode(original: *const c.struct_termios) void {
    _ = c.tcsetattr(0, c.TCSAFLUSH, original);
}

pub fn main() !void {
    enable_raw_mod();
    var ch: c_char = undefined;
    print("{s}", .{CLEAR_TERMINAL});

    while ((c.read(c.STDIN_FILENO, &ch, 1) == 1 ) and (ch != 'q')) { }
}


