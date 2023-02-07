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
module unload python
module load mummer
module load ghostscript

cd /global/scratch/users/annen
while read GENOME; do
    bedtools getfasta -name -s -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed POT2_topo_region/sec1_${GENOME}.bed > POT2_topo_region/sec1_${GENOME}.fasta
    bedtools getfasta -name -s -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed POT2_topo_region/sec2_${GENOME}.bed > POT2_topo_region/sec2_${GENOME}.fasta
done < rep_genomes_list.txt

cd /global/scratch/users/annen/POT2_topo_region

cat genomes_pairwise_list.txt | while read pair; do
    GENOME1=$(echo ${pair} | awk '{ print $1 }')
    GENOME2=$(echo ${pair} | awk '{ print $2 }')
    ### section 1
    nucmer --maxmatch  -p sec1_${GENOME1}_v_${GENOME2} sec1_${GENOME1}.fasta sec1_${GENOME2}.fasta
    mummerplot --color -postscript -p sec1_${GENOME1}_v_${GENOME2} sec1_${GENOME1}_v_${GENOME2}.delta
    gnuplot sec1_${GENOME1}_v_${GENOME2}.gp
    ps2pdf sec1_${GENOME1}_v_${GENOME2}.ps sec1_${GENOME1}_v_${GENOME2}.pdf
    ### section 2
    nucmer --maxmatch -p sec2_${GENOME1}_v_${GENOME2} sec2_${GENOME1}.fasta sec2_${GENOME2}.fasta
    mummerplot --color -postscript -p sec2_${GENOME1}_v_${GENOME2} sec2_${GENOME1}_v_${GENOME2}.delta
    gnuplot sec2_${GENOME1}_v_${GENOME2}.gp
    ps2pdf sec2_${GENOME1}_v_${GENOME2}.ps sec2_${GENOME1}_v_${GENOME2}.pdf
done

### gene ontology analysis
cd /global/scratch/users/annen
 # grab the protein sequences of genes in each section
while read GENOME; do
    > POT2_topo_region/sec1_${GENOME}_genes.faa
    cat POT2_topo_region/sec1_${GENOME}_genes.bed | awk '{ print $4; }' | while read gene; do
        cat GENOME_TREE/PROTEOMES_filt/${GENOME}.faa | awk -v RS=">" -v g=${gene} '$0 ~ g { print ">" substr($0,1,length($0)-1); }' >> POT2_topo_region/sec1_${GENOME}_genes.faa
    done
    > POT2_topo_region/sec2_${GENOME}_genes.faa
    cat POT2_topo_region/sec2_${GENOME}_genes.bed | awk '{ print $4; }' | while read gene; do
        cat GENOME_TREE/PROTEOMES_filt/${GENOME}.faa | awk -v RS=">" -v g=${gene} '$0 ~ g { print ">" substr($0,1,length($0)-1); }' >> POT2_topo_region/sec2_${GENOME}_genes.faa
    done
done < rep_genomes_list.txt
