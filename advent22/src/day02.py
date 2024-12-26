with open("data/day02.txt") as f:
    rounds = f.read().split("\n")
    rounds = [[ord(x[0]) - ord("A"), ord(x[2]) - ord("X")] for x in rounds]


def shape(id):
    return id + 1


def outcome(round):
    match (round[0] - round[1]) % 3:
        case 0:
            return 3
        case 1:
            return 0
        case 2:
            return 6


def calculate(round):
    match round[1]:
        case 0:
            return 0 + shape((round[0] - 1) % 3)
        case 1:
            return 3 + shape(round[0])
        case 2:
            return 6 + shape((round[0] + 1) % 3)


out1 = sum([outcome(round) + shape(round[1]) for round in rounds])
print(f"1: {out1}")


out2 = sum([calculate(round) for round in rounds])
print(f"2: {out2}")
