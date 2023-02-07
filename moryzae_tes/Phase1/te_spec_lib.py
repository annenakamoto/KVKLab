import sys

# elements to include in library
ELEMS = {}
for line in sys.stdin:
    ELEMS[line[:-1]] = 1

printing = False
# nucleotide sequence library
with open("LIB_DOM.fasta.classified", 'r') as lib:
    for line in lib:
        lst = line.split()
        if len(lst) > 0:
            if ">" in lst[0]:
                if ELEMS.get(lst[0][1:]):
                    printing = True
                    print(line[:-1])
                else:
                    printing = False
            else:
                if printing:
                    print(line[:-1])




        