#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int left;
    do
    {
        left = get_int("Change owed: ");
    }
    while (left < 0);

    int total = 0;
    total += (left / 25);
    left %= 25;

    total += (left / 10);
    left %= 10;

    total += (left / 5);
    left %= 5;

    total += (left / 1);

    printf("%i\n", total);
}
