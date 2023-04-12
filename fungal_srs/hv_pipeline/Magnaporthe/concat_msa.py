from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys
import os

### STDIN: list of genome names (cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '{ print $8; }')
### works when in /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder


GENOMES = {}
for line in sys.stdin:
    g = line[:-1]
    GENOMES[g] = SeqRecord(Seq(""), g, '', '')

msa_list = os.listdir("MoBUSCO_MAFFT")
for msa in msa_list:
    msa_path =  "MoBUSCO_MAFFT/" + msa
    for record in SeqIO.parse(msa_path, 'fasta'):
        genome = record.id
        GENOMES[genome].seq += record.seq

with open("ALL_BUSCOs.afa", 'w') as handle:
    for seq in GENOMES.values():
        SeqIO.write(seq, handle, 'fasta')
