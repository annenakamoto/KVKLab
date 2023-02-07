#!/bin/bash
#SBATCH --job-name=GO_PFAM_terms
#SBATCH --account=co_minium
#SBATCH --partition=savio2
#SBATCH --qos=savio_lowprio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### characterize genes in the the POT2 toplology region

cd /global/scratch/users/annen/POT2_topo_region/GO_terms

### GO term analysis
#while read GENOME; do
    ### filter the PANNZER output for PPV value of 0.6
    #cat ${GENOME}.GO.out | awk -v FS='\t' '{ if ( $6 >= 0.6 ) { print; }}' > ${GENOME}.GO.filt.out
    ### python script to construct GO term table
    ###     columns: gene_name  MF_goid BP_goid CC_goid     MF_desc BP_desc CC_desc
    #cat ${GENOME}.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/GO_table.py ${GENOME} > ${GENOME}.GO.TABLE.txt
    #cat ${GENOME}.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/common_GO_terms.py > ${GENOME}.common_GO_terms.txt

#done < genome_list.txt


### PFAM term analysis
#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
#while read GENOME; do
    ### find pfam domains in genes in POT2 topo region
    #pfam_scan.pl -fasta sec1_${GENOME}_genes.faa -dir PFAM_lib -e_dom 0.01 -e_seq 0.01 -outfile sec1_${GENOME}_genes.pfam.out
    ### parse the output
    #cat sec1_${GENOME}_genes.pfam.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_pfam.py > sec1_${GENOME}.pfam_list.out
#done < genome_list.txt
#conda deactivate


### for B71 whole proteome

### filter the PANNZER output for PPV value of 0.6
cat B71_full.GO.txt | awk -v FS='\t' '{ if ( $6 >= 0.6 ) { print; }}' > B71_full.GO.filt.out
### python script to construct GO term table
###     columns: gene_name  MF_goid BP_goid CC_goid     MF_desc BP_desc CC_desc
cat B71_full.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/GO_table.py B71 > B71_full.GO.TABLE.txt
cat B71_full.GO.filt.out | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/common_GO_terms.py > B71_full.common_GO_terms.txt


#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
### find pfam domains in genes in POT2 topo region
#pfam_scan.pl -fasta B71.faa -dir PFAM_lib -e_dom 0.01 -e_seq 0.01 -outfile B71.pfam.out
### parse the output
#cat B71.pfam.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_pfam.py > B71.pfam_list.out
#conda deactivate

