const std = @import("std");

pub fn main() !void {
    std.debug.print("MMO Engine Starting...\n", .{});
}

test "basic test" {
    try std.testing.expectEqual(true, true);
}
