import sys
import random
from statistics import median

# sys.stdin = eff-indivTE dists (treatment)
# sys.argv[1] = TE
# sys.argv[2] = GENOME
# sys.argv[3] = eff-allTEs dist file (control)

control_u = []
control_d = []
with open(sys.argv[3], 'r') as cont:
    for line in cont:
        lst = line.split()
        # effector: [upstream_dist, downstream_dist]
        control_u.append(int(lst[1]))
        control_d.append(int(lst[2]))

treatment_u = []
treatment_d = []
for line in sys.stdin:
    lst = line.split()
    # effector: [upstream_dist, downstream_dist]
    treatment_u.append(int(lst[1]))
    treatment_d.append(int(lst[2]))

med_tu = median(treatment_u)
med_td = median(treatment_d)
len_t = len(treatment_u)


