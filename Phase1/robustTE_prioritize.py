import sys

elements = []
for elem in sys.stdin:
    elements.append(elem[:-1])

with open(sys.argv[1], "r") as library:
    printing = False
    for line in library:
        words = str(line).split()
        first_word = words[0]
        if first_word[0] == ">":
            if first_word in elements:
                printing = True
            else:
                printing = False
        if printing:
            print(line[:-1])
        