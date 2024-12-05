const std = @import("std");

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const split = std.mem.indexOf(u8, data, "\n\n").?;
    const rule_data = data[0..split];
    const update_data = data[split + 2 ..];

    var rules = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer {
        var it = rules.valueIterator();
        while (it.next()) |v| {
            v.deinit();
        }
        rules.deinit();
    }

    var rule_sections = std.mem.splitScalar(u8, rule_data, '\n');
    while (rule_sections.next()) |sec| {
        const before = try std.fmt.parseInt(u8, sec[0..2], 10);
        const after = try std.fmt.parseInt(u8, sec[3..], 10);

        if (!rules.contains(before)) {
            try rules.put(before, std.ArrayList(u32).init(allocator));
        }

        try rules.getPtr(before).?.append(after);
    }

    var out1: u32 = 0;
    var out2: u32 = 0;
    var pages = std.ArrayList(u32).init(allocator);
    defer pages.deinit();

    var update_sections = std.mem.splitScalar(u8, update_data, '\n');
    while (update_sections.next()) |sec| {
        pages.clearRetainingCapacity();

        var page_sections = std.mem.splitScalar(u8, sec, ',');
        while (page_sections.next()) |page_sec| {
            try pages.append(try std.fmt.parseInt(u8, page_sec, 10));
        }

        var ok = true;
        for (pages.items[0 .. pages.items.len - 1], pages.items[1..pages.items.len]) |i, j| {
            if (rules.contains(j) and std.mem.indexOfScalar(u32, rules.get(j).?.items, i) != null) {
                ok = false;
                break;
            }
        }

        if (ok) {
            out1 += pages.items[pages.items.len / 2];
        } else {
            for (pages.items) |target| {
                var count: i32 = 0;
                for (pages.items) |p| {
                    if (p != target and std.mem.indexOfScalar(u32, rules.get(target).?.items, p) != null) {
                        count += 1;
                    }
                }

                if (count == pages.items.len / 2) {
                    out2 += target;
                    break;
                }
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
