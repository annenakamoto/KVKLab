#!/bin/bash
#SBATCH --job-name=visualize_TEs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### characterize genes in the the POT2 toplology region

cd /global/scratch/users/annen

cd /global/scratch/users/annen/POT2_topo_region
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_B71.bed -b sec1_B71.bed > sec1_B71_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_B71.bed -b sec2_B71.bed > sec2_B71_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_guy11.bed -b sec1_guy11.bed > sec1_guy11_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_guy11.bed -b sec2_guy11.bed > sec2_guy11_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_US71.bed -b sec1_US71.bed > sec1_US71_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_US71.bed -b sec2_US71.bed > sec2_US71_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_LpKY97.bed -b sec1_LpKY97.bed > sec1_LpKY97_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_LpKY97.bed -b sec2_LpKY97.bed > sec2_LpKY97_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_MZ5-1-6.bed -b sec1_MZ5-1-6.bed > sec1_MZ5-1-6_genes.bed
bedtools intersect -wa -a /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_MZ5-1-6.bed -b sec2_MZ5-1-6.bed > sec2_MZ5-1-6_genes.bed

### add the orthogroup to each bed file
ls *genes.bed > gene_bed_list.txt
while read f; do
    > ${f}.OG
    while read line; do
        GENE=$(echo $line | awk '{ print $4; }')
        OG=$(grep ${GENE} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
        echo -e "${line}\t${OG}" >> ${f}.OG
    done < ${f}
done < gene_bed_list.txt


### make data files containing effector structural group info
### B71
> sec1_B71.DATA.txt
while read GENE; do
    GENE_NAME=$(echo -e ${GENE} | awk '{ print $4; }')
    OG=$(grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
    grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v RS=' ' '{ print; }' | while read g; do
        if [[ ${g} == *"MGG"* ]]; then
            ### see if g is in Kyunyong's spreadsheet
            MGG=${g}
            DATA=$(grep ${g} Magnaporthe_Oryza_Structure_prediction.txt | awk -v FS='\t' -v OFS='\t' '{ print $1, $22; }')
            if [ -z "${DATA}" ]; then
                #is empty
                DATA=$(echo -e ".\t.\t.")
            fi
            ### list the GENE, OG, MGG_gene(g), struct_group, description > sec1_B71.DATA.txt
            echo -e "${GENE}\t${OG}\t${MGG}\t${DATA}" >> sec1_B71.DATA.txt
        fi
    done
done < sec1_B71_genes.bed

> sec2_B71.DATA.txt
while read GENE; do
    GENE_NAME=$(echo -e ${GENE} | awk '{ print $4; }')
    OG=$(grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
    grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v RS=' ' '{ print; }' | while read g; do
        if [[ ${g} == *"MGG"* ]]; then
            ### see if g is in Kyunyong's spreadsheet
            MGG=${g}
            DATA=$(grep ${g} Magnaporthe_Oryza_Structure_prediction.txt | awk -v FS='\t' -v OFS='\t' '{ print $1, $22; }')
            if [ -z "${DATA}" ]; then
                #is empty
                DATA=$(echo -e ".\t.\t.")
            fi
            ### list the GENE, OG, MGG_gene(g), struct_group, description > sec2_B71.DATA.txt
            echo -e "${GENE}\t${OG}\t${MGG}\t${DATA}" >> sec2_B71.DATA.txt
        fi
    done
done < sec2_B71_genes.bed

### guy11
> sec1_guy11.DATA.txt
while read GENE; do
    GENE_NAME=$(echo -e ${GENE} | awk '{ print $4; }')
    OG=$(grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
    grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v RS=' ' '{ print; }' | while read g; do
        if [[ ${g} == *"MGG"* ]]; then
            ### see if g is in Kyunyong's spreadsheet
            MGG=${g}
            DATA=$(grep ${g} Magnaporthe_Oryza_Structure_prediction.txt | awk -v FS='\t' -v OFS='\t' '{ print $1, $22; }')
            if [ -z "${DATA}" ]; then
                #is empty
                DATA=$(echo -e ".\t.\t.")
            fi
            ### list the GENE, OG, MGG_gene(g), struct_group, description > sec1_guy11.DATA.txt
            echo -e "${GENE}\t${OG}\t${MGG}\t${DATA}" >> sec1_guy11.DATA.txt
        fi
    done
done < sec1_guy11_genes.bed

> sec2_guy11.DATA.txt
while read GENE; do
    GENE_NAME=$(echo -e ${GENE} | awk '{ print $4; }')
    OG=$(grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
    grep ${GENE_NAME} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -v RS=' ' '{ print; }' | while read g; do
        if [[ ${g} == *"MGG"* ]]; then
            ### see if g is in Kyunyong's spreadsheet
            MGG=${g}
            DATA=$(grep ${g} Magnaporthe_Oryza_Structure_prediction.txt | awk -v FS='\t' -v OFS='\t' '{ print $1, $22; }')
            if [ -z "${DATA}" ]; then
                #is empty
                DATA=$(echo -e ".\t.\t.")
            fi
            ### list the GENE, OG, MGG_gene(g), struct_group, description > sec2_guy11.DATA.txt
            echo -e "${GENE}\t${OG}\t${MGG}\t${DATA}" >> sec2_guy11.DATA.txt
        fi
    done
done < sec2_guy11_genes.bed

### determine PAV of orthogroups to see what changes have occurred in this region in different lineages
cat sec1*.OG | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/region_pav.py > sec1_PAV.DATA.txt
cat sec2*.OG | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/region_pav.py > sec2_PAV.DATA.txt

### make mummer plots to visualize the regions synteny to each other
