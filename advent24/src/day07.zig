const std = @import("std");

const data = @embedFile("data/day07.txt");

fn explore(target: usize, nums: []usize, total: usize, index: usize) bool {
    if (index == nums.len) return total == target;
    return explore(target, nums, total + nums[index], index + 1) or
        explore(target, nums, total * nums[index], index + 1);
}

fn explore_cat(target: usize, nums: []usize, total: usize, index: usize) bool {
    if (index == nums.len) return total == target;
    return explore_cat(target, nums, total + nums[index], index + 1) or
        explore_cat(target, nums, total * nums[index], index + 1) or
        explore_cat(target, nums, total * std.math.pow(usize, 10, std.math.log10_int(nums[index]) + 1) + nums[index], index + 1);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var out1: usize = 0;
    var out2: usize = 0;

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const split_loc = std.mem.indexOfScalar(u8, line, ':').?;
        const goal = try std.fmt.parseInt(usize, line[0..split_loc], 10);

        var nums = std.ArrayList(usize).init(allocator);
        defer nums.deinit();

        var num_sections = std.mem.splitScalar(u8, line[split_loc + 2 ..], ' ');
        while (num_sections.next()) |num_section| {
            try nums.append(try std.fmt.parseInt(usize, num_section, 10));
        }

        if (explore(goal, nums.items, nums.items[0], 1)) out1 += goal;
        if (explore_cat(goal, nums.items, nums.items[0], 1)) out2 += goal;
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
