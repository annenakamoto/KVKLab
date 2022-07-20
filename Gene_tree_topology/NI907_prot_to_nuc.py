import sys

MAPPING = {}    # key = old gene name, value = new gene name
with open("/global/scratch/users/annen/GENOME_TREE/PROTEOMES/NI907_gene_map.txt", "r") as map:
    for line in map:
        lst = line.split()
        MAPPING[lst[1]] = lst[2]

# sys.stdin is /global/scratch/users/annen/GENOME_TREE/PROTEOMES/GCF_004355905.1_ASM435590v1_cds_from_genomic.fna
for line in sys.stdin:
    if ">" in line:
        old_name = line.split("protein_id=")[1][:14]
        print(">" + MAPPING[old_name])
    else:
        print(line[:-1])
