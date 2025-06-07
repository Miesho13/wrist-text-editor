const std = @import("std");
const print = std.debug.print;
const heap = std.heap.page_allocator;
const line = std.ArrayList(u8).init(heap);
const os = std.os;
const termios = std.os.termios;

const Editor = struct {
    line_pos: i32,
    char_pos: i32,
    allocator: std.mem.Allocator,
    line_buffer: std.ArrayList(std.ArrayList(u8)),

    pub fn init(allocator : std.mem.Allocator) Editor {
        return Editor {
            .line_pos    = 0,
            .char_pos    = 0,
            .allocator   = allocator,
            .line_buffer = std.ArrayList(std.ArrayList(u8)).init(allocator)
        };
    }

    pub fn putc(self: *Editor, ch: u8) !void {
        try self.line_buffer
            .items[@intCast(self.line_pos)].insert(@intCast(self.char_pos), ch);
    }

    pub fn new_line(self: *Editor) !void {
        if (self.line_pos == self.line_buffer.items.len) {
            try self.line_buffer.append(std.ArrayList(u8).init(self.allocator));
        }
        try self.line_buffer
            .insert(@intCast(self.line_pos), std.ArrayList(u8).init(self.allocator));
    }

    pub fn mv_cursor(self: *Editor, line_pos: i32, char_pos: i32) void {
        self.line_pos += line_pos;
        if (self.line_pos < 0) {
            self.line_pos = 0;
        } else if (self.line_pos > self.line_buffer.items.len) {
            self.line_pos = @intCast(self.line_buffer.items.len);
        }

        self.char_pos += char_pos;
        if (self.char_pos < 0) {
            self.char_pos = 0;
        } else if (self.char_pos > self.line_buffer.items[@intCast(self.line_pos)].items.len) {
            self.char_pos = @intCast(self.line_buffer.items[@intCast(self.line_pos)].items.len);
        }
    }

    pub fn popc(self: *Editor) !void {
        _ = self.line_buffer.items[@intCast(self.line_pos)].orderedRemove(@intCast(self.char_pos));
    }

    pub fn load() void {

    }

    pub fn save(self: *Editor, path: []const u8) !void {
        var file = try std.fs.cwd().createFile(path, .{
            .truncate = true,
        });
        defer file.close();

        for (self.line_buffer.items) |itm| {
            try file.writeAll(itm.items);
        }
    }

    pub fn debug_print(self: *Editor) void {
        for (self.line_buffer.items) |item| {
            print("{s}\n",.{item.items});
        }
    }

};

pub fn enableRawMode() !termios.Termios {
    var original = try termios.tcgetattr(os.STDIN_FILENO);
    var raw = original;

    raw.lflag &= ~termios.ICANON; // disable canonical mode
    raw.lflag &= ~termios.ECHO;   // disable echo
    // raw.lflag &= ~termios.ISIG;   // disable Ctrl-C and Ctrl-Z
    raw.iflag &= ~(termios.IXON | termios.ICRNL); // disable Ctrl-S/Q and CR-to-NL
    raw.c_oflag &= ~termios.OPOST; // disable output processing
    raw.c_cc[termios.VMIN] = 1;
    raw.c_cc[termios.VTIME] = 0;

    try termios.tcsetattr(os.STDIN_FILENO, termios.TCSAFLUSH, &raw);

    return original;
}

pub fn disableRawMode(original: termios.Termios) void {
    _ = termios.tcsetattr(os.STDIN_FILENO, termios.TCSAFLUSH, &original);
}


pub fn main() !void {
    enableRawMode();
    disableRawMode();
    print("\x1b[2J", .{});
    print("\x1b[H", .{});
}


