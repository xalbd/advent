const std = @import("std");

const data = @embedFile("data/day12.txt");
const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);
const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

const Region = struct { count: usize, perimeter: usize };
const Plot = struct { r: isize, c: isize, dir: usize };

fn inBounds(r: isize, c: isize) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols;
}

fn floodfill(r: isize, c: isize, seen: [][cols]bool, output: [][cols]usize, target: u8, label: usize) void {
    if (!inBounds(r, c)) return;

    const ir: usize = @intCast(r);
    const ic: usize = @intCast(c);

    if (data[ir * (cols + 1) + ic] == target and !seen[ir][ic]) {
        seen[ir][ic] = true;
        output[ir][ic] = label;

        for (directions) |dir| {
            floodfill(r + dir[0], c + dir[1], seen, output, target, label);
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // reformat input for unique labels
    var map: [cols][rows]usize = undefined;
    var seen: [cols][rows]bool = std.mem.zeroes([cols][rows]bool);
    for (0..rows) |r| {
        for (0..cols) |c| {
            floodfill(@intCast(r), @intCast(c), &seen, &map, data[r * (cols + 1) + c], r * (cols + 1) + c);
        }
    }

    var regions = std.AutoHashMap(usize, Region).init(allocator);
    var perimeter_plots = std.AutoHashMap(usize, std.ArrayList(Plot)).init(allocator);
    defer {
        regions.deinit();

        var vals = perimeter_plots.valueIterator();
        while (vals.next()) |v| {
            v.deinit();
        }
        perimeter_plots.deinit();
    }

    for (0..rows) |r| {
        for (0..cols) |c| {
            const ir: isize = @intCast(r);
            const ic: isize = @intCast(c);
            const target = map[r][c];

            if (!regions.contains(target)) {
                try regions.put(target, .{ .count = 0, .perimeter = 0 });
            }
            regions.getPtr(target).?.count += 1;

            for (directions, 0..) |dir, i| {
                const nr: isize = ir + dir[0];
                const nc: isize = ic + dir[1];
                if (!inBounds(nr, nc) or target != map[@intCast(nr)][@intCast(nc)]) {
                    regions.getPtr(target).?.perimeter += 1;

                    if (!perimeter_plots.contains(target)) {
                        try perimeter_plots.put(target, std.ArrayList(Plot).init(allocator));
                    }
                    try perimeter_plots.getPtr(target).?.append(.{ .r = nr, .c = nc, .dir = i });
                }
            }
        }
    }

    var out1: usize = 0;
    var out2: usize = 0;

    var it = regions.iterator();
    while (it.next()) |entry| {
        const label = entry.key_ptr.*;
        const region = entry.value_ptr.*;

        out1 += region.count * region.perimeter;

        var neighbor_pairs: usize = 0;
        const plots = perimeter_plots.get(label).?.items;
        for (plots) |i| {
            for (plots) |j| {
                if (i.dir == j.dir and ((i.c == j.c and i.r == j.r + 1) or (i.r == j.r and i.c == j.c + 1))) neighbor_pairs += 1;
            }
        }
        out2 += region.count * (region.perimeter - neighbor_pairs);
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
