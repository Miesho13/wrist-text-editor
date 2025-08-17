const std = @import("std");
const print = std.debug.print;
const unicode = std.unicode;

const GapBuffer = struct {
    data: []u8,
    data_size: usize,
    gap_start: usize,
    gap_end: usize,
    gap_size: usize,

    pub fn init(allocator: std.mem.Allocator, initial_size: usize, gap_size: usize) !GapBuffer {
        const buffer = GapBuffer {
            .data = try allocator.alloc(u8, initial_size),
            .data_size = initial_size,
            .gap_start = 0,
            .gap_end = gap_size,
            .gap_size = gap_size, 
        };
        return buffer;
    }

    pub fn deinit(self: *GapBuffer, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn append(self: *GapBuffer, data: []u8) !void {
        if (data.len >= self.gap_size) {
            return error.GapTooSmall;
        }

        if (self.gap_start + data.len > self.data_size) {
            return error.BufferOverflow;
        }
            
        @memcpy(self.data[self.gap_start..data.len], data);
        self.gap_start += data.len;
    }
};

test "gap_buffer" {
    var gap = try GapBuffer.init(std.heap.page_allocator, 4096, 1024);
    defer gap.deinit(std.heap.page_allocator);

    var data: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    try gap.append(data[0..5]);

    for (gap.data) |val| {

        if (val != 0) {
            print("{}", .{val});
        } 
        else {
            print(" ", .{});
        }
    }

    print("GapBuffer initialized with size: {}\n", .{gap.data.len});
}
