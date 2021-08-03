from Phase1.rename_TE import NAMES
import sys

# key is original name, value is new name
NAME_MAP = {}

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0:
        NAME_MAP[lst[0]] = lst[1]

with open("LIB_DOM.fasta.classified", 'r') as lib:
    for line in lib:
        lst = line.split()
        if ">" in lst[0]:
            if NAME_MAP.get(lst[0][1:]):
                print(">" + NAME_MAP[lst[0][1:]])
            else: 
                print(lst[0])
        else:
            print(lst[0])
