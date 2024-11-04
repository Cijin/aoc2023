const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const fs = std.fs;

const colors = enum(u8) {
    red,
    green,
    blue,
};

const ColorCount = struct { count: u32, color: colors };

const ColorError = error{
    NotFound,
};

fn getColorCount(game: []const u8) !ColorCount {
    var it = std.mem.splitScalar(u8, game, ' ');
    const count: u32 = try std.fmt.parseUnsigned(u8, it.first(), 10);
    if (it.next()) |color| {
        switch (color[0]) {
            'r' => return .{ .count = count, .color = colors.red },
            'g' => return .{ .count = count, .color = colors.green },
            'b' => return .{ .count = count, .color = colors.blue },
            else => return ColorError.NotFound,
        }
    }

    return ColorError.NotFound;
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
    var gamePowerSum: u32 = 0;
    var colorCount: ColorCount = undefined;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        var it = std.mem.splitSequence(u8, line, ": ");
        var maxRed: u32 = 0;
        var maxGreen: u32 = 0;
        var maxBlue: u32 = 0;
        _ = it.first();

        var gamesIt = std.mem.splitSequence(u8, it.rest(), "; ");
        while (gamesIt.peek() != null) {
            const game = gamesIt.next() orelse break;
            if (std.mem.containsAtLeast(u8, game, 1, ",")) {
                var gameIt = std.mem.splitSequence(u8, game, ", ");
                while (gameIt.peek() != null) {
                    if (gameIt.next()) |value| {
                        colorCount = try getColorCount(value);
                        switch (colorCount.color) {
                            .red => {
                                if (colorCount.count > maxRed) {
                                    maxRed = colorCount.count;
                                }
                            },
                            .green => {
                                if (colorCount.count > maxGreen) {
                                    maxGreen = colorCount.count;
                                }
                            },
                            .blue => {
                                if (colorCount.count > maxBlue) {
                                    maxBlue = colorCount.count;
                                }
                            },
                        }
                    }
                }
            } else {
                colorCount = try getColorCount(game);
                switch (colorCount.color) {
                    .red => {
                        if (colorCount.count > maxRed) {
                            maxRed = colorCount.count;
                        }
                    },
                    .green => {
                        if (colorCount.count > maxGreen) {
                            maxGreen = colorCount.count;
                        }
                    },
                    .blue => {
                        if (colorCount.count > maxBlue) {
                            maxBlue = colorCount.count;
                        }
                    },
                }
            }
        }

        print("max r:{d}, g:{d}, b:{d}\n", .{ maxRed, maxGreen, maxBlue });
        gamePowerSum += maxRed * maxGreen * maxBlue;
    }

    print("Game power sum: {d}\n", .{gamePowerSum});
}
