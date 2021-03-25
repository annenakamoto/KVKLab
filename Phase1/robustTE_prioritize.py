import sys

elements = []
for elem in sys.stdin:
    elements.append(elem)

with open(sys.argv[1], "r") as library:
    printing = False
    for line in library:
        first_word = line.partition(' ')[0]
        if first_word[0] == ">":
            if first_word in elements:
                elements.remove(first_word)
                printing = True
            else:
                printing = False
        if printing:
            print(line)
        