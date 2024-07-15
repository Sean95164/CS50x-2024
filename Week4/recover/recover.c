#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    // Accept a single command-line argument
    if (argc != 2)
    {
        printf("Too many arguments!\n");
        return 1;
    }

    // Open the memory card
    FILE *card = fopen(argv[1], "r");
    if (card == NULL)
    {
        printf("Can't open the file %s", argv[1]);
        return 1;
    }

    // Create a buffer for a block of data
    uint8_t buffer[512];

    int fileNum = 0;
    bool firstFile = true;
    char *filename = malloc(10 * sizeof(char));
    FILE *img = NULL;

    // While there's still data left to read from the memory card
    while (fread(buffer, 1, 512, card) == 512)
    {
        // Create JPEGs from the data

        // Detect whether a new .jpeg. If it is .jpeg, then create a new file.
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff &&
            (buffer[3] & 0xf0) == 0xe0)
        {
            if (!firstFile)
            {
                fclose(img);
            }
            else
            {
                firstFile = false;
            }

            sprintf(filename, "%03i.jpg", fileNum);
            img = fopen(filename, "w");
            fileNum += 1;
        }

        if (img != NULL)
        {
            fwrite(buffer, 1, 512, img);
        }
    }

    free(filename);
    fclose(img);
    fclose(card);
    return 0;
}
