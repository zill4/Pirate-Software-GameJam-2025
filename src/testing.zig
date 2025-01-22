const std = @import("std");

pub const TestContext = struct {
    name: []const u8,

    pub fn init(name: []const u8) TestContext {
        std.debug.print("\n=== Test: {s} ===\n", .{name});
        return .{ .name = name };
    }

    pub fn done(self: TestContext) void {
        std.debug.print("✅ Passed: {s}\n", .{self.name});
    }

    pub fn step(self: TestContext, name: []const u8) void {
        _ = self; // acknowledge self parameter
        std.debug.print("  → {s}\n", .{name});
    }

    pub fn ok(self: TestContext, name: []const u8) void {
        _ = self; // acknowledge self parameter
        std.debug.print("  ✓ {s}\n", .{name});
    }
};
