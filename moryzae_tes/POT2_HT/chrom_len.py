import sys

chrom = None
length = 0
for line in sys.stdin:
    if ">" in line:
        if chrom:
            print(chrom + "\t" + str(length))
        chrom = line.split()[0][1:]
        length = 0
    else:
        length += len(line[:-1])
print(chrom + "\t" + str(length))

