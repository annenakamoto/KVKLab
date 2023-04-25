from Bio import SeqIO
import sys
import os
import shutil
import csv

### works in: /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline
###     OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa
###     ${OG}.Pfam.reduced.tbl

og = sys.argv[1]    # OG

## Zm NLRs
# fa = "OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/" + og + ".fa"
# dm = og + ".Pfam.reduced.tbl"
# out = og + ".iTOL.domains.txt"

## Mo HV OGs
fa = "OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences/" + og + ".fa"
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
        elif "NACHT" in domain_name:
            shape = "HH"
            color = "#6378ff"   # darkblue
        elif "AAA" in domain_name:
            shape = "HH"
            color = "#63e5ff"   # lightblue
        elif "LRR" in domain_name:
            shape = "RE"
            color = "#de4b4d"   # red
        elif "Ank" in domain_name:
            shape = "RE"
            color = "#ffaa00"   # yellow-orange
        elif "WD" in domain_name:
            shape = "RE"
            color = "#8a3200"   # brown
        elif "TPR" in domain_name:
            shape = "RE"
            color = "#ff6a00"   # orange
        elif "Rx_N" in domain_name:
            shape = "EL"
            color = "#6aeb65"   # green
        elif "Pkinase" in domain_name:
            shape = "EL"
            color = "#00a38b"   # teal
        elif "PNP_UDP" in domain_name:
            shape = "EL"
            color = "#b163ff"   # purple
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
    output.write("DATASET_DOMAINS\n")
    output.write("SEPARATOR COMMA\n")
    output.write("DATASET_LABEL,Domains\n")
    output.write("COLOR,#ff0000\n")
    output.write("DATA\n")
    for i in range(len(record_list)):
        record = record_list[i]
        gene_name = record.id
        length = len(record.seq)
        result = [str(gene_name),str(length)]
        if DOMAINS.get(gene_name):
            for d in DOMAINS[gene_name]:
                result.append("|".join(d))
            output.write(",".join(result) + "\n")
            #print(",".join(result))

