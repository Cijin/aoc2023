const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const fs = std.fs;

const maxAllowed = enum(u8) {
    red = 12,
    green,
    blue,
};

fn getCount(str: []const u8) !u8 {
    var it = std.mem.splitScalar(u8, str, ' ');
    _ = it.first();
    const count = it.next().?;
    return std.fmt.parseUnsigned(u8, count, 10);
}

fn isValidGame(game: []u8) bool {
    var it = std.mem.splitScalar(u8, game, ' ');
    const count: u8 = std.fmt.parseUnsigned(u8, it.first(), 10) catch {
        return false;
    };
    const color = it.next().?;

    switch (color[0]) {
        'r' => return count <= @intFromEnum(maxAllowed.red),
        'g' => return count <= @intFromEnum(maxAllowed.green),
        'b' => return count <= @intFromEnum(maxAllowed.blue),
        else => return false,
    }
}

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
    var gameIdSum: u32 = 0;
    var gameId: u8 = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        var it = std.mem.splitSequence(u8, line, ": ");
        gameId = try getCount(it.first());

        var gamesIt = std.mem.splitSequence(u8, it.rest(), "; ");
        var isGameValid = true;
        while (gamesIt.peek() != null and isGameValid) {
            const game = gamesIt.next() orelse break;
            if (std.mem.containsAtLeast(u8, game, 1, ",")) {
                var gameIt = std.mem.splitSequence(u8, game, ", ");
                while (gameIt.peek() != null and isGameValid) {
                    if (gameIt.next()) |value| {
                        isGameValid = isValidGame(@constCast(value));
                    }
                }
            } else {
                isGameValid = isValidGame(@constCast(game));
            }
        }
        if (isGameValid) {
            //print("Valid game id {}\n", .{gameId});
            gameIdSum += gameId;
        }
    }

    print("Game Id Sum: {d}\n", .{gameIdSum});
}
