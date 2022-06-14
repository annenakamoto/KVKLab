import sys

genome = sys.argv[1]

# >MAGGY_I:CP050920.1:5819093-5824697(+):LpKY97

for line in sys.stdin:
    if ">" in line and genome in line:
        lst = line.split(":")
        chrom = lst[1]
        start, stop = lst[2][:-3].split("-")
        name = lst[0][1:]
        score = str(0)
        strand = lst[2].split("(")[1][0]
        print('\t'.join([chrom, start, stop, name, score, strand]))
        
