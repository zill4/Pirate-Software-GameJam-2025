const std = @import("std");
const build_options = @import("build_options");

pub fn main() !void {
    if (build_options.enable_logging) {
        std.debug.print("Logging enabled\n", .{});
    }

    if (build_options.enable_profiling) {
        std.debug.print("Profiling enabled\n", .{});
    }

    std.debug.print("MMO Engine Starting...\n", .{});
}

test "basic test" {
    try std.testing.expectEqual(true, true);
}
