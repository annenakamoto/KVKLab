from Bio import SeqIO
import sys
import os
import shutil
import csv

### works in: /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline
###     OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa
###     ${OG}.Pfam.reduced.tbl

og = sys.argv[1]    # OG
fa = "OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/" + og + ".fa"
dm = og + ".Pfam.reduced.tbl"
out = og + ".iTOL.domains.txt"

record_list = list(SeqIO.parse(fa, 'fasta'))

DOMAINS = {}    # key=gene_name, value=[shape,start,stop,color,domain_name]
with open(dm, 'r') as tbl:
    for line in tbl:
        lst = line.split()
        gene_name = lst[0]
        start = lst[10]
        stop = lst[11]
        domain_name = lst[2]
        if "NB-ARC" in domain_name:
            shape = "HH"
            color = "#ffff99"   # yellow
        elif "LRR" in domain_name:
            shape = "RE"
            color = "#de4b4d"   # red
        elif "Rx_N" in domain_name:
            shape = "EL"
            color = "6aeb65"   # green
        else:
            shape = "DI"
            color = "#9e9e9e"   # grey
        if DOMAINS.get(gene_name):
            item = [str(shape),str(start),str(stop),str(color),str(domain_name)]
            DOMAINS[str(gene_name)].append(item)
        else:
            item = [str(shape),str(start),str(stop),str(color),str(domain_name)]
            DOMAINS[str(gene_name)] = [item]

with open(out, 'w') as output:
    for i in range(len(record_list)):
        record = record_list[i]
        gene_name = record.id
        length = len(record.seq)
        result = [str(gene_name),str(length)]
        for d in DOMAINS[gene_name]:
            result.append("|".join(d))
        #output.write(",".join(result))
        print(",".join(result))

