from Bio import SeqIO

PLENGTH = 85.0
PIDENT = 90.0

KW = {}

with open("References/fngrep.embl", "rU") as library:
    for record in SeqIO.parse(library, "embl"):
        KW[record.name] = [len(record.seq), record.annotations.get('keywords')]

with open("guy11.fasta.out", "rU") as annotation:
    hits = 0
    for line in annotation:
        lst = line.split()
        if len(lst) >= 15:
            key = KW.get(lst[9])
            length = abs(int(lst[6]) - int(lst[5]))
            if key is not None and ("LTR" not in lst[9]) and (round(((float(length) / key[0]) * 100.0), 1) >= PLENGTH) and (100.0 - float(lst[1]) >= PIDENT):
                print line[:-1], length, '\t', key[0], '\t', round(((float(length) / key[0]) * 100.0), 1), '\t', ', '.join(key[1])
                hits += 1
        elif len(lst) == 14:
            print line[:-1], '\t', "len", '\t', "act", '\t', "plen", "\t", "keywords"
        else:
            print line[:-1]
    print hits
