#!/bin/bash
#SBATCH --job-name=GO_PFAM_terms
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### characterize genes in the the POT2 toplology region

cd /global/scratch/users/annen/POT2_topo_region/GO_terms

### GO term analysis
while read GENOME; do
    ### filter the PANNZER output for PPV value of 0.6
    #cat ${GENOME}.GO.out | awk -v FS='\t' '{ if ( $6 >= 0.6 ) { print; }}' > ${GENOME}.GO.filt.out
    ### python script to construct GO term table
    ###     columns: gene_name  MF_goid BP_goid CC_goid     MF_desc BP_desc CC_desc
    #cat ${GENOME}.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/GO_table.py ${GENOME} > ${GENOME}.GO.TABLE.txt
    cat ${GENOME}.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/common_GO_terms.py > ${GENOME}.common_GO_terms.txt

done < genome_list.txt

### PFAM term analysis

