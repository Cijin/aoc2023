const std = @import("std");
const two = @import("02/main.zig");

pub fn main() void {
    two.solve() catch |err| {
        std.debug.print("there was an error {}\n", .{err});
    };
}
