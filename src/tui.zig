const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("termios.h");
    @cInclude("unistd.h");
    @cInclude("sys/ioctl.h");
    @cInclude("stdio.h");
});

pub fn enable_raw_mod() void {
    var raw: c.struct_termios = undefined;
    _ = c.tcgetattr(c.STDIN_FILENO, &raw);
    raw.c_lflag &= ~(@as(c.tcflag_t, c.ECHO));
    raw.c_lflag &= ~(@as(c.tcflag_t, c.ICANON));
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, &raw);
}

pub fn clear() void {
    print("\x1b[2J\x1b[H", .{});
}

pub fn set_currsor(x: usize, y: usize) void {
    print("\x1B[{};{}H", .{y, x});
}

pub fn puts(str: [] const u8, x: usize, y: usize) void {
    print("\x1B[{};{}H", .{y, x});
    print("{s}", .{str});
}

pub fn canvas_size() void {
    var w: c.winsize = undefined; 
    _ = c.ioctl(c.STDOUT_FILENO, c.TIOCGWINSZ, &w);
    print("col: {} row: {}", .{w.ws_col, w.ws_row});
} 

pub fn evnet_loop() bool {
    var ch: u8 = undefined;
    _ = c.read(c.STDIN_FILENO, &ch, 1);
    switch (ch) {
        'a'...'z', ' ', '\n', 0x08 => {
            if (ch == 'q') { 
                return true; 
            }
            print("{c}", .{ch});
        },
        else => { },
    }
    
    return false;
}
