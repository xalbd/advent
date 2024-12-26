with open("data/day03.txt") as f:
    lines = f.read().split("\n")


def priority(x: str):
    return ord(x) - ord("a") + 1 if x.islower() else ord(x) - ord("A") + 27


shared = [set(x[: len(x) // 2]) & set(x[len(x) // 2 :]) for x in lines]
priorities = [priority(x.pop()) for x in shared]
out1 = sum(priorities)
print(f"1: {out1}")


shared = [
    set(lines[i * 3]) & set(lines[i * 3 + 1]) & set(lines[i * 3 + 2])
    for i in range(0, len(lines) // 3)
]
priorities = [priority(x.pop()) for x in shared]
out2 = sum(priorities)
print(f"2: {out2}")
