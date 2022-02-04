#!/bin/bash
#SBATCH --job-name=prep_bam ## name of your job
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

cd /global/scratch/users/annen/PMB200B_ws2 ## add the directory where reads and genome are here
module load samtools

# B71
mv SRR6232156.bam SRR6232156.preprocessed # renaming bam file
# should be one line
java -jar /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/picard/2.9.0/lib/picard.jar SortSam I=SRR6232156.preprocessed O=SRR6232156.sorted SORT_ORDER=coordinate
# also one line
java -jar /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/picard/2.9.0/lib/picard.jar MarkDuplicates I=SRR6232156.sorted O=SRR6232156.bam M=SRR6232156.marked_dup_metrics
samtools index SRR6232156.bam
samtools faidx guy11.fna

# MZ5-1-6
mv SRR8258942.bam SRR8258942.preprocessed # renaming bam file
# should be one line
java -jar /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/picard/2.9.0/lib/picard.jar SortSam I=SRR8258942.preprocessed O=SRR8258942.sorted SORT_ORDER=coordinate
# also one line
java -jar /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/picard/2.9.0/lib/picard.jar MarkDuplicates I=SRR8258942.sorted O=SRR8258942.bam M=SRR8258942.marked_dup_metrics
samtools index SRR8258942.bam
samtools faidx guy11.fna
