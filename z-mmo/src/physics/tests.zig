const std = @import("std");
const world = @import("world.zig");

test "physics world initialization" {
    try world.World.init();
}
