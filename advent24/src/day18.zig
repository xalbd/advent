const std = @import("std");

const data = @embedFile("data/day18.txt");

const Location = struct { r: isize, c: isize, distance: usize };

const Queue = struct {
    const Node = struct {
        val: Location,
        next: ?*Node,
    };

    arena: std.mem.Allocator,
    head: ?*Node = null,
    tail: ?*Node = null,

    fn enqueue(self: *Queue, loc: Location) !void {
        const node = try self.arena.create(Node);
        node.* = .{ .val = loc, .next = null };

        if (self.tail != null) self.tail.?.next = node else self.head = node;
        self.tail = node;
    }

    fn deque(self: *Queue) ?Location {
        const node = self.head orelse return null;

        if (self.head == self.tail) self.tail = null;
        self.head = self.head.?.next;
        return node.val;
    }
};

const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };
const rows = 71;
const cols = 71;

fn inBounds(r: isize, c: isize) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols;
}

fn bfs(allocator: std.mem.Allocator, map: [][cols]bool) !?usize {
    var q: Queue = .{ .arena = allocator };
    try q.enqueue(.{ .r = 0, .c = 0, .distance = 0 });

    var visit: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);
    visit[0][0] = true;

    var out: ?usize = null;
    while (q.deque()) |cur| {
        if (cur.r == 70 and cur.c == 70) {
            out = cur.distance;
            break;
        }
        for (directions) |dir| {
            const new_r = cur.r + dir[0];
            const new_c = cur.c + dir[1];
            if (inBounds(new_r, new_c) and !map[@intCast(new_r)][@intCast(new_c)] and !visit[@intCast(dir[0] + cur.r)][@intCast(dir[1] + cur.c)]) {
                visit[@intCast(dir[0] + cur.r)][@intCast(dir[1] + cur.c)] = true;
                try q.enqueue(.{ .r = dir[0] + cur.r, .c = dir[1] + cur.c, .distance = cur.distance + 1 });
            }
        }
    }

    return out;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    var map: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);

    var sections = std.mem.splitScalar(u8, data, '\n');
    for (0..1024) |_| {
        const sec = sections.next().?;
        const comma_loc = std.mem.indexOfScalar(u8, sec, ',').?;
        map[try std.fmt.parseInt(usize, sec[0..comma_loc], 10)][try std.fmt.parseInt(usize, sec[comma_loc + 1 ..], 10)] = true;
    }

    // part 1
    const out1: ?usize = try bfs(allocator, &map);
    try stdout.print("1: {d}\n", .{out1.?});

    // part 2
    while (sections.next()) |sec| {
        const comma_loc = std.mem.indexOfScalar(u8, sec, ',').?;
        map[try std.fmt.parseInt(usize, sec[0..comma_loc], 10)][try std.fmt.parseInt(usize, sec[comma_loc + 1 ..], 10)] = true;

        if (try bfs(allocator, &map) == null) {
            try stdout.print("2: {s},{s}\n", .{ sec[0..comma_loc], sec[comma_loc + 1 ..] });
            break;
        }
    }
}
