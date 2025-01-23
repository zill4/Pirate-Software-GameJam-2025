const std = @import("std");
const block = @import("block.zig");

test "block creation and moves" {
    var prev_hash: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash("test", &prev_hash, .{});

    var test_block = try block.GameBlock.init(std.testing.allocator, prev_hash);
    defer {
        test_block.deinit();
        std.testing.allocator.destroy(test_block);
    }

    try test_block.addMove("rock", "paper", "lose");
    try std.testing.expect(test_block.moves.items.len == 1);

    test_block.finalize();
    // Verify hash is not zero
    var zero_hash: [32]u8 = [_]u8{0} ** 32;
    try std.testing.expect(!std.mem.eql(u8, &test_block.hash, &zero_hash));
}
