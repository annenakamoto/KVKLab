import sys

Elements = {}
for elem in sys.stdin:
    Elements[elem[:-1]] = 1

with open(sys.argv[1], "r") as library:
    printing = False
    for line in library:
        words = str(line).split()
        if len(words) > 0:
            first_word = words[0]
            if first_word[0] == ">":
                if Elements.get(first_word):
                    printing = True
                else:
                    printing = False
            if printing:
                print(line[:-1])
        