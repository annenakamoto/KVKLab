# find the # bp each TE takes up

import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    if len(words) == 1:
        first_word = words[0]
        name = first_word.split(":")
        coords = name[2][:-3].split("-")
        length = abs(int(coords[0]) - int(coords[1]))
        in_dict = Elements.get(name[0])
        if in_dict:
            Elements[name[0]] += length
        else:
            Elements[name[0]] = length

print(len(Elements), " unique elements.\n")

total = 0
for elem, count in Elements.items():
    print(elem, "\t", count)
    total += count

print(total, " total bp of TEs.\n")
