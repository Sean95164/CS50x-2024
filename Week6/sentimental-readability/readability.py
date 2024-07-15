from cs50 import get_string


def count_letters(text):
    count = 0
    for cha in text:
        if cha.isalpha():
            count += 1

    return count


def count_words(text):
    count = 1
    for cha in text:
        if cha.isspace():
            count += 1

    return count


def count_sentences(text):
    count = 0
    for cha in text:
        if cha in [".", "!", "?"]:
            count += 1

    return count


def main():
    text = get_string("Text: ")

    letters = count_letters(text)
    words = count_words(text)
    sentences = count_sentences(text)

    L = letters / words * 100
    S = sentences / words * 100
    index = round(0.0588 * L - 0.296 * S - 15.8)

    if (index < 1):
        print("Before Grade 1\n")

    elif (index >= 16):
        print("Grade 16+\n")

    else:
        print(f"Grade {index}")


main()
