const std = @import("std");
const three = @import("03/main.zig");

pub fn main() void {
    three.solve() catch |err| {
        std.debug.print("there was an error {}\n", .{err});
    };
}
