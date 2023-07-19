#!/bin/bash
#SBATCH --job-name=te_content_unfilt
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### compare TE content with/wothout filtering for TE domains

cd /global/scratch/users/annen/Rep_TE_Lib

GENOME=$1

source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler
RepeatClassifier -consensi REPLIB_clust.fasta -pa ${SLURM_NTASKS}
conda deactivate

### run RepeatMasker on GENOME using REPLIB_clust.fasta, which is the TE library before domain filtering
#module load RepeatMasker
#RepeatMasker -lib REPLIB_clust.fasta -dir RepeatMasker_out_rev -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc hq_genomes/$GENOME.fasta

