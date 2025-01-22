const std = @import("std");

pub const MemoryError = error{
    OutOfMemory,
    InvalidAlignment,
    AllocationTooLarge,
};

pub const MemoryStats = struct {
    total_allocated: usize,
    total_freed: usize,
    current_usage: usize,
    peak_usage: usize,

    pub fn init() MemoryStats {
        return .{
            .total_allocated = 0,
            .total_freed = 0,
            .current_usage = 0,
            .peak_usage = 0,
        };
    }
};

pub const TrackedAllocator = struct {
    backing_allocator: std.mem.Allocator,
    stats: MemoryStats,

    pub fn init(backing_allocator: std.mem.Allocator) TrackedAllocator {
        return .{
            .backing_allocator = backing_allocator,
            .stats = MemoryStats.init(),
        };
    }

    pub fn allocator(self: *TrackedAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free,
            },
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
        const self = @as(*TrackedAllocator, @ptrCast(@alignCast(ctx)));
        if (self.backing_allocator.rawAlloc(len, ptr_align, ret_addr)) |ptr| {
            self.stats.total_allocated += len;
            self.stats.current_usage += len;
            self.stats.peak_usage = @max(self.stats.peak_usage, self.stats.current_usage);
            return ptr;
        }
        return null;
    }

    fn resize(ctx: *anyopaque, buf: []u8, ptr_align: u8, new_len: usize, ret_addr: usize) bool {
        const self = @as(*TrackedAllocator, @ptrCast(@alignCast(ctx)));
        const old_len = buf.len;

        if (self.backing_allocator.rawResize(buf, ptr_align, new_len, ret_addr)) {
            if (new_len > old_len) {
                self.stats.total_allocated += (new_len - old_len);
                self.stats.current_usage += (new_len - old_len);
            } else {
                self.stats.total_freed += (old_len - new_len);
                self.stats.current_usage -= (old_len - new_len);
            }
            self.stats.peak_usage = @max(self.stats.peak_usage, self.stats.current_usage);
            return true;
        }
        return false;
    }

    fn free(ctx: *anyopaque, buf: []u8, ptr_align: u8, ret_addr: usize) void {
        const self = @as(*TrackedAllocator, @ptrCast(@alignCast(ctx)));
        self.stats.total_freed += buf.len;
        self.stats.current_usage -= buf.len;
        self.backing_allocator.rawFree(buf, ptr_align, ret_addr);
    }
};
