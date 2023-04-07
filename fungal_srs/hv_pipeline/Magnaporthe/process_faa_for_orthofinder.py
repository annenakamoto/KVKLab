from Bio import SeqIO
import sys
import os
import shutil
import csv

### Processes faa output from fungap for orthofinder (re-name genes, remove stop codons)

genome = sys.argv[1]    ### new name of genome
print(genome)
old_faa = sys.argv[2]   ### path to original faa from fungap
new_faa = sys.argv[3]   ### path to save new processed faa at

record_list = list(SeqIO.parse(old_faa, 'fasta'))

with open(new_faa, 'w') as corrected:
    for i in range(len(record_list)):
        record = record_list[i]
        old_name = record.id
        num = old_name.split("_")[1][:-3]
        record.id = genome + "_" + num ## rename records to have genome name in them
        record.description = ''
        if '*' in record.seq:
            if record.seq[-1] == '*': ## remove stop codon from end of sequences
                record.seq = record.seq[:-1]
                SeqIO.write(record, corrected, 'fasta')
        else:
            SeqIO.write(record, corrected, 'fasta')
