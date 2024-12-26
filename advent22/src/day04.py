with open("data/day04.txt") as f:
    lines = f.read().split("\n")
    pairs = [x.split(",") for x in lines]
    values = [[[int(v) for v in x.split("-")] for x in y] for y in pairs]


def contain(pair):
    return (pair[0][0] <= pair[1][0] and pair[0][1] >= pair[1][1]) or (
        pair[0][0] >= pair[1][0] and pair[0][1] <= pair[1][1]
    )


def overlap(pair):
    return not (pair[0][0] > pair[1][1] or pair[1][0] > pair[0][1])


out1 = [contain(x) for x in values].count(True)
print(f"1: {out1}")


out2 = [overlap(x) for x in values].count(True)
print(f"2: {out2}")
