const std = @import("std");

pub fn main() !void {
    // Standard output
    const stdout = std.io.getStdOut().writer();

    // Print message
    try stdout.print("Hello, Voxel World!\n", .{});
}
