def get_int(prompt):
    while True:
        try:
            height = int(input(prompt))
            if 1 <= height <= 8:
                return height
            else:
                pass
        except ValueError:
            pass


def main():
    height = get_int("Height: ")

    for i in range(1, height + 1):
        num_of_space = height - i
        print(" " * num_of_space, end="")
        print("#" * i)


main()
