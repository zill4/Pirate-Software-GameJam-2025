const std = @import("std");

pub const GameAllocator = struct {
    arena: std.heap.ArenaAllocator,

    pub fn init() GameAllocator {
        return GameAllocator{
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };
    }

    pub fn deinit(self: *GameAllocator) void {
        self.arena.deinit();
    }

    pub fn allocator(self: *GameAllocator) std.mem.Allocator {
        return self.arena.allocator();
    }
};
