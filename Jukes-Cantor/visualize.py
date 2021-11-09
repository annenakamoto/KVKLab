import sys

blue = "0,17,145"
green = "0,107,2"
orange = "166,102,0"
purple = "106,0,163"
cyan = "0,126,143"

RGB = { "guy11":    blue,
        "US71":     green,
        "B71":      orange,
        "LpKY97":   purple,
        "MZ5-1-6":  cyan }

JC = {}
c = 0
with open(sys.argv[1], 'r') as file:
    for line in file:
        lst = line.split()
        if len(lst) == 3:
            jc_dist = lst[1]
            JC[c] = jc_dist
            c += 1

c = 0
for line in sys.stdin:
    if line and ">" in line:
        lst = line.split(":")
        ss = lst[2].split("(")
        s = ss[0].split("-")
        
        chrom = lst[1]
        start = str(s[0])
        stop = str(s[1])
        name = lst[0][1:] + "(" + str(round(float(JC[c]), 6)) + ")"
        # 0 JC = 999 ;
        if float(JC[c]) > .4:
            score = 100
        else:
            score = (1 - float(JC[c])/.4) * 832 + 167
        strand = ss[1][:-1]
        ts = start
        te = stop
        rgb = RGB[lst[3][:-1]]
        
        print(chrom + '\t' + start + '\t' + stop + '\t' + name + '\t' + str(score) + '\t' + strand + '\t' + ts + '\t' + te + '\t' + rgb)
        
