#!/bin/bash
#SBATCH --job-name=syri ## name of your job
#SBATCH --partition=savio2 ## partition to use
#SBATCH --qos=savio_normal ## dont worry about it
#SBATCH --account=ic_pmb200b ## dont worry about it
#SBATCH --nodes=1 ## number of nodes used
#SBATCH --ntasks-per-node=24 ## number of cpus in the node
#SBATCH --time=24:00:00 ## max time for job
#SBATCH --mail-user=annen@berkeley.edu ## email job completion
#SBATCH --mail-type=ALL
#SBATCH --output=/global/scratch/users/annen/PMB200B_ws2/slurm_stderr/slurm-%j.out
#SBATCH --error=/global/scratch/users/annen/PMB200B_ws2/slurm_stdout/slurm-%j.out

cd /global/scratch/users/annen/PMB200B_ws2
module load seqtk

grep '>CP' MZ5-1-6.fna | awk '{ print substr($1, 2)}' > MZ5-1-6_chromnames.txt
grep '>CM' B71.fna | awk '{ print substr($1, 2)}' > B71_chromnames.txt

seqtk subseq MZ5-1-6.fna MZ5-1-6_chromnames.txt | seqtk rename - chr > MZ5-1-6_chrom_only.fasta
seqtk subseq B71.fna B71_chromnames.txt > B71_chrom_only.fasta

module purge
module load mummer
source activate /global/scratch/users/annen/anaconda3/envs/syri ## use source instead of conda

nucmer --maxmatch -p B71_v_MZ5-1-6_full -l 40 -g 90 -c 100 -b 200 -t ${SLURM_NTASKS} MZ5-1-6_chrom_only.fasta B71_chrom_only.fasta
delta-filter -m -i 90 -l 100 B71_v_MZ5-1-6_full.delta > B71_v_MZ5-1-6_full.filtered.delta
show-coords -THrd B71_v_MZ5-1-6_full.filtered.delta > B71_v_MZ5-1-6_full.filtered.coords
~/syri/syri/bin/syri -c B71_v_MZ5-1-6_full.filtered.coords -d B71_v_MZ5-1-6_full.filtered.delta -r MZ5-1-6_chrom_only.fasta -q B71_chrom_only.fasta --nc 5 --all
