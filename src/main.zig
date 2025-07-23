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

const app = editor.init(heap);

pub fn ed() !bool {
    var bench = try tui.Bench.start();
    
    const key = tui.get_input();

    bench.stop();
    bench.fps_print(0, 100);

    if (key == 'q') { return false; }
    return true;
}


pub fn main() !void {
    tui.enable_raw_mod();
    tui.cursor_off();
    defer tui.cursor_on();
    tui.clear();

    while(try ed()) { }
}


