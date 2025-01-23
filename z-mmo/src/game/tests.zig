const std = @import("std");
const state = @import("state.zig");

test "game state initialization" {
    try state.GameState.init();
}
