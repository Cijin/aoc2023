const std = @import("std");
const partOne = @import("01/part1.zig");

pub fn main() void {
    partOne.part_one() catch |err| {
        std.debug.print("there was an error {}\n", .{err});
    };
}
