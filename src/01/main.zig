const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;
const fs = std.fs;

const NotFound = error{ NoneExist, Nan };

fn is_possible_num(l: u8) NotFound![]const []const u8 {
    return switch (l) {
        'o' => &[_][]const u8{"one"},
        't' => &[_][]const u8{ "two", "three" },
        'f' => &[_][]const u8{ "four", "five" },
        's' => &[_][]const u8{ "six", "seven" },
        'e' => &[_][]const u8{"eight"},
        'n' => &[_][]const u8{"nine"},
        else => NotFound.NoneExist,
    };
}

fn needle_in_haystacks(needle: []u8, haystacks: []const []const u8) NotFound!usize {
    print("Needle: {s}\n", .{needle});
    for (haystacks, 0..) |haystack, i| {
        if (std.mem.containsAtLeast(u8, haystack, 1, needle)) {
            return i;
        }
    }

    return NotFound.NoneExist;
}

fn get_value(num: []const u8) NotFound!u8 {
    if (std.mem.eql(u8, num, "one")) {
        return '1';
    } else if (std.mem.eql(u8, num, "two")) {
        return '2';
    } else if (std.mem.eql(u8, num, "three")) {
        return '3';
    } else if (std.mem.eql(u8, num, "four")) {
        return '4';
    } else if (std.mem.eql(u8, num, "five")) {
        return '5';
    } else if (std.mem.eql(u8, num, "six")) {
        return '6';
    } else if (std.mem.eql(u8, num, "seven")) {
        return '7';
    } else if (std.mem.eql(u8, num, "eight")) {
        return '8';
    } else if (std.mem.eql(u8, num, "nine")) {
        return '9';
    }

    return NotFound.NoneExist;
}

pub fn part_one() !void {
    var file = try fs.cwd().openFile("src/01/file1.txt", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var sum: u32 = 0;
    var byteBuffer: [10]u8 = .{0} ** 10;
    var byteBufferIndex: usize = 0;
    const maxBufferIndex: usize = 5;
    var possibleNums: []const []const u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums: [10]u8 = undefined;
        var i: usize = 0;
        var possibleNum: u8 = undefined;

        for (line) |byte| {
            switch (byte) {
                '0'...'9' => {
                    nums[i] = byte;
                    i += 1;
                },
                'a'...'z' => {
                    if (byteBufferIndex == 0) {
                        assert(byteBuffer[byteBufferIndex] == 0);

                        possibleNums = is_possible_num(byte) catch {
                            continue;
                        };

                        if (possibleNums.len != 0) {
                            assert(byteBuffer[byteBufferIndex] == 0);

                            byteBuffer[byteBufferIndex] = byte;
                            byteBufferIndex += 1;
                        }
                        continue;
                    }

                    assert(byteBufferIndex < maxBufferIndex);
                    assert(byteBuffer[byteBufferIndex] == 0);

                    byteBuffer[byteBufferIndex] = byte;
                    byteBufferIndex += 1;

                    const foundIndex: usize = needle_in_haystacks(byteBuffer[0..(byteBufferIndex + 1)], possibleNums) catch {
                        @memset(&byteBuffer, 0);
                        byteBufferIndex = 0;
                        continue;
                    };

                    possibleNum = get_value(possibleNums[foundIndex]) catch {
                        continue;
                    };

                    nums[i] = possibleNum;
                    @memset(&byteBuffer, 0);
                    byteBufferIndex = 0;
                    i += 1;
                },
                else => {
                    continue;
                },
            }
        }
        const num1: u8 = (nums[0] - '0');
        const num2: u8 = (nums[i - 1] - '0');

        sum += ((num1 * 10) + num2);
    }
    print("{d}\t", .{sum});
    print("\n", .{});
}
