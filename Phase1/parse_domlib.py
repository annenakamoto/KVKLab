import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    if words[0] != "":
        first_word = words[0]
        in_dict = Elements.get(first_word)
        if not in_dict:
            Elements[first_word] = 1

with open(sys.argv[1], "r") as LIB:
    printing = False
    for line in LIB:
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
