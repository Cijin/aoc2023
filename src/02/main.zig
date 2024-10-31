const std = @import("std");
const print = std.debug.print;
const fs = std.fs;

pub fn solve() !void {
    const file = try fs.cwd().openFile("src/02/file.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinitStatus = gpa.deinit();
        if (deinitStatus == .leak) {
            std.log.err("Memory leak", .{});
        }
    }

    const allocator = gpa.allocator();
    var list = std.ArrayList(u8).init(allocator);
    defer {
        list.deinit();
    }

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        for (line) |byte| {
            switch (byte) {
                '0'...'9' => try list.append(byte - '0'),
                else => continue,
            }
        }
    }

    for (list.items, 0..) |item, i| {
        print("{d}:{d}\n", .{ i, item });
    }
}
