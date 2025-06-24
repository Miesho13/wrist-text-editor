const std = @import("std");
const tui = @import("../src/tui.zig");
const print = std.debug.print;

test "Helo test" {
    try std.testing.expect('E' == @intFromEnum(tui.Key.E));
}

