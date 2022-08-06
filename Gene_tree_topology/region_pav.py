import sys

OG_PAV = {}    # key=OG, value=genomes_list

for line in sys.stdin:
    lst = line.split()
    genome = lst[3].split("_")[2]
    og = lst[4]
    if OG_PAV.get(og):
        OG_PAV[og].append(genome)
    else:
        OG_PAV[og] = [genome]

all_genomes = ["guy11", "US71", "B71", "LpKY97", "MZ5-1-6"]
for og,genomes in OG_PAV.items():
    entry = [og]
    for i in range(0,5):
        if all_genomes[i] in genomes:
            entry.append(all_genomes[i])
        else:
            entry.append("x")
    print('\t'.join(entry))
