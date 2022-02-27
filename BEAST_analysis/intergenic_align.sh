#!/bin/bash
#SBATCH --job-name=intergenic_align
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make intergenic nucleotide alignment (for BEAST)

cd /global/scratch/users/annen/GENOME_TREE

### make intergenic sequences bedfile (complement of genic bed)
# while read GENOME; do
#     ### Generate chromosome length file
#     cat hq_genomes/${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > LEN/${GENOME}.len
#     bedtools complement -i SCO_BED/SCO_${GENOME}.bed -g LEN/${GENOME}.len > INTERGENIC/int_${GENOME}.bed
#     echo "***finished ${GENOME}***"
# done < genome_list_no_out.txt

### now what to do with intergenic regions bedfiles? Do genome-wide alignments to pick out the syntenic regions, then do alignments 


### genome-wide alignments (of full genomes) to get syntenic regions (bedfile?)
cd /global/scratch/users/annen/Cactus_analysis
source activate /global/scratch/users/annen/anaconda3/envs/cactus
export PATH=$PATH:/global/scratch/users/annen/cactus-bin-v2.0.5/bin
d=$(date +"%m-%d-%y_%T")
#rm -r JOBSTORE

#cactus --binariesMode local --workDir WORKDIR JOBSTORE moryzae_seqFile.txt moryzae_wgalign.cactus.hal

### convert HAL to MAF (multiple alignment format)
#hal2maf moryzae_wgalign.cactus.hal moryzae_wgalign.cactus.maf
echo "***halValidate***"
halValidate moryzae_wgalign.cactus.hal
echo
echo "***halStats***"
halStats moryzae_wgalign.cactus.hal
echo
echo "***halSummarizeMutations***"
halSummarizeMutations moryzae_wgalign.cactus.hal

conda deactivate

