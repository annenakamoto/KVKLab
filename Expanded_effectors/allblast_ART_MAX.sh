#!/bin/bash
#SBATCH --job-name=needle_ART_MAX
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### generate fasta files for ART & MAX effector nucleotide sequences

cd /global/scratch/users/annen/Expanded_effectors

# > FASTA/ART.fasta
# > FASTA/MAX.fasta
# while read GENOME; do
#     cat FASTA/${GENOME}.ART.fasta >> FASTA/ART.fasta
#     cat FASTA/${GENOME}.MAX.fasta >> FASTA/MAX.fasta
# done < genome_list.txt

# makeblastdb -in FASTA/ART.fasta -dbtype nucl -out ART_db
# blastn -db ART_db -query FASTA/ART.fasta -outfmt 6 -out allblast_ART.out -num_threads 24
# makeblastdb -in FASTA/MAX.fasta -dbtype nucl -out MAX_db
# blastn -db MAX_db -query FASTA/MAX.fasta -outfmt 6 -out allblast_MAX.out -num_threads 24

# echo "*** aligning ART ***"
# mafft --maxiterate 1000 --globalpair --quiet --thread 24 FASTA/ART.fasta > FASTA/ART_align.fasta
# echo "*** aligning MAX ***"
# mafft --maxiterate 1000 --globalpair --quiet --thread 24 FASTA/MAX.fasta > FASTA/MAX_align.fasta
# echo "*** done ***"

### doesn't remove enough gaps
# trimal -noallgaps -in FASTA/ART_align.fasta -out FASTA/ART_align.trim.fasta
# trimal -noallgaps -in FASTA/MAX_align.fasta -out FASTA/MAX_align.trim.fasta

### this trimming method makes the alignment look a lot better
trimal -gappyout -in FASTA/ART_align.fasta -out FASTA/ART_align.trim.gappy.fasta
trimal -gappyout -in FASTA/MAX_align.fasta -out FASTA/MAX_align.trim.gappy.fasta

### make ART and MAX trees
raxmlHPC-PTHREADS-SSE3 -s FASTA/ART_align.trim.gappy.fasta -n RAxML.ART -m GTRGAMMA -T 24 -f a -x 12345 -p 12345 -# 100
raxmlHPC-PTHREADS-SSE3 -s FASTA/MAX_align.trim.gappy.fasta -n RAxML.MAX -m GTRGAMMA -T 24 -f a -x 12345 -p 12345 -# 100
