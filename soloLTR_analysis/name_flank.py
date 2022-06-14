import sys

ltr = (sys.argv[1]).split("_")[0]
mapping = sys.argv[2]






c = 1
with open(mapping, 'w') as f:
    
    f.write(str(c) + ": " + k + '\n') # keep track of what number referrs to which internal region
    c += 1