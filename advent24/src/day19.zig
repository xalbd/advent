const std = @import("std");

const data = @embedFile("data/day19.txt");

fn possible(towel: []const u8, patterns: std.ArrayList([]const u8)) bool {
    if (towel.len == 0) return true;

    for (patterns.items) |pattern| {
        if (towel.len >= pattern.len and std.mem.eql(u8, towel[0..pattern.len], pattern)) {
            if (possible(towel[pattern.len..], patterns)) {
                return true;
            }
        }
    }
    return false;
}

fn count(towel: []const u8, patterns: std.ArrayList([]const u8), allocator: std.mem.Allocator) !usize {
    var memo: []usize = try allocator.alloc(usize, towel.len + 1); // 0 to x not including x
    defer allocator.free(memo);

    for (memo) |*m| {
        m.* = 0;
    }

    for (1..towel.len + 1) |i| { // upper bound non inclusive
        for (0..i) |j| { // lower bound inclusive
            for (patterns.items) |pattern| {
                if (pattern.len == i - j and std.mem.eql(u8, pattern, towel[j..i])) {
                    memo[i] += if (j == 0) 1 else memo[j];
                }
            }
        }
    }
    return memo[towel.len];
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    const pattern_end = std.mem.indexOfScalar(u8, data, '\n').?;
    var patterns = std.ArrayList([]const u8).init(allocator);
    var sections = std.mem.tokenize(u8, data[0..pattern_end], ", ");
    while (sections.next()) |sec| {
        try patterns.append(sec);
    }

    var out1: usize = 0;
    var out2: usize = 0;
    var towels = std.mem.splitScalar(u8, data[pattern_end + 2 ..], '\n');
    while (towels.next()) |towel| {
        if (possible(towel, patterns)) {
            out1 += 1;
            out2 += try count(towel, patterns, allocator);
        }
    }

    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
