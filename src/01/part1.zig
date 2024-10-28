const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const print = std.debug.print;
const fs = std.fs;

pub fn part_one() !void {
    var file = try fs.cwd().openFile("src/01/file1.txt", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var sum: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums: [10]u8 = undefined;
        var i: usize = 0;

        for (line) |byte| {
            switch (byte) {
                '0'...'9' => {
                    nums[i] = byte;
                    i += 1;
                },
                else => {
                    continue;
                },
            }
        }
        const num1: u32 = @intCast((nums[0] - '0'));
        const num2: u32 = @intCast((nums[i - 1] - '0'));

        sum += ((num1 * 10) + num2);
    }
    print("{d}\t", .{sum});
    print("\n", .{});
}
