const std = @import("std");
const memory = @import("../engine/memory.zig");
const logger = @import("../engine/logger.zig");

pub const BlockHeader = struct {
    timestamp: i64,
    prev_hash: [32]u8,
    merkle_root: [32]u8,
    nonce: u64,
};

pub const GameMove = struct {
    player_choice: []const u8,
    computer_choice: []const u8,
    result: []const u8,
    timestamp: i64,
};

pub const GameBlock = struct {
    header: BlockHeader,
    moves: std.ArrayList(GameMove),
    hash: [32]u8,

    pub fn init(allocator: std.mem.Allocator, prev_hash: [32]u8) !*GameBlock {
        const block = try allocator.create(GameBlock);
        block.* = .{
            .header = .{
                .timestamp = std.time.timestamp(),
                .prev_hash = prev_hash,
                .merkle_root = undefined, // Will be calculated when moves are added
                .nonce = 0,
            },
            .moves = std.ArrayList(GameMove).init(allocator),
            .hash = undefined, // Will be calculated when block is finalized
        };
        return block;
    }

    pub fn deinit(self: *GameBlock) void {
        self.moves.deinit();
    }

    pub fn addMove(self: *GameBlock, player: []const u8, computer: []const u8, result: []const u8) !void {
        const game_move = GameMove{
            .player_choice = player,
            .computer_choice = computer,
            .result = result,
            .timestamp = std.time.timestamp(),
        };
        try self.moves.append(game_move);
        try self.updateMerkleRoot();
    }

    fn updateMerkleRoot(self: *GameBlock) !void {
        var hasher = std.crypto.hash.sha2.Sha256.init(.{});
        for (self.moves.items) |move| {
            hasher.update(move.player_choice);
            hasher.update(move.computer_choice);
            hasher.update(move.result);
        }
        hasher.final(&self.header.merkle_root);
    }

    pub fn finalize(self: *GameBlock) void {
        var hasher = std.crypto.hash.sha2.Sha256.init(.{});
        // Hash the header
        hasher.update(std.mem.asBytes(&self.header.timestamp));
        hasher.update(&self.header.prev_hash);
        hasher.update(&self.header.merkle_root);
        hasher.update(std.mem.asBytes(&self.header.nonce));
        hasher.final(&self.hash);
    }
};
