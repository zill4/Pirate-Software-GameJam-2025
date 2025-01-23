const std = @import("std");
const renderer = @import("renderer.zig");

test "renderer initialization" {
    try renderer.Renderer.init();
}
