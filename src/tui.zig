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
    raw.c_cc[c.VMIN] = 0;
    raw.c_cc[c.VTIME] = 0;
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

pub const FrameBuffer = struct {

    pub fn init(allocator: std.mem.Allocator, height: u32, width: u32, x_frame_pos: u32, y_frame_pos: u32) !FrameBuffer {
        const buffer: []u16 = try allocator.alloc(u16, height * width);
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

    pub fn putc(self: *FrameBuffer, ch: u16, x: u32, y: u32) void {
        self.frame_buffer[y * self.width_ + x] = ch;
    }

    pub fn puts(self: *FrameBuffer, s: []u16, x: u32, y: u32) void {
        std.mem.copyForwards(u16, self.frame_buffer[(y * self.width_ + x)..], s);
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
                set_currsor(0 + self.x_frame_pos_, y + self.y_frame_pos_);
                y += 1; x = 0;
            }
            x += 1;

            if (ch == '\n' or ch == 0) { continue; }
            else { print("{u}", .{@as(u21, ch)}); }
        }
    }

    height_: u32,
    width_: u32,
    x_frame_pos_: u32, 
    y_frame_pos_: u32,
    frame_buffer: []u16,
};

pub const FrameBufferBuilder = struct {
    pub fn putc_mut(buffer: []u16, ch: u16, x: u32, y: u32, width: u64, height: u64) i64 {
        if (y > height) { 
            return -1; 
        }

        buffer[y * width + x] = ch;
        return 1;
    }

    pub fn puts(buffer: []u16, s: []u16, x: u32, y: u32, width: u64, height: u64) i64 {
        if (y > height) { 
            return -1; 
        }
        if (s.len >= width) { 
            return -1; 
        }

        std.mem.copyForwards(u16, buffer[(y * width + x)..], s);
        return @intCast(s.len);
    }
};

pub fn string_to_u16_slice(dest: []u16, str: []const u8) []u16 {

    for (0..str.len) |i| {
        dest[i] = @as(u16, str[i]);
    }

    return dest;
}

pub fn u8_to_u16_slice(dest: []u16, str: []u8) []u16 {

    for (0..str.len) |i| {
        dest[i] = @as(u16, str[i]);
    }

    return dest;
}

pub fn render_frame(buffer: []u16, width: u64, height: u64, 
                    offx: u64, offy: u64) void {
    set_currsor(offx, offy);

    var xprint: u32 = 0; 
    var yprint: u32 = 0; 

    for (buffer) |ch| {
        if (ch != 0 and ch != '\n') {
            print("{u}", .{ch}); 
        }

        xprint += 1;
        if (xprint == width) {
            xprint = 0; 
            yprint += 1;
            if (yprint >= height) {
                break;
            }
            set_currsor(0 + offx, yprint + offy);
        }
    }

}

pub fn get_input() ?u8 {
    var ch: u8 = 0;
    if (c.read(c.STDIN_FILENO, &ch, 1) == 1) {
        return ch;
    }
    return null;
}


pub const Bench = struct {
    pub fn start() !Bench {
        return Bench {
            .tim = try std.time.Timer.start(),
            .fps = 0,
        };
    }

    pub fn stop(self: *Bench) void {
        const elapsed = self.read();
        const float_elapsed: f64 = @floatFromInt(elapsed);
        self.fps = 1_000_000_000 / float_elapsed;
    }

    pub fn read(self: *Bench) u64 {
        return self.tim.read();
    }
    
    pub fn fps_print(self: Bench, x: u32, y: u32) void {
        set_currsor(x, y);
        print("{d:.2}", .{self.fps});
    }

    tim: std.time.Timer = undefined,
    fps: f64 = 0, 
};

