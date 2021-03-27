import sys

elements = []
for elem in sys.stdin:
    elements.append(elem[:-1])

with open(sys.argv[1], "r") as library:
    printing = False
    for line in library:
        words = str(line).split()
        if len(words) > 0:
            first_word = words[0]
            if first_word[0] == ">":
                printing = False
                for i in range(len(elements)):
                    if elements[i] == first_word:
                        printing = True
                        elements.pop(i)
                        break
            if printing:
                print(line[:-1])
        