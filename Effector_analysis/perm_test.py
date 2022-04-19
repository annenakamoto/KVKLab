import sys
import random
from statistics import median

# sys.argv[1] = TE
# sys.argv[2] = GENOME
# sys.argv[3] = allTEs-eff dist file (control)
# sys.argv[4] = indivTE-eff dist file (treatment)

# reads in files
def read_in(file_name, dictionary):
    with open(file_name, 'r') as f:
        for line in f:
            lst = line.split()
            # TE: (upstream_dist, downstream_dist)
            dictionary[lst[0]] = tuple(int(lst[1]), int(lst[2]))

# Read in control (allTEs-eff dist file)
CONTROL = {}
read_in(sys.argv[3], CONTROL)

# Read in treatment (indivTEs-eff dist file)
TREATMENT = {}
read_in(sys.argv[4], TREATMENT)



