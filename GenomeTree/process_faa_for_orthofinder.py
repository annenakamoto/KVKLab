from Bio import SeqIO
import sys
import os
import shutil
import csv

### STDIN: list of genome names (PROTEOMES/genome_list.txt)
### works when in /global/scratch/users/annen/GENOME_TREE

for line in sys.stdin:
    genome = line[:-1]
    print(genome)
    old_faa = "PROTEOMES/" + genome + ".faa"
    new_faa = "PROTEOMES_filt/" + genome + ".faa"
    record_list = list(SeqIO.parse(old_faa, 'fasta'))

    with open(new_faa, 'w') as corrected:
        for i in range(len(record_list)):
            record = record_list[i]
            record.id = 'gene_' + str(i) + '_' + genome ## rename records to have genome name in them
            record.description = ''
            if '*' in record.seq:
                if record.seq[-1] == '*': ## remove stop codon from end of sequences
                    record.seq = record.seq[:-1]
                    SeqIO.write(record, corrected, 'fasta')
            else:
                SeqIO.write(record, corrected, 'fasta')
