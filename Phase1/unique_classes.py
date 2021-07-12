import sys

CLASSES = {}

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0 and lst[0] == ">":
        c = lst[1].split("#")[1].split(":")[0]
        if CLASSES.get(c):
            CLASSES[c] += 1
        else:
            CLASSES[c] = 1

for key, value in CLASSES.items():
    print(key, '\t', value)
