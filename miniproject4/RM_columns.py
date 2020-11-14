from Bio import SeqIO
import sys

KW = {}

with open("References/fngrep.embl", "r") as library:
    for record in SeqIO.parse(library, "embl"):
        KW[record.name] = [len(record.seq), record.annotations.get('keywords')]

for line in sys.stdin:
    lst = line.split()
    if len(lst) >= 15:
        key = KW.get(lst[9])
        length = abs(int(lst[6]) - int(lst[5]))
        if key is not None and ("LTR" not in lst[9]):
            print(line[:-1], length, '\t', round(((float(length) / key[0]) * 100.0), 1), '\t', ', '.join(key[1]))
