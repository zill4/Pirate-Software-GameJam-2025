const std = @import("std");
const chain = @import("chain.zig");

test "blockchain initialization" {
    try chain.Chain.init();
}
