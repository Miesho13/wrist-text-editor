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
    tui.cursor_off();
    tui.clear();

    // const buffer: []const u8 = "test\nsome\nbuffer\nhelllllo\n";
    // col:181 row:50

    var frame_buffer = try tui.FrameBuffer.init(heap, tui.canvas_size().ws_row - 1, tui.canvas_size().ws_col, 0, 0);
    defer frame_buffer.deinit(heap);

    var render_bench: [181*49]u8 = undefined;
    // @memset(&render_bench, 'X');
    frame_buffer.puts(&render_bench, 0, 0);
    // frame_buffer.putc(' ', 20, 20);

    // tui.render_frame_buffer(&frame_buffer);
    var x_pos: u32 = 0;
    var y_pos: u32 = 0;
    frame_buffer.putc('X', x_pos, y_pos);

    while(true) { 
        var timer = try std.time.Timer.start();
        frame_buffer.render();
        const elapsed = timer.read();
        
        frame_buffer.putc(' ', x_pos, y_pos);

        if (x_pos == 181) { 
            y_pos += 1; x_pos = 0;
        }
        x_pos += 1;
        if (x_pos == 181 and y_pos == 49) {
            x_pos = 0; y_pos = 0;
        }

        frame_buffer.putc('X', x_pos, y_pos);

        tui.set_currsor(0, 100);
        print("ns: {}", .{elapsed});
        // std.time.sleep(1_000_000);
    }
}


