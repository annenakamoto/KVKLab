#!/bin/bash
#SBATCH --job-name=gen_jukes_cantor
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     find Jukes-Cantor distances between one reference gene and its SCOs
###         reference: guy11
###         lineages: FJ98099 (Oryza), US71 (Setaria), B71 (Triticum), LpKY97 (Lolium), MZ5-1-6 (Eleusine)

### SETUP FILES
cd /global/scratch/users/annen/JC_gist_genomes

# RUN GFFREAD: gffread-0.12.7.Linux_x86_64/gffread -h
# gffread -g <genome_fasta> -x <coding_seqs_output_fasta> --ids <list_of_ids> <gff_file>
gffread-0.12.7.Linux_x86_64/gffread -g guy11.fasta -x guy11.cds.fasta guy11.fungap_out.gff3

#while read orthogroup; do
#    grep $orthogroup Orthogroups.txt
#done < SingleCopyOrthogroups.txt


### COMPUTE DISTANCES

### use needle to align each SCO to the reference gene and find the percent identity, then compute JC dist in python
#needle -asequence ${TE}.${GEN}.CONS.fasta  -bsequence ${TE}.${GEN}.filt_lib.fasta -outfile ${TE}.${GEN}.filt.needle -gapopen 10.0 -gapextend 0.5
#echo "*** finished needle for ${TE} ${GEN} ***"
#cat ${TE}.${GEN}.filt.needle | awk '/# Identity:/ { print $3 }' | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/simple_JC.py ${TE}.${GEN} > ${TE}.${GEN}.filt.JC.out.txt
#echo "*** finished computing JC discances ***"
