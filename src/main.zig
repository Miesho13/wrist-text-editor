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
    tui.clear();

    var ed = editor.Editor.init(heap);
    try ed.new_line();
    try ed.putc('q');
    
    tui.puts("===========", 15, 15);
    tui.puts("|", 14, 16);
    tui.puts("|", 26, 16);
    tui.puts("===========", 15, 17);

    tui.puts("XxxxDD", 13, 13);


    tui.set_currsor(0,0);
    tui.canvas_size();
    
    var quit: bool = false;
    while (!quit) { 
        quit = tui.evnet_loop();
    }
}


