#!/bin/bash
#SBATCH --job-name=busco_Mo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder

# module purge
# echo "activating conda env..."
# source activate /global/scratch/users/annen/anaconda3/envs/BUSCO_phylogenomics
# echo "env activated"
# python ../../BUSCO_phylogenomics/BUSCO_phylogenomics.py -i MoBUSCO -o MoBUSCO_PHYLO -t ${SLURM_NTASKS} --supermatrix_only --gene_tree_program fasttree > BUSCO_phylogenomics.LOG.txt
# conda deactivate

### use just the faa protein fasta files from the above command (in supermatrix/proteins) and align them with mafft myself
# cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/MoBUSCO_PHYLO/supermatrix/proteins
# ls ${1}* | while read faa; do
#     mafft --maxiterate 1000 --globalpair --thread ${SLURM_NTASKS} ${faa} > ../../../MoBUSCO_MAFFT/${faa}
# done

### concatenate the alignments
# source activate /global/scratch/users/annen/anaconda3/envs/Biopython
# cat ../../KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '{ print $8; }' | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Magnaporthe/concat_msa.py
# source deactivate

### trim the alignment
# trimal -gt 1 -in ALL_BUSCOs.afa -out ALL_BUSCOs.trim.afa

### make fasttree
#source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
#fasttree -gamma -out ALL_BUSCOs.tree ALL_BUSCOs.trim.afa 
#source deactivate

module load fasttreeMP
FastTreeMP -gamma -out ALL_BUSCOs.tree.mp ALL_BUSCOs.trim.afa 
