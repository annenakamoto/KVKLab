#!/bin/bash
#SBATCH --job-name=POT2_topo_region_tree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make a nucleotide gene tree of all SCO genes in the POT2 topo region to see if overall it matches POT2 topo

cd /global/scratch/users/annen

### bedtools intersect to get all genes in the region
echo -e "CM015706.1\t277198\t1308036\tB71_pot2_topo_region" > treeKO_analysis/B71_pot2_topo_region.bed
bedtools intersect -wa -a Expanded_effectors/GENE_BED/genes_B71.bed -b treeKO_analysis/B71_pot2_topo_region.bed > treeKO_analysis/B71_pot2_topo_region_genes.bed

cat treeKO_analysis/B71_pot2_topo_region_genes.bed | awk '{ print $4; }' | while read GENE; do
    cd /global/scratch/users/annen
    # get the orthogroup the gene is in, filter the genes in it to only contain the representative genomes + outgroup, and make sure its a SCO
    OG=$(grep ${GENE} GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups.txt | awk -v FS=":" '{ print $1; }')
    grep ${OG} GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups.txt | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/filter_og_region.py > treeKO_analysis/REGION_TREE/${OG}_genes.txt
    if [ -s treeKO_analysis/REGION_TREE/${OG}_genes.txt ]; then # only continue if the file isn't empty
        echo "*** made list of genes for ${OG} ***"
        ### getfasta for those genes
        ### bedfiles for each genome are at /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_${GENOME}.bed
        > treeKO_analysis/REGION_TREE/${OG}.fasta
        while read g; do
        GENOME=$(echo ${g} | awk -v FS='_' '{ print $3; }')
        if [ "${GENOME}" = "NI907" ]; then
            cat GENOME_TREE/PROTEOMES/NI907_nuc_cds.fasta | awk -v RS='>' -v g=${g} '$0 ~ g { print ">" substr($0, 1, length($0)-1); }' >> treeKO_analysis/REGION_TREE/${OG}.fasta
        else
            grep -m 1 ${g} Expanded_effectors/GENE_BED/genes_${GENOME}.bed > tmp${OG}.bed
            bedtools getfasta -name -fo tmp${OG}.fasta -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed tmp${OG}.bed
            cat tmp${OG}.fasta >> treeKO_analysis/REGION_TREE/${OG}.fasta
        fi
        done < treeKO_analysis/REGION_TREE/${OG}_genes.txt
        rm tmp${OG}.fasta tmp${OG}.bed
        echo "*** made fasta for ${OG} ***"

        # align fasta and trim
        mafft --maxiterate 1000 --globalpair --quiet --thread 24 treeKO_analysis/REGION_TREE/${OG}.fasta > treeKO_analysis/REGION_TREE/${OG}.align.fasta
        trimal -gappyout -in treeKO_analysis/REGION_TREE/${OG}.align.fasta -out treeKO_analysis/REGION_TREE/MSA/${OG}.align.trim.fasta
        echo "*** aligned and trimmed alignment for ${OG} ***"
    else
        echo "*** ${OG} was not an SCO ***"
    fi
done

# concatenate the MSAs
> treeKO_analysis/REGION_TREE/REGION.afa
source activate /global/scratch/users/annen/anaconda3/envs/Biopython
cat rep_genomes_list.txt | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/concat_msa.py
conda deactivate

# make tree
cd /global/scratch/users/annen/treeKO_analysis/REGION_TREE
raxmlHPC-PTHREADS-SSE3 -s REGION.afa -n RAxML.REGION -m GTRGAMMA -T 24 -f a -x 12345 -p 12345 -# 100
echo "*** made tree ***"

# determine if phylogeny still matches POT2 topology
echo "*** checking tree for POT2 topology: ***"
module unload python
source activate /global/scratch/users/annen/anaconda3/envs/treeKO   # to use ete2 python module
cat RAxML_bestTree.RAxML.REGION | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/is_nuc_pot2_topo.py REGION
conda deactivate


