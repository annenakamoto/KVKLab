from Bio import SeqIO
import sys
import os
import shutil
import csv

### Generate domain annotations for itol

dom = sys.argv[1]    # domain (NB-ARC, NACHT, AAA)

fa = dom + ".fa"
dm = dom + ".Pfam.reduced.tbl"
out = dom + ".iTOL.domains.txt"

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
        elif "HET" in domain_name:
            shape = "EL"
            color = "#1a8216"   # dark-green
        elif "HeLo" in domain_name:
            shape = "EL"
            color = "#168262"   # dark-teal
        elif "Ses_" in domain_name:
            shape = "EL"
            color = "#f0719d"   # pink
        elif "Goodbye" in domain_name:
            shape = "EL"
            color = "#870b36"   # magenta
        elif "Patatin" in domain_name:
            shape = "EL"
            color = "#b85e11"   # dark-orange
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

