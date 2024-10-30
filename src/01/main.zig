const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const print = std.debug.print;
const assert = std.debug.assert;
const fs = std.fs;

const NotFound = error{ NoneExist, Nan };

fn is_possible_num(l: u8) NotFound![][]u8 {
    switch (l) {
        'o' => {
            return [][]u8{"one"};
        },
        't' => {
            return [][]u8{ "two", "three" };
        },
        'f' => {
            return [][]u8{ "four", "five" };
        },
        's' => {
            return [][]u8{ "six", "seven" };
        },
        'e' => {
            return [][]u8{"eight"};
        },
        'n' => {
            return [][]u8{"nine"};
        },
        else => {
            return NotFound.NoneExist;
        },
    }
}

fn needle_in_haystacks(needle: []u8, haystacks: [][]u8) NotFound!i8 {
    for (0..haystacks.len) |i| {
        if (std.mem.containsAtLeast(u8, haystacks[i], 1, needle)) {
            return i;
        }
    }

    return NotFound.NoneExist;
}

fn get_value(num: []u8) NotFound!u8 {
    // TODO: use std.mem.eql
}

pub fn part_one() !void {
    var file = try fs.cwd().openFile("src/01/file1.txt", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var sum: u32 = 0;
    var byteBuffer: [6]u8 = undefined;
    var byteBufferIndex: usize = 0;
    const maxBufferIndex: usize = 5;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums: [10]u8 = undefined;
        var i: usize = 0;
        var possibleNums: [][]u8 = undefined;

        for (line) |byte| {
            switch (byte) {
                '0'...'9' => {
                    nums[i] = byte;
                    i += 1;
                },
                'a'...'z' => {
                    if (byteBufferIndex == 0) {
                        assert(byteBuffer[byteBufferIndex] == '0');

                        possibleNums = is_possible_num(byte) catch {
                            continue;
                        };

                        if (possibleNums.len != 0) {
                            assert(byteBuffer[byteBufferIndex] == '0');
                            byteBuffer[byteBufferIndex] = byte;
                        }

                        continue;
                    }

                    assert(byteBufferIndex < maxBufferIndex);
                    byteBufferIndex += 1;

                    assert(byteBuffer[byteBufferIndex] == '0');
                    byteBuffer[byteBufferIndex] = byte;

                    const foundIndex: i8 = needle_in_haystacks(byteBuffer[0..(byteBufferIndex + 1)], possibleNums) catch {
                        @memset(&byteBuffer, '0');
                        byteBufferIndex = 0;
                    };
                    if (foundIndex > 0) {
                        // found needle
                        // check if needle is expected
                        // enums?
                        // if not try again with the next byte
                    }
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
