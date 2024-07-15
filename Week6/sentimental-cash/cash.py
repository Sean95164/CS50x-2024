from cs50 import get_float


def num_of_change(total):
    total = int(total * 100)
    change = 0

    change += total // 25
    total %= 25

    change += total // 10
    total %= 10

    change += total // 5
    total %= 5

    change += total

    return change


def main():
    total = get_float("Change: ")
    if total < 0:
        total = get_float("Change: ")

    change = num_of_change(total)
    print(change)


main()
