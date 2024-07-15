#include "helpers.h"
#include <math.h>

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop over all pixels
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int rgbtRed = image[i][j].rgbtRed;
            int rgbtGreen = image[i][j].rgbtGreen;
            int rgbtBlue = image[i][j].rgbtBlue;

            // Take average of red, green, and blue, then round the value
            int grayScale = round((rgbtBlue + rgbtGreen + rgbtRed) / 3.0);

            // Update pixel values
            image[i][j].rgbtRed = grayScale;
            image[i][j].rgbtGreen = grayScale;
            image[i][j].rgbtBlue = grayScale;
        }
    }
}

// Convert image to sepia
void sepia(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop over all pixels
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            BYTE rgbtRed = image[i][j].rgbtRed;
            BYTE rgbtGreen = image[i][j].rgbtGreen;
            BYTE rgbtBlue = image[i][j].rgbtBlue;

            // Compute and round sepia values
            int sepiaRed = round(.393 * rgbtRed + .769 * rgbtGreen + .189 * rgbtBlue);
            int sepiaGreen = round(.349 * rgbtRed + .686 * rgbtGreen + .168 * rgbtBlue);
            int sepiaBlue = round(.272 * rgbtRed + .534 * rgbtGreen + .131 * rgbtBlue);

            // Ensure the resulting value is no larger than 255
            if (sepiaRed > 255)
            {
                sepiaRed = 255;
            }

            if (sepiaGreen > 255)
            {
                sepiaGreen = 255;
            }

            if (sepiaBlue > 255)
            {
                sepiaBlue = 255;
            }

            // Update pixel with sepia values
            image[i][j].rgbtRed = sepiaRed;
            image[i][j].rgbtGreen = sepiaGreen;
            image[i][j].rgbtBlue = sepiaBlue;
        }
    }
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop over half pixels
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width / 2; j++)
        {
            // Swap pixels
            RGBTRIPLE tmp = image[i][j];
            image[i][j] = image[i][width - j - 1];
            image[i][width - j - 1] = tmp;
        }
    }
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // Create a copy of image
    RGBTRIPLE copy[height][width];
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            copy[i][j] = image[i][j];
        }
    }

    int d[][2] = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}};

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int red = 0;
            int blue = 0;
            int green = 0;

            int neighborsNum = 0;

            for (int k = 0; k < 9; k++)
            {
                int next_i = i + d[k][0];
                int next_j = j + d[k][1];

                // Check no beyond the edge
                if (next_i < height && next_i >= 0 && next_j < width && next_j >= 0)
                {
                    red += copy[next_i][next_j].rgbtRed;
                    blue += copy[next_i][next_j].rgbtBlue;
                    green += copy[next_i][next_j].rgbtGreen;

                    neighborsNum += 1;
                }
            }

            image[i][j].rgbtRed = round(red / (float) neighborsNum);
            image[i][j].rgbtBlue = round(blue / (float) neighborsNum);
            image[i][j].rgbtGreen = round(green / (float) neighborsNum);
        }
    }

    return;
}
