// Implements a dictionary's functionality
/* ============================================== */

// Must add #define _GNU_SOURCE, or it will show warning when compiling
#define _GNU_SOURCE
#include "dictionary.h"
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Choose number of buckets in hash table
const unsigned int N = LENGTH * 30;

// Hash table
node *table[N];

// Size attribute
int count = 0;

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    unsigned int hashCode = hash(word);

    // set ptr point to first node in table[hashCode]
    node *ptr = table[hashCode]->next;
    while (ptr != NULL)
    {
        bool match = strcasecmp(ptr->word, word) == 0;
        if (match)
        {
            return true;
        }
        ptr = ptr->next;
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    unsigned int hashCode = 0;
    // Improve this hash function
    for (int i = 0; i < strlen(word); i++)
    {
        if (isalpha(word[i]))
        {
            hashCode += toupper(word[i]) - 'A';
        }
    }
    return hashCode;
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // Initialize hashtable
    for (int i = 0; i < N; i++)
    {
        node *sentinel = malloc(sizeof(node));
        strcpy(sentinel->word, "");
        sentinel->next = NULL;
        table[i] = sentinel;
    }

    // Open the dictionary file
    FILE *source = fopen(dictionary, "r");
    if (source == NULL)
    {
        return false;
    }

    char word[LENGTH + 1];
    char c;
    int index = 0;

    // Read each word in the file
    while (fread(&c, sizeof(char), 1, source))
    {
        if (c != '\n')
        {
            word[index++] = c;
        }
        else
        {
            // create a word, and reset the index to 0
            word[index] = '\0';
            index = 0;

            // add 1 to size variable
            count++;

            // Add each word to the hash table
            unsigned int hashCode = hash(word);

            // Create a new node
            node *newNode = malloc(sizeof(node));
            strcpy(newNode->word, word);

            node *ptr = table[hashCode];
            // prepend to linked-list
            newNode->next = ptr->next;
            ptr->next = newNode;
        }
    }

    // Close the dictionary file
    fclose(source);
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    return count;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    for (int i = 0; i < N; i++)
    {
        node *p = table[i];
        free_list(p);
    }
    return true;
}

void free_list(node *p)
{
    if (p == NULL)
    {
        return;
    }

    free_list(p->next);
    free(p);
}
