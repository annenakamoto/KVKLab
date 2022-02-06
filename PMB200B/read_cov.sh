#!/bin/bash
#SBATCH --job-name=read_cov ## name of your job
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

module load igvtools 
# B71 
igvtools count -z 5 -w 1 SRR6232156.bam SRR6232156.tdf guy11.fna

# MZ5-1-6
igvtools count -z 5 -w 1 SRR8258942.bam SRR8258942.tdf guy11.fna
