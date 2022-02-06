#!/bin/bash
#SBATCH --job-name=smoove ## name of your job
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

conda activate lumpy
module purge ## get rid of loaded modules bc these can interfere 

# B71
smoove call --name SRR6232156 --fasta guy11.fna --processes 24 --outdir SRR6232156_smoove_out SRR6232156.bam 

zcat SRR6232156_smoove_out/SRR6232156-smoove.vcf.gz > SRR6232156.lumpy.vcf

# MZ5-1-6
smoove call --name SRR8258942 --fasta guy11.fna --processes 24 --outdir SRR8258942_smoove_out SRR8258942.bam 

zcat SRR8258942_smoove_out/SRR8258942-smoove.vcf.gz > SRR8258942.lumpy.vcf
