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

pub fn cursor_off() void {
    print("\x1b[?25l", .{});
}

pub fn cursor_on() void {
    print("\x1b[?25h", .{});
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

pub fn canvas_size() c.winsize {
    var w: c.winsize = undefined; 
    _ = c.ioctl(c.STDOUT_FILENO, c.TIOCGWINSZ, &w);
    return w; 
} 

pub const Key = enum(u8) {
    // Printable ASCII
    A = 'A', B = 'B', C = 'C', D = 'D', E = 'E', F = 'F', G = 'G',
    H = 'H', I = 'I', J = 'J', K = 'K', L = 'L', M = 'M',
    N = 'N', O = 'O', P = 'P', Q = 'Q', R = 'R', S = 'S',
    T = 'T', U = 'U', V = 'V', W = 'W', X = 'X', Y = 'Y', Z = 'Z',

    a = 'a', b = 'b', c = 'c', d = 'd', e = 'e', f = 'f', g = 'g',
    h = 'h', i = 'i', j = 'j', k = 'k', l = 'l', m = 'm',
    n = 'n', o = 'o', p = 'p', q = 'q', r = 'r', s = 's',
    t = 't', u = 'u', v = 'v', w = 'w', x = 'x', y = 'y', z = 'z',

    Num0 = '0', Num1 = '1', Num2 = '2', Num3 = '3', Num4 = '4',
    Num5 = '5', Num6 = '6', Num7 = '7', Num8 = '8', Num9 = '9',

    Space     = ' ',
    Tab       = '\t',
    Enter     = '\r', // On Unix, this is usually \r or \n depending on mode
    Escape    = 27,
    Backspace = 127,

    // Symbols
    Exclamation = '!',
    At          = '@',
    Hash        = '#',
    Dollar      = '$',
    Percent     = '%',
    Caret       = '^',
    Ampersand   = '&',
    Asterisk    = '*',
    LeftParen   = '(',
    RightParen  = ')',
    Minus       = '-',
    Underscore  = '_',
    Plus        = '+',
    Equal       = '=',
    LeftBracket = '[',
    RightBracket= ']',
    LeftBrace   = '{',
    RightBrace  = '}',
    Backslash   = '\\',
    Pipe        = '|',
    Semicolon   = ';',
    Colon       = ':',
    Quote       = '\'',
    DoubleQuote = '"',
    Comma       = ',',
    LessThan    = '<',
    Period      = '.',
    GreaterThan = '>',
    Slash       = '/',
    Question    = '?',
    Backtick    = '`',
    Tilde       = '~',

    // Special (not single-byte ASCII — placeholder values)
    // These will need to be handled via parsing escape sequences
    UpArrow     = 128,
    DownArrow   = 129,
    LeftArrow   = 130,
    RightArrow  = 131,
    F1          = 140,
    F2          = 141,
    F3          = 142,
    F4          = 143,
    F5          = 144,
    F6          = 145,
    F7          = 146,
    F8          = 147,
    F9          = 148,
    F10         = 149,
    F11         = 150,
    F12         = 151,

    Unknown     = 255,
};

var last_press = undefined;
pub fn evnet_loop() bool {
    var ch: u8 = undefined;
    _ = c.read(c.STDIN_FILENO, &ch, 1);
    switch (ch) {
        @intFromEnum(Key.a)...@intFromEnum(Key.z), ' ', '\n', 0x08 => {
            if (ch == 'q') { 
                return true; 
            }
            print("{c}", .{ch});
        },
        else => { },
    }

    return false;
}

pub fn get_key() u8 {
    var ch: u8 = undefined;
    _ = c.read(c.STDIN_FILENO, &ch, 1);
    return ch;
}

pub const FrameBuffer = struct {

    pub fn init(allocator: std.mem.Allocator, height: u32, width: u32, x_frame_pos: u32, y_frame_pos: u32) !FrameBuffer {
        const buffer: []u8 = try allocator.alloc(u8, height * width);
        @memset(buffer, 0);

        return FrameBuffer {
            .height_ = height,
            .width_ = width,
            .x_frame_pos_ = x_frame_pos,
            .y_frame_pos_ = y_frame_pos,
            .frame_buffer = buffer,
        };
    }
    
    pub fn deinit(self: *FrameBuffer, allocator: std.mem.Allocator) void {
        allocator.free(self.frame_buffer);
    }

    pub fn putc(self: *FrameBuffer, ch: u8, x: u32, y: u32) void {
        self.frame_buffer[y * self.width_ + x] = ch;
    }

    pub fn puts(self: *FrameBuffer, s: []u8, x: u32, y: u32) void {
        std.mem.copyForwards(u8, self.frame_buffer[(y * self.width_ + x)..], s);
    }
    
    pub fn get_buffer(self: *FrameBuffer) []u8 {
        return self.frame_buffer;
    }

    // render frame buffer 
    pub fn render(self: *FrameBuffer) void {
        set_currsor(self.x_frame_pos_, self.y_frame_pos_);

        var x: u32 = 0; var y: u32 = 0;
        for (self.frame_buffer) |ch| {
            if (x == self.width_) { 
                y += 1; x = 0;
                set_currsor(0 + self.x_frame_pos_, y + self.y_frame_pos_);
            }
            x += 1;

            if (ch == '\n' or ch == 0) { }
            else { print("{c}", .{ch}); }
        }
    }

    height_: u32,
    width_: u32,
    x_frame_pos_: u32, 
    y_frame_pos_: u32,
    frame_buffer : []u8,
};

pub fn render_frame_buffer(frame_buffer: *FrameBuffer) void {
    for (frame_buffer.get_buffer()) |ch| {
        if (ch == 0) { continue; }
        print("{c}", .{ch});
    }
}

