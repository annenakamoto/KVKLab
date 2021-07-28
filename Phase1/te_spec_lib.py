import sys

mode = sys.argv[1]

# elements to include in library
ELEMS = {}
for line in sys.stdin:
    ELEMS[line[:-1]] = 1


if mode == "protein":
    printing = False
    # protein sequence library
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
elif mode == "nucleotide":
    printing = False
    # nucleotide sequence library
    with open("LIB_DOM.fasta.classified", 'r') as lib:
        for line in lib:
            lst = line.split()
            if len(lst) > 0:
                if ">" in lst[0]:
                    if ELEMS.get(lst[1:]):
                        printing = True
                        print(line[:-1])
                    else:
                        printing = False
                else:
                    if printing:
                        print(line[:-1])
else:
    print("please choose nucleotide or protein mode")



        