const std = @import("std");
const server = @import("server.zig");

test "server initialization" {
    try server.Server.init();
}
