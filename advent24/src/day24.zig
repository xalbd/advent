const std = @import("std");

const data = @embedFile("data/day24.txt");

const Rule = struct { one: [3]u8, two: [3]u8, op: u8, result: [3]u8 };

fn eq(x: [3]u8, y: [3]u8) bool {
    return std.mem.eql(u8, &x, &y);
}

fn verifyAdder(bit: usize, carry: [3]u8, rules: *std.ArrayList(Rule)) ?[3]u8 {
    // x_id, y_id, z_id are solid
    // xor1, and1, carry, xor2, and2, or1 are available for swapping
    const x_id: [3]u8 = .{ 'x', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };
    const y_id: [3]u8 = .{ 'y', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };
    const z_id: [3]u8 = .{ 'z', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };

    var xor1: ?[3]u8 = null;
    var and1: ?[3]u8 = null;
    for (rules.items) |r| {
        if ((eq(r.one, x_id) and eq(r.two, y_id)) or (eq(r.one, y_id) and eq(r.two, x_id))) {
            if (r.op == 'X') {
                xor1 = r.result;
            } else if (r.op == 'A') {
                and1 = r.result;
            }
        }
    }

    var and2: ?[3]u8 = null;

    for (rules.items) |r| {
        if ((eq(r.one, xor1.?) and eq(r.two, carry)) or (eq(r.one, carry) and eq(r.two, xor1.?))) {
            if (r.op == 'X') {
                if (!eq(r.result, z_id)) return null;
            } else if (r.op == 'A') {
                and2 = r.result;
            }
        }
    }

    if (and2 == null) return null;

    for (rules.items) |r| {
        if ((eq(r.one, and2.?) and eq(r.two, and1.?)) or (eq(r.one, and1.?) and eq(r.two, and2.?))) {
            if (r.op == 'O') {
                return r.result;
            }
        }
    }

    return null;
}

fn verifyWholeAdder(rules: *std.ArrayList(Rule)) usize {
    var carry: ?[3]u8 = .{ 'g', 'c', 't' };
    for (1..45) |z| {
        carry = verifyAdder(z, carry.?, rules);
        if (carry == null) return z;
    }

    return if (std.mem.eql(u8, &carry.?, "z45")) 45 else 0;
}

fn sortNames(_: void, a: [3]u8, b: [3]u8) bool {
    return std.mem.order(u8, &a, &b).compare(std.math.CompareOperator.lt);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    // part 1
    var wires = std.AutoHashMap([3]u8, bool).init(allocator);

    const split_loc = std.mem.indexOf(u8, data, "\n\n").?;

    var initial_sections = std.mem.splitScalar(u8, data[0..split_loc], '\n');
    while (initial_sections.next()) |section| {
        try wires.put(.{ section[0], section[1], section[2] }, section[5] == '1');
    }

    var rules = std.ArrayList(Rule).init(allocator);
    var rules2 = std.ArrayList(Rule).init(allocator);
    var rule_sections = std.mem.splitScalar(u8, data[split_loc + 2 ..], '\n');
    while (rule_sections.next()) |section| {
        var segments = std.mem.splitScalar(u8, section, ' ');
        var segment = segments.next().?;

        var r: Rule = undefined;
        r.one = .{ segment[0], segment[1], segment[2] };
        segment = segments.next().?;
        r.op = segment[0];
        segment = segments.next().?;
        r.two = .{ segment[0], segment[1], segment[2] };
        segment = segments.next().?;
        segment = segments.next().?;

        r.result = .{ segment[0], segment[1], segment[2] };

        try rules.append(r);
        try rules2.append(r);
    }

    while (rules2.items.len > 0) {
        var i: usize = 0;
        while (i < rules2.items.len) {
            const r = rules2.items[i];
            if (wires.contains(r.one) and wires.contains(r.two)) {
                const one = wires.get(r.one).?;
                const two = wires.get(r.two).?;
                const out = switch (r.op) {
                    'A' => one and two,
                    'O' => one or two,
                    'X' => (one and !two) or (!one and two),
                    else => unreachable,
                };

                try wires.put(r.result, out);
                _ = rules2.orderedRemove(i);
            } else {
                i += 1;
            }
        }
    }

    var bit: usize = 0;
    var mask = std.bit_set.IntegerBitSet(64).initEmpty();
    while (true) {
        const desired_index: [3]u8 = .{ 'z', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };
        if (!wires.contains(desired_index)) break;

        mask.setValue(bit, wires.get(desired_index).?);
        bit += 1;
    }
    try stdout.print("1: {d}\n", .{mask.mask});

    // part 2
    var wire_list = std.ArrayList([3]u8).init(allocator);
    var it = wires.keyIterator();
    while (it.next()) |w| {
        try wire_list.append(w.*);
    }

    var best = verifyWholeAdder(&rules);
    var out2 = std.ArrayList([3]u8).init(allocator);
    while (best != 45) {
        outer: for (wire_list.items) |a| {
            for (wire_list.items) |b| {
                for (rules.items) |*r| {
                    if (std.mem.eql(u8, &r.result, &a)) {
                        r.result = b;
                    } else if (std.mem.eql(u8, &r.result, &b)) {
                        r.result = a;
                    }
                }

                if (verifyWholeAdder(&rules) > best) {
                    best = verifyWholeAdder(&rules);
                    try out2.append(a);
                    try out2.append(b);
                    break :outer;
                }

                for (rules.items) |*r| {
                    if (std.mem.eql(u8, &r.result, &a)) {
                        r.result = b;
                    } else if (std.mem.eql(u8, &r.result, &b)) {
                        r.result = a;
                    }
                }
            }
        }
    }

    std.mem.sort([3]u8, out2.items, {}, sortNames);
    try stdout.print("2: ", .{});
    for (out2.items, 0..) |n, i| {
        try stdout.print("{s}", .{n});
        if (i == out2.items.len - 1) {
            try stdout.print("\n", .{});
        } else {
            try stdout.print(",", .{});
        }
    }
}
