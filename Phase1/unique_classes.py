import sys

classifications = set()

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0 and lst[0] == ">":
        c = lst[1].split("#")[1].split(":")[0]
        classifications.add(c)

for c in classifications:
    print(c)
