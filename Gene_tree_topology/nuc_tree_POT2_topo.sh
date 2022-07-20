#!/bin/bash
#SBATCH --job-name=POT2_topology
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make a nucleotide gene tree, check if it has POT2 topology

cd /global/scratch/users/annen

> treeKO_analysis/POT2_topo_NUC_tree.DATA.txt
while read OG; do
    cd /global/scratch/users/annen
    # get the orthogroup the gene is in, filter the genes in it to only contain the representative genomes + outgroup
    grep ${OG} GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups.txt | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/filter_og.py > treeKO_analysis/NUC_TREES/${OG}_genes.txt
    echo "*** made list of genes for ${OG} ***"

    # getfasta for those genes
    # bedfiles for each genome are at /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_${GENOME}.bed
    > treeKO_analysis/NUC_TREES/${OG}.fasta
    while read g; do
        GENOME=$(echo ${g} | awk -v FS='_' '{ print $3; }')
        if [ "${GENOME}" = "NI907" ]; then
            cat GENOME_TREE/PROTEOMES/NI907_nuc_cds.fasta | awk -v RS='>' -v g=${g} '$0 ~ g { print ">" substr($0, 1, length($0)-1); }' >> treeKO_analysis/NUC_TREES/${OG}.fasta
        else
            grep -m 1 ${g} Expanded_effectors/GENE_BED/genes_${GENOME}.bed > tmp${OG}.bed
            bedtools getfasta -name -fo tmp${OG}.fasta -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed tmp${OG}.bed
            cat tmp${OG}.fasta >> treeKO_analysis/NUC_TREES/${OG}.fasta
        fi
    done < treeKO_analysis/NUC_TREES/${OG}_genes.txt
    rm tmp${OG}.fasta tmp${OG}.bed
    echo "*** made fasta for ${OG} ***"

    # align fasta and trim
    mafft --maxiterate 1000 --globalpair --quiet --thread 24 treeKO_analysis/NUC_TREES/${OG}.fasta > treeKO_analysis/NUC_TREES/${OG}.align.fasta
    trimal -gappyout -in treeKO_analysis/NUC_TREES/${OG}.align.fasta -out treeKO_analysis/NUC_TREES/${OG}.align.trim.fasta
    echo "*** aligned and trimmed alignment for ${OG} ***"

    # make tree
    cd /global/scratch/users/annen/treeKO_analysis/NUC_TREES
    raxmlHPC-PTHREADS-SSE3 -s ${OG}.align.trim.fasta -n RAxML.${OG} -m GTRGAMMA -T 24 -f a -x 12345 -p 12345 -# 100
    echo "*** made tree for ${OG} ***"

    # determine if phylogeny still matches POT2 topology
    echo "*** checking ${OG} nucleotide tree for POT2 topology: ***"
    module unload python
    source activate /global/scratch/users/annen/anaconda3/envs/treeKO   # to use ete2 python module
    cat RAxML_bestTree.RAxML.${OG} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/is_nuc_pot2_topo.py ${OG} >> /global/scratch/users/annen/treeKO_analysis/POT2_topo_NUC_tree.DATA.txt
    conda deactivate
done < treeKO_analysis/POT2_topo_OG_list.txt # list of genes with POT2 topo trees
