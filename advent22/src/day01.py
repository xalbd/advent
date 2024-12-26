with open("data/day01.txt") as f:
    elves = [x.split("\n") for x in f.read().split("\n\n")]

totals = [sum(map(int, x)) for x in elves]
totals.sort(reverse=True)

out1 = totals[0]
print(f"1: {out1}")


out2 = sum(totals[0:3])
print(f"2: {out2}")
