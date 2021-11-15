import sys

for line in sys.stdin:
    if ">" in line:
        lst = line.split(":")
        lst1 = lst[2].split("(")
        lst2 = lst1[0].split("-")
        chrom = lst[1]
        start = str(lst2[0])
        end = str(lst2[1])
        name = line[1:-1]
        score = "0"
        strand = lst1[1][0]
        print(chrom + "\t" + start + "\t" + end + "\t" + name + "\t" + score + "\t" + strand)
