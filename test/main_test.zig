
const std = @import("std");

const print = std.debug.print;

test "hello test" {
    print("Hello test\n", .{ });
}

