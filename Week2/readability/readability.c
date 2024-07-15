#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

int count_letters(string text);
int count_words(string text);
int count_sentences(string text);

int main(void)
{
    // Prompt the user for some text
    string text = get_string("Text: ");

    // Count the number of letters, words, and sentences in the text
    int letters = count_letters(text);
    int words = count_words(text);
    int sentences = count_sentences(text);

    // Compute the Coleman-Liau index
    double L = (double) letters / words * 100.0;
    double S = (double) sentences / words * 100.0;
    double index = 0.0588 * L - 0.296 * S - 15.8;
    int roundIndex = index + 0.5;
    // Print the grade level

    if (roundIndex < 1)
    {
        printf("Before Grade 1\n");
    }
    else if (roundIndex >= 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        printf("Grade %d\n", roundIndex);
    }
}

int count_letters(string text)
{
    // Return the number of letters in text
    int count = 0;
    for (int i = 0, len = strlen(text); i < len; i++)
    {
        if (isalpha(text[i]))
        {
            count += 1;
        }
    }
    return count;
}

int count_words(string text)
{
    // Return the number of words in text
    int count = 1;
    for (int i = 0, len = strlen(text); i < len; i++)
    {
        if (isspace(text[i]))
        {
            count += 1;
        }
    }
    return count;
}

int count_sentences(string text)
{
    // Return the number of sentences in text
    int count = 0;
    for (int i = 0, len = strlen(text); i < len; i++)
    {
        if (text[i] == '.' || text[i] == '!' || text[i] == '?')
        {
            count += 1;
        }
    }
    return count;
}
