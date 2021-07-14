import sys

oryza_blue = "#4d8eff"
setaria_green = "#7cff4d"
triticum_orange = "#ffcf4d"
eleusine_aqua = "#4dffea"
lolium_purple = "#a64dff"

LINEAGES = {
    "AG006":    oryza_blue,
    "AG039":    oryza_blue,
    "Sar-2-20-1":    oryza_blue,
    "AG098":    oryza_blue,
    "PR003":    oryza_blue,
    "AG032":    oryza_blue,
    "AG059":    oryza_blue,
    "AG038":    oryza_blue,
    "FJ98099":    oryza_blue,
    "AV1-1-1":    oryza_blue,
    "FJ72ZC7-77":    oryza_blue,
    "FR13":    oryza_blue,
    "AG002":    oryza_blue,
    "FJ81278":    oryza_blue,
    "San_Andrea":    oryza_blue,
    "guy11":    oryza_blue,
    "Lh88405":    oryza_blue,
    "Arcadia2":    setaria_green,
    "US71":    setaria_green,
    "LpKY97":    lolium_purple,
    "BTJP4-1":    triticum_orange,
    "BTGP6-f":    triticum_orange,
    "BTGP1-b":    triticum_orange,
    "BTMP13_1":    triticum_orange,
    "B71":    triticum_orange,
    "BR32":    triticum_orange,
    "MZ5-1-6":    eleusine_aqua,
    "CD156":    eleusine_aqua
}

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0 and "#" in lst[0]:
        for iso in LINEAGES.keys():
            if iso in lst[0]:
                print(lst[0], "\t", LINEAGES[iso], "\t", iso)
                break
