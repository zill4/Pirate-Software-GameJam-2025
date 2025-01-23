const std = @import("std");
const renderer = @import("renderer.zig");
const logger = @import("logger.zig");

test "renderer initialization" {
    try renderer.Renderer.init();
}

test "logger basic functionality" {
    var test_logger = logger.Logger.init(std.testing.allocator, .debug);
    defer test_logger.deinit();

    try test_logger.info("Test message", "TEST");
    try std.testing.expect(test_logger.entries.items.len == 1);
    try std.testing.expectEqualStrings("Test message", test_logger.entries.items[0].message);
}
