const std = @import("std");

const data = @embedFile("data/day21.txt");

const Loc = struct { r: isize, c: isize };
const LocPair = struct { one: Loc, two: Loc = .{ .r = 0, .c = 2 } };
const LocPairDistance = struct { l: LocPair, distance: usize };

const numeric_loc: [11]Loc = .{ .{ .r = 3, .c = 1 }, .{ .r = 2, .c = 0 }, .{ .r = 2, .c = 1 }, .{ .r = 2, .c = 2 }, .{ .r = 1, .c = 0 }, .{ .r = 1, .c = 1 }, .{ .r = 1, .c = 2 }, .{ .r = 0, .c = 0 }, .{ .r = 0, .c = 1 }, .{ .r = 0, .c = 2 }, .{ .r = 3, .c = 2 } };
const directional_loc: [5]Loc = .{ .{ .r = 0, .c = 1 }, .{ .r = 1, .c = 0 }, .{ .r = 1, .c = 1 }, .{ .r = 1, .c = 2 }, .{ .r = 0, .c = 2 } };
const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 } };

fn inBoundsDirectional(r: isize, c: isize) bool {
    return switch (r) {
        0 => c >= 1 and c <= 2,
        1 => c >= 0 and c <= 2,
        else => false,
    };
}

fn inBoundsNumeric(r: isize, c: isize) bool {
    return switch (r) {
        0, 1, 2 => c >= 0 and c <= 2,
        3 => c >= 1 and c <= 2,
        else => false,
    };
}

fn distIndexLoc(l: Loc) usize {
    return @intCast(l.r * 3 + l.c);
}

fn distIndexLocPair(l: LocPair) usize {
    return 6 * distIndexLoc(l.one) + distIndexLoc(l.two);
}

// returns collapsed 2x3x2x3 matrix with number of inputs required to move next robot in chain from any directional r/c to any other directional r/c and click
fn getNextRobotDistance(allocator: std.mem.Allocator, prev_dist: [36]usize) ![36]usize {
    var out: [36]usize = undefined;
    @memset(&out, std.math.maxInt(usize));

    var stack = std.ArrayList(LocPairDistance).init(allocator);
    defer stack.deinit();

    for (1..6) |i| {
        var dist_from_start: [36]usize = undefined; // distances from current robot r/c + previous robot A to current robot r/c + previous robot r/c
        @memset(&dist_from_start, std.math.maxInt(usize));
        stack.clearAndFree();

        try stack.append(.{ .l = .{ .one = .{ .r = @intCast(i / 3), .c = @intCast(i % 3) } }, .distance = 0 });
        while (stack.popOrNull()) |cur| {
            const l = cur.l;
            if (!inBoundsDirectional(l.one.r, l.one.c) or !inBoundsDirectional(l.two.r, l.two.c)) continue;

            if (dist_from_start[distIndexLocPair(l)] > cur.distance) {
                dist_from_start[distIndexLocPair(l)] = cur.distance;
                try pushNeighbors(&stack, cur, prev_dist);
            }
        }

        for (0..6) |j| {
            out[6 * i + j] = dist_from_start[6 * j + 2];
        }

        // no moving and immediate click from initial position edge case due to starting search with 0 distance
        out[6 * i + i] = prev_dist[2 * 6 + 2];
    }

    return out;
}

fn getRobotDistance(allocator: std.mem.Allocator, repeats: usize) ![36]usize {
    var out: [36]usize = undefined;
    @memset(&out, 1);

    for (0..repeats) |_| {
        out = try getNextRobotDistance(allocator, out);
    }

    return out;
}

fn distance(allocator: std.mem.Allocator, start: Loc, end: Loc, robot_dist: [36]usize) !usize {
    var dist: [4 * 3 * 2 * 3]usize = undefined;
    @memset(&dist, std.math.maxInt(usize));

    var stack = std.ArrayList(LocPairDistance).init(allocator);
    defer stack.deinit();

    try stack.append(.{ .l = .{ .one = start }, .distance = 0 });
    while (stack.popOrNull()) |cur| {
        const l = cur.l;
        if (!inBoundsNumeric(l.one.r, l.one.c) or !inBoundsDirectional(l.two.r, l.two.c)) continue;

        if (dist[distIndexLocPair(l)] > cur.distance) {
            dist[distIndexLocPair(l)] = cur.distance;
            try pushNeighbors(&stack, cur, robot_dist);
        }
    }

    return dist[@intCast(end.r * 18 + end.c * 6 + 2)];
}

fn pushNeighbors(stack: *std.ArrayList(LocPairDistance), cur: LocPairDistance, prev_dist: [36]usize) !void {
    for (directions, 0..) |dir, i| {
        var new_loc = cur.l;
        new_loc.one.r += dir[0];
        new_loc.one.c += dir[1];
        new_loc.two = directional_loc[i];
        const dist_delta = prev_dist[distIndexLocPair(.{ .one = cur.l.two, .two = new_loc.two })];
        try stack.append(.{ .l = new_loc, .distance = cur.distance + dist_delta });
    }

    const dist_delta = prev_dist[distIndexLocPair(.{ .one = cur.l.two, .two = directional_loc[4] })];
    try stack.append(.{ .l = .{ .one = cur.l.one, .two = directional_loc[4] }, .distance = cur.distance + dist_delta });
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    var out1: usize = 0;
    var out2: usize = 0;

    const robot_2: [36]usize = try getRobotDistance(allocator, 2);
    const robot_25: [36]usize = try getRobotDistance(allocator, 25);

    var codes = std.mem.splitScalar(u8, data, '\n');
    while (codes.next()) |code| {
        var distance_1: usize = 0;
        var distance_2: usize = 0;

        var current = numeric_loc[10];
        var end: Loc = undefined;
        for (0..code.len) |i| {
            end = if (code[i] == 'A') numeric_loc[10] else numeric_loc[code[i] - '0'];

            distance_1 += try distance(allocator, current, end, robot_2);
            distance_2 += try distance(allocator, current, end, robot_25);

            current = end;
        }
        out1 += try std.fmt.parseInt(usize, code[0 .. code.len - 1], 10) * distance_1;
        out2 += try std.fmt.parseInt(usize, code[0 .. code.len - 1], 10) * distance_2;
    }

    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
