const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

/// Custom allocator for game-specific memory management
pub const GameAllocator = struct {
    // Base allocator (usually page allocator)
    base_allocator: Allocator,

    // Stats for tracking
    total_allocated: usize,
    peak_allocated: usize,
    allocation_count: usize,

    pub fn init(base_allocator: Allocator) GameAllocator {
        return .{
            .base_allocator = base_allocator,
            .total_allocated = 0,
            .peak_allocated = 0,
            .allocation_count = 0,
        };
    }

    // Create an allocator interface
    pub fn allocator(self: *GameAllocator) Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free,
            },
        };
    }

    fn alloc(
        ctx: *anyopaque,
        len: usize,
        ptr_align: u8,
        ret_addr: usize,
    ) ?[*]u8 {
        const self = @ptrCast(*GameAllocator, @alignCast(@alignOf(GameAllocator), ctx));

        // Allocate memory using base allocator
        const result = self.base_allocator.rawAlloc(len, ptr_align, ret_addr) orelse return null;

        // Update stats
        self.total_allocated += len;
        self.allocation_count += 1;
        self.peak_allocated = @max(self.peak_allocated, self.total_allocated);

        return result;
    }

    fn resize(
        ctx: *anyopaque,
        buf: []u8,
        buf_align: u8,
        new_len: usize,
        ret_addr: usize,
    ) bool {
        const self = @ptrCast(*GameAllocator, @alignCast(@alignOf(GameAllocator), ctx));

        // Update stats for resizing
        if (new_len > buf.len) {
            self.total_allocated += new_len - buf.len;
            self.peak_allocated = @max(self.peak_allocated, self.total_allocated);
        } else {
            self.total_allocated -= buf.len - new_len;
        }

        return self.base_allocator.rawResize(buf, buf_align, new_len, ret_addr);
    }

    fn free(
        ctx: *anyopaque,
        buf: []u8,
        buf_align: u8,
        ret_addr: usize,
    ) void {
        const self = @ptrCast(*GameAllocator, @alignCast(@alignOf(GameAllocator), ctx));

        // Update stats
        self.total_allocated -= buf.len;
        self.allocation_count -= 1;

        self.base_allocator.rawFree(buf, buf_align, ret_addr);
    }

    // Helper method to print stats
    pub fn printStats(self: *GameAllocator) void {
        std.debug.print(
            \\Memory Stats:
            \\  Total Allocated: {d} bytes
            \\  Peak Allocated: {d} bytes
            \\  Allocation Count: {d}
            \\
        , .{
            self.total_allocated,
            self.peak_allocated,
            self.allocation_count,
        });
    }
};

// Tests
test "GameAllocator basic functionality" {
    var game_allocator = GameAllocator.init(testing.allocator);
    const allocator = game_allocator.allocator();

    // Test allocation
    const memory = try allocator.alloc(u8, 1000);
    defer allocator.free(memory);

    try testing.expect(game_allocator.total_allocated == 1000);
    try testing.expect(game_allocator.allocation_count == 1);
    try testing.expect(game_allocator.peak_allocated == 1000);
}
