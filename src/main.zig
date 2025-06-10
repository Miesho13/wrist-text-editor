const std = @import("std");
const editor = @import("./editor.zig");
const tui = @import("./tui.zig");

const print = std.debug.print;
const heap = std.heap.page_allocator;
const line = std.ArrayList(u8).init(heap);

const c = @cImport({
    @cInclude("termios.h");
    @cInclude("unistd.h");
});

const CLEAR_TERMINAL = "\x1b[2J\x1b[H";


pub fn main() !void {
    tui.enable_raw_mod();
    print("{s}", .{CLEAR_TERMINAL});

    var ed = editor.Editor.init(heap);
    try ed.new_line();
    try ed.putc('q');

    print("\x1B[15;15H", .{});
    ed.debug_print();

    var ch: c_char = undefined;
    while ((c.read(c.STDIN_FILENO, &ch, 1) == 1 ) and (ch != 'q')) { }
}


