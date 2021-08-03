import sys

# classification for each TE of interest (te_name corresponds to one of these keys)
TE_CLASS = {
    "GYMAG1_I": "LTR/Gypsy", "GYMAG2_I": "LTR/Gypsy", "GYPSY1_MG": "LTR/Gypsy",
    "MAGGY_I": "LTR/Gypsy", "MGRL3_I": "LTR/Gypsy", "PYRET_I": "LTR/Gypsy",
    "MGR583": "LINE/Tad1", "POT2": "DNA/TcMar-Fot1", "copia_fam": "LTR/Copia"
}
te_name = sys.argv[1]
te_class = TE_CLASS[te_name]

# count for each genome
COUNT = {
    "AG006": 1, "AG039": 1, "Sar-2-20-1": 1, "AG098": 1, "PR003": 1, "AG032": 1,
    "AG059": 1, "AG038": 1, "FJ98099": 1, "AV1-1-1": 1, "FJ72ZC7-77": 1, "FR13": 1,
    "AG002": 1, "FJ81278": 1, "San_Andrea": 1, "guy11": 1, "Lh88405": 1, "Arcadia2": 1,
    "US71": 1, "LpKY97": 1, "BTJP4-1": 1, "BTGP6-f": 1, "BTGP1-b": 1, "BTMP13_1": 1,
    "B71": 1, "BR32": 1, "MZ5-1-6": 1, "CD156": 1
}

for line in sys.stdin:
    source = ""
    for genome in COUNT.keys():
        if genome in line:
            source = genome + "." + COUNT[genome]
            COUNT[genome] += 1
            break
    print(line[:-1] + "\t" + te_name + "#" + source + "#" + te_class)
