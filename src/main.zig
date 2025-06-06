const std = @import("std");
const print = std.debug.print;
const heap = std.heap.page_allocator;
const line = std.ArrayList(u8).init(heap);

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
        const idx: usize  = @intCast(self.char_pos);
        const list = self.line_buffer.items[@intCast(self.line_pos)];

        if (idx >= list.items.len) {
            return error.IndexOutOfBounds;
        }
        std.mem.copyForwards(i8, list.items[idx..], list.items[idx + 1..]);
         _ = list.pop();
    }

    pub fn load() void {

    }

    pub fn save() void {
        
    }

    pub fn debug_print(self: *Editor) void {
        for (self.line_buffer.items) |item| {
            print("{s}\n",.{item.items});
        }
    }

};


pub fn main() !void {
    var editor = Editor.init(heap);
    try editor.new_line();

    try editor.putc('A');
    editor.mv_cursor(0, 1);

    try editor.putc('B');
    editor.mv_cursor(0, 1);

    try editor.putc('C');
    editor.mv_cursor(1, 0);
    try editor.new_line();

    try editor.putc('D');
    editor.mv_cursor(1, 0);
    try editor.new_line();

    try editor.putc('Z');
    editor.mv_cursor(0, 1);

    try editor.putc('Y');
    editor.mv_cursor(0, 1);

    try editor.putc('A');
    editor.debug_print();
    
    print("--------------", .{});

    try editor.popc();

    editor.debug_print();
}


