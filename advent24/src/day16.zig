const std = @import("std");

const data = @embedFile("data/day16.txt");
const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

const Location = struct { r: isize, c: isize, dir: usize, cost: usize };

fn tryMove(move: Location, stack: *std.ArrayList(Location), visit: [][][]usize) !void {
    if (visit[move.dir][@intCast(move.r)][@intCast(move.c)] > move.cost) {
        visit[move.dir][@intCast(move.r)][@intCast(move.c)] = move.cost;
        try stack.append(move);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
    const rows: usize = (data.len + 1) / (cols + 1);

    const start_index = std.mem.indexOfScalar(u8, data, 'S').?;
    const end_index = std.mem.indexOfScalar(u8, data, 'E').?;

    const start_r = start_index / (cols + 1);
    const start_c = start_index % (cols + 1);
    const end_r = end_index / (cols + 1);
    const end_c = end_index % (cols + 1);

    // part 1
    var visit: [][][]usize = try allocator.alloc([][]usize, 4);
    for (visit) |*x| {
        x.* = try allocator.alloc([]usize, rows);
        for (x.*) |*y| {
            y.* = try allocator.alloc(usize, cols);
            @memset(y.*, std.math.maxInt(usize));
        }
    }

    var stack = std.ArrayList(Location).init(allocator);
    try stack.append(.{ .r = @intCast(start_r), .c = @intCast(start_c), .dir = 1, .cost = 0 });
    visit[1][start_r][start_c] = 0;

    while (stack.popOrNull()) |cur| {
        const move = Location{ .r = cur.r + directions[cur.dir][0], .c = cur.c + directions[cur.dir][1], .cost = cur.cost + 1, .dir = cur.dir };
        if (move.r >= 0 and move.r < rows and move.c >= 0 and move.c < cols) {
            const move_r: usize = @intCast(move.r);
            const move_c: usize = @intCast(move.c);
            const move_idx: usize = move_r * (cols + 1) + move_c;
            if (data[move_idx] != '#') {
                try tryMove(move, &stack, visit);
            }
        }

        const rotate_1 = Location{ .r = cur.r, .c = cur.c, .cost = cur.cost + 1000, .dir = (cur.dir + 1) % 4 };
        const rotate_2 = Location{ .r = cur.r, .c = cur.c, .cost = cur.cost + 1000, .dir = (cur.dir + 3) % 4 };
        try tryMove(rotate_1, &stack, visit);
        try tryMove(rotate_2, &stack, visit);
    }

    const out1: usize = @min(visit[0][end_r][end_c], @min(visit[1][end_r][end_c], @min(visit[2][end_r][end_c], visit[3][end_r][end_c])));
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    var best_visit: [][]bool = try allocator.alloc([]bool, rows);
    for (best_visit) |*x| {
        x.* = try allocator.alloc(bool, cols);
        @memset(x.*, false);
    }

    var best_stack = std.ArrayList(Location).init(allocator);
    for (0..4) |dir| {
        if (visit[dir][end_r][end_c] == out1) {
            try best_stack.append(.{ .r = @intCast(end_r), .c = @intCast(end_c), .cost = out1, .dir = dir });
        }
    }

    var out2: usize = 0;
    while (best_stack.popOrNull()) |cur| {
        const cur_r: usize = @intCast(cur.r);
        const cur_c: usize = @intCast(cur.c);
        if (!best_visit[cur_r][cur_c]) {
            out2 += 1;
            best_visit[cur_r][cur_c] = true;
        }

        for (0..4) |dir| {
            if (cur.cost >= 1000 and visit[dir][cur_r][cur_c] == cur.cost - 1000) {
                try best_stack.append(.{ .r = cur.r, .c = cur.c, .cost = cur.cost - 1000, .dir = dir });
            }
        }

        const move_r: isize = cur.r - directions[cur.dir][0];
        const move_c: isize = cur.c - directions[cur.dir][1];
        if (cur.cost >= 1 and visit[cur.dir][@intCast(move_r)][@intCast(move_c)] == cur.cost - 1) {
            try best_stack.append(.{ .r = move_r, .c = move_c, .cost = cur.cost - 1, .dir = cur.dir });
        }
    }
    try stdout.print("2: {d}\n", .{out2});
}
