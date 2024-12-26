import copy

with open("data/day05.txt") as f:
    [state, directions] = [x.split("\n") for x in f.read().split("\n\n")]


stacks = [[] for _ in range((len(state[0]) + 1) // 4)]
for line in state[:-1]:
    for i in range(len(stacks)):
        if line[4 * i + 1] != " ":
            stacks[i].insert(0, line[4 * i + 1])
stacks2 = copy.deepcopy(stacks)

directions = [x.split(" ") for x in directions]
directions = [list(map(int, [x[1], x[3], x[5]])) for x in directions]
directions = [[x[0], x[1] - 1, x[2] - 1] for x in directions]

for d in directions:
    for _ in range(d[0]):
        stacks[d[2]].append(stacks[d[1]].pop())

out1 = "".join([x[-1] for x in stacks])
print(f"1: {out1}")


for d in directions:
    stacks2[d[2]].extend(stacks2[d[1]][-d[0] :])
    stacks2[d[1]] = stacks2[d[1]][: -d[0]]

out2 = "".join([x[-1] for x in stacks2])
print(f"2: {out2}")
