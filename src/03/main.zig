const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const directions: [8][2]i32 = .{ .{ -1, 0 }, .{ -1, 0 }, .{ 0, -1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ -1, 1 } };

const part = struct {
    num: u32,
    visited: bool,

    fn append(self: *part, i: u8) void {
        self.num = (self.num * 10) + i;
    }

    fn markVisited(self: *part) void {
        self.visited = true;
    }

    fn isVisited(self: part) bool {
        return self.visited;
    }
};

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

    const schematicBoundary: u16 = 10;
    var sum: u32 = 0;
    var schematic: [schematicBoundary][schematicBoundary]?*part = .{.{null} ** 10} ** 10;
    var symbolBuffer: [10][2]u16 = undefined;
    var symbolIdx: u16 = 0;
    var i: u16 = 0;

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(u16)) catch |err| {
        std.log.err("Failed to read line: {s}\n", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);

        for (line, 0..) |char, j| {
            switch (char) {
                '0'...'9' => {
                    const currentNum: u8 = char - '0';
                    if (schematic[i][j]) |s| {
                        s.append(currentNum);
                    } else {
                        var p = part{ .num = currentNum, .visited = false };
                        schematic[i][j] = &p;
                    }
                },
                '*', '$', '+', '#' => {
                    symbolBuffer[symbolIdx] = [_]u16{ i, @as(u16, @intCast(j)) };
                    symbolIdx += 1;
                },
                else => continue,
            }
        }
        i += 1;
    }

    for (schematic) |row| {
        for (row) |e| {
            if (e) |s| {
                print("{d}, {any}\n", .{ s.num, s.visited });
            }
        }
    }

    for (symbolBuffer) |s| {
        for (directions) |dir| {
            const x: i32 = @intCast(s[0]);
            const y: i32 = @intCast(s[1]);
            const lookupx = dir[0] + x;
            const lookupy = dir[1] + y;

            if ((lookupx < 0) or (lookupx >= schematicBoundary)) {
                continue;
            }

            if ((lookupy < 0) or (lookupy >= schematicBoundary)) {
                continue;
            }

            if (schematic[@intCast(lookupx)][@intCast(lookupy)]) |p| {
                if (!p.isVisited()) {
                    sum += p.num;
                    p.markVisited();
                }
            }
        }
    }

    print("Sum: {d}\n", .{sum});
    // for each symbol traverse all directions
    // save numbers at those locations if any
    // should i traverse through numbers or number; 4,6,7 or 467?
}
