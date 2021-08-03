import sys

genome = sys.argv[1]

TE_COUNT = {
    "GYMAG1_I": 0,
    "GYMAG2_I": 0,
    "GYPSY1_MG": 0,
    "MAGGY_I": 0,
    "MGRL3_I": 0,
    "PYRET_I": 0,
    "MGR583": 0,
    "POT2": 0,
    "copia_fam": 0
}

total = 0
total_minus_other = 0
for line in sys.stdin:
    lst = line.split()
    if len(lst) == 2 and str(lst[0]) in TE_COUNT:
        TE_COUNT[str(lst[0])] = int(lst[1])
        total_minus_other += int(lst[1])
    if len(lst) > 2 and str(lst[1]) == "total":
        total = int(lst[0])

TE_COUNT["other"] = total - total_minus_other

### GENOME\tGYMAG1_I\tGYMAG2_I\tGYPSY1_MG\tMAGGY_I\tMGRL3_I\tPYRET_I\tMGR583\tPOT2\tcopia_fam\tother
print(genome+"\t"+str(TE_COUNT["GYMAG1_I"])+"\t"+str(TE_COUNT["GYMAG2_I"])+"\t"+str(TE_COUNT["GYPSY1_MG"])+"\t"+str(TE_COUNT["MAGGY_I"])+"\t"+str(TE_COUNT["MGRL3_I"])+
        "\t"+str(TE_COUNT["PYRET_I"])+"\t"+str(TE_COUNT["MGR583"])+"\t"+str(TE_COUNT["POT2"])+"\t"+str(TE_COUNT["copia_fam"])+"\t"+str(TE_COUNT["other"]))
