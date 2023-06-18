#!/bin/bash
#SBATCH --job-name=filt_zymo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### filter the Zymo genomes to remove any contigs shorter than 1 kb (1,000 bp)

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/ZYMO/1000_assemble
mkdir -p ASSEMBLIES_filt

ls | awk '/Zt/' | while read genome; do
    seqtk seq -L 1000 ${genome}/contigs.fasta > ASSEMBLIES_filt/${genome}.fna
done
