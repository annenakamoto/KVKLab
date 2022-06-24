import sys

# gene names are original ones from fungap, need to be mapped to names in orthofinder output (gene_00001 -> gene_0_guy11)
# input is a bed file from STDIN
# arg1 = genome name

genome = sys.argv[1]

for line in sys.stdin:
    lst = line.split()
    original = lst[3].split("_")
    new = "gene_" + str(int(original[1]) - 1) + "_" + genome
    lst[0] = new
    print('\t'.join(lst))
