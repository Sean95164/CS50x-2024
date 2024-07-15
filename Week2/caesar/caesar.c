#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char rotate(long key, char cha);
int check(string text);

int main(int argc, string argv[])
{
    if (argc != 2 || !check(argv[1]))
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }

    string plaintext = get_string("plaintext: ");

    long key = atol(argv[1]);

    printf("ciphertext: ");
    for (int i = 0, len = strlen(plaintext); i < len; i++)
    {
        char cipherChar = rotate(key, plaintext[i]);
        printf("%c", cipherChar);
    }

    printf("\n");
    return 0;
}

char rotate(long key, char cha)
{
    if (isalpha(cha))
    {
        long shift = 0;
        if (cha >= 'A' && cha <= 'Z')
        {
            shift = ((cha + key - 'A') % 26) + 'A';
        }
        else if (cha >= 'a' && cha <= 'z')
        {
            shift = ((cha + key - 'a') % 26) + 'a';
        }
        return shift;
    }
    return (char) cha;
}

int check(string text)
{
    for (int i = 0, len = strlen(text); i < len; i++)
    {
        if (!isdigit(text[i]))
        {
            return 0;
        }
    }

    return 1;
}
