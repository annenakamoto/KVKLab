import sys

blue = "0,60,255"
green = "30,255,0"
orange = "255,153,0"
purple = "162,0,255"
cyan = "0,229,255"

RGB = { "guy11":    blue,
        "US71":     green,
        "B71":      orange,
        "LpKY97":   purple,
        "MZ5-1-6":  cyan }

for line in sys.stdin:
    if line and ">" in line:
        lst = line.split(":")
        ss = lst[2].split("-")
        
        chrom = lst[1]
        start = ss[0]
        stop = ss[1][:-3]
        name = lst[0][1:]
        score = "0"
        strand = "."
        ts = start
        te = stop
        rgb = RGB[lst[3][:-1]]
        
        print(chrom + '\t' + start + '\t' + stop + '\t' + name + '\t' + score + '\t' + strand + '\t' + ts + '\t' + te + '\t' + rgb)
        