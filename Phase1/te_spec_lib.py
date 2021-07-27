import sys

# elements to include in library
ELEMS = {}

for line in sys.stdin:
    ELEMS[line[:-1]] = 1

printing = False
with open("LIB_DOM_trans.fasta.classified", 'r') as lib:
    for line in lib:
        lst = line.split()
        if len(lst) > 0:
            if lst[0] == ">":
                if ELEMS.get(lst[1]):
                    printing = True
                    print(line[:-1])
                else:
                    printing = False
            else:
                if printing:
                    print(line[:-1])

        