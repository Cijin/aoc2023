const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const directions: [8][2]i32 = .{ .{ 0, -1 }, .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, 1 }, .{ 1, 1 }, .{ 1, 0 }, .{ 1, -1 } };

const part = struct {
    num: u32,
    visited: bool,

    fn append(self: *part, n: u8) void {
        self.num = (self.num * 10) + n;
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

    const schematicBoundary: u32 = 200;
    var schematic: [schematicBoundary][schematicBoundary]?*part = .{.{null} ** schematicBoundary} ** schematicBoundary;
    var sum: u32 = 0;
    var symbolBuffer: [schematicBoundary * 10][2]u32 = undefined;
    var symbolIdx: u32 = 0;
    var i: u32 = 0;
    var allocatedParts: [schematicBoundary * 10]?*part = .{null} ** (schematicBoundary * 10);
    var allocatedIdx: u32 = 0;

    defer {
        for (allocatedParts) |p| {
            if (p) |allocatedPart| {
                allocator.destroy(allocatedPart);
            }
        }
    }

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(u16)) catch |err| {
        std.log.err("Failed to read line: {s}\n", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);

        for (line, 0..) |char, j| {
            switch (char) {
                '0'...'9' => {
                    const currentNum: u8 = char - '0';
                    if (j > 0) {
                        if (schematic[i][j - 1]) |s| {
                            s.append(currentNum);
                            schematic[i][j] = s;
                            continue;
                        }
                    }

                    const p = try allocator.create(part);
                    allocatedParts[allocatedIdx] = p;
                    allocatedIdx += 1;

                    p.* = part{ .num = currentNum, .visited = false };
                    schematic[i][j] = p;
                },
                '*' => {
                    symbolBuffer[symbolIdx] = [_]u32{ i, @as(u32, @intCast(j)) };
                    symbolIdx += 1;
                },
                else => continue,
            }
        }
        i += 1;
    }

    const ratio: u8 = 2;
    var gears: [2]u32 = undefined;
    var gearIdx: u8 = 0;
    const maxDirIdx = directions.len - 1;

    for (symbolBuffer) |s| {
        gearIdx = 0;
        gears = .{0} ** 2;

        for (directions, 0..) |dir, dirIdx| {
            if (gearIdx > ratio) {
                break;
            }

            const x: i64 = @intCast(s[0]);
            const y: i64 = @intCast(s[1]);
            const lookupx = dir[0] + x;
            const lookupy = dir[1] + y;

            if ((lookupx < 0) or (lookupx >= schematicBoundary)) {
                continue;
            }

            if ((lookupy < 0) or (lookupy >= schematicBoundary)) {
                continue;
            }

            // TODO: there is a mistake here as some get wrongly visited
            // although, problem is solved. So moving on.
            if (schematic[@intCast(lookupx)][@intCast(lookupy)]) |p| {
                if (!p.isVisited()) {
                    p.markVisited();
                    gears[gearIdx] = p.num;
                    gearIdx += 1;
                }
            }

            if (dirIdx == maxDirIdx and gearIdx != ratio) break;
        }
        sum += gears[0] * gears[1];
    }

    for (schematic) |row| {
        for (row) |e| {
            if (e) |s| {
                print("{d}, {any}\n", .{ s.num, s.visited });
            }
        }
    }

    print("Sum: {d}\n", .{sum});
}
