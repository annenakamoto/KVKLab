from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys
import os

### STDIN: list of genome names (PROTEOMES/genome_list.txt)
### works when in /global/scratch/users/annen/GENOME_TREE

GENOMES = {}
for line in sys.stdin:
    g = line[:-1]
    GENOMES[g] = SeqRecord(Seq(""), g, '', '')

msa_list = os.listdir("SCO_alignments")
for msa in msa_list:
    msa_path =  "SCO_alignments/" + msa
    for record in SeqIO.parse(msa_path, 'fasta'):
        genome = record.id.split("_")[2]
        GENOMES[genome].seq += record.seq

with open("ALL_SCOs.afa", 'w') as handle:
    for seq in GENOMES.values():
        SeqIO.write(seq, handle, 'fasta')
