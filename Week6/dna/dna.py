import csv
import sys


def main():

    # Check for command-line usage
    if len(sys.argv) != 3:
        print("Require 3 file input")

    # Read database file into a variable
    rows = []
    with open(sys.argv[1]) as file:
        reader = csv.DictReader(file)
        for row in reader:
            rows.append(row)

    STRs = []
    for key in reader.fieldnames:
        if key == "name":
            continue
        STRs.append(key)

    # Read DNA sequence file into a variable
    with open(sys.argv[2]) as file:
        sequence = file.readline()

    # Find longest match of each STR in DNA sequence
    STRs_of_sequence = dict()
    for STR in STRs:
        STRs_of_sequence[STR] = longest_match(sequence, STR)

    # Check database for matching profiles
    for row in rows:
        match = True
        for STR in STRs:
            if int(row[STR]) != STRs_of_sequence[STR]:
                # Test
                # print(f"{row['name']} in {STR} not matched")
                # print(f"expected: {STRs_of_sequence[STR]}, actual: {row[STR]}")
                match = False
                break

        if match:
            print(row["name"])
            break

    if match == False:
        print("No match")

    return


def longest_match(sequence, subsequence):
    """Returns length of longest run of subsequence in sequence."""

    # Initialize variables
    longest_run = 0
    subsequence_length = len(subsequence)
    sequence_length = len(sequence)

    # Check each character in sequence for most consecutive runs of subsequence
    for i in range(sequence_length):

        # Initialize count of consecutive runs
        count = 0

        # Check for a subsequence match in a "substring" (a subset of characters) within sequence
        # If a match, move substring to next potential match in sequence
        # Continue moving substring and checking for matches until out of consecutive matches
        while True:

            # Adjust substring start and end
            start = i + count * subsequence_length
            end = start + subsequence_length

            # If there is a match in the substring
            if sequence[start:end] == subsequence:
                count += 1

            # If there is no match in the substring
            else:
                break

        # Update most consecutive matches found
        longest_run = max(longest_run, count)

    # After checking for runs at each character in seqeuence, return longest run found
    return longest_run


main()
