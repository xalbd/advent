const std = @import("std");

const data = @embedFile("data/day20.txt");
const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);
const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

fn valid(r: isize, c: isize) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols and data[@intCast(r * (cols + 1) + c)] != '#';
}

fn floodfill(r: isize, c: isize, distances: [][]usize, dist: usize) void {
    if (!valid(r, c)) return;

    const ur: usize = @intCast(r);
    const uc: usize = @intCast(c);

    if (distances[ur][uc] > dist) {
        distances[ur][uc] = dist;

        for (directions) |dir| {
            floodfill(r + dir[0], c + dir[1], distances, dist + 1);
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    const dist: [][][]usize = try allocator.alloc([][]usize, 2);
    for (dist) |*x| {
        x.* = try allocator.alloc([]usize, rows);
        for (x.*) |*y| {
            y.* = try allocator.alloc(usize, cols);
            @memset(y.*, std.math.maxInt(usize));
        }
    }

    const start_index = std.mem.indexOfScalar(u8, data, 'S').?;
    const end_index = std.mem.indexOfScalar(u8, data, 'E').?;
    const start_r = start_index / (cols + 1);
    const start_c = start_index % (cols + 1);
    const end_r = end_index / (cols + 1);
    const end_c = end_index % (cols + 1);

    floodfill(@intCast(start_r), @intCast(start_c), dist[0], 0);
    floodfill(@intCast(end_r), @intCast(end_c), dist[1], 0);

    const goal = dist[0][end_r][end_c];

    var out1: usize = 0;
    var out2: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            for (0..rows) |r_end| {
                for (0..cols) |c_end| {
                    const ir: isize = @intCast(r);
                    const ic: isize = @intCast(c);
                    const ir_end: isize = @intCast(r_end);
                    const ic_end: isize = @intCast(c_end);

                    const distance = @abs(ir_end - ir) + @abs(ic_end - ic);
                    if (distance <= 20 and valid(ir, ic) and valid(ir_end, ic_end)) {
                        if (dist[0][r][c] + distance + dist[1][r_end][c_end] <= goal - 100) {
                            if (distance == 2) out1 += 1;
                            out2 += 1;
                        }
                    }
                }
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
