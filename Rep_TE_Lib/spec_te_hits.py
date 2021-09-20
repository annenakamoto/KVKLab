import sys

### Outputting all specific TE (argv[1]) hits in a library
### stdin is the RepeatMasker hits library of the input GENOME (argv[2])

TE = sys.argv[1]
GENOME = sys.argv[2]

printing = False
for line in sys.stdin:
    if ">" in line:
        if TE in line:
            printing = True
            print(line[:-1] + ":" + GENOME)
        else:
            printing = False
    else:
        if printing == True:
            print(line[:-1])

