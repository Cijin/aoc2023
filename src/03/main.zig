const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn solve() !void {
    const file = try fs.cwd().openFile("src/03/file.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinitStatus = gpa.deinit();
        if (deinitStatus == .leak) {
            std.log.err("Memory leak", .{});
        }
    }

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}\n", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        print("{s}\n", .{line});
    }
}
