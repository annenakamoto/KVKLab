#!/bin/bash
#SBATCH --job-name=CladeSplit
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

working_dir=${1}    # working directory path, where CladeSplit and Initial directories are located [CLADESPLIT]
cls_num=${2}        # the CladeSplit number (1,2,3, etc)
sp_dir=${3}         # species dir (Zm: Tuning_hvPipeline, Mo: MoOrthoFinder)
eco_cut=${4}        # specify different species ecotype cutoff (Mo: 48)
of_dir=${5}         # orthofinder results dir (Zm: Results_Mar16, Mo: Results_out)

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/${sp_dir}

next_cls_num=$((${cls_num}+1))
init_dir="Cladesplit${cls_num}_init"        # name of initial directory containing the trees and alignments to cladesplit (ie. Cladesplit1_init)
cls_dir="Cladesplit${cls_num}"              # name of the directory to output the results of the cladesplit to (ie. Cladesplit1)
new_dir="Cladesplit${next_cls_num}_init"    # name of new directory to output msa to for next cladesplit step (ie. Cladesplit2_init)

module purge

start=${6}
stop=${7}

### make alignments in range [start, stop]
ls ${working_dir}/${cls_dir} | sed -n "${start},${stop}p" | awk -v FS="_" -v n="${num}" '$n ~ /.afa/ { print substr($0,1,length($0)-4); }' | while read clade; do    
    # clade = name of a clade that has been split and made it to next cladesplit step (ie. OG0000110_216_L_149)
    OG=$(echo ${clade} | awk -v FS="_" '{ print $1; }')     # get the name of the orthogroup from the clade name
    
    ### make new fasta file of genes just in the CLADE
    module load seqtk
    fa=OrthoFinder_out/${of_dir}/Orthogroup_Sequences/${OG}.fa
    cat ${working_dir}/${cls_dir}/${clade}.afa | awk '/>/ { print substr($1, 2); }' > ${working_dir}/tmp.${clade}.list.txt
    seqtk subseq -l 60 ${fa} ${working_dir}/tmp.${clade}.list.txt > ${working_dir}/tmp.${clade}.fa
    rm ${working_dir}/tmp.${clade}.list.txt

    ### run mafft
    module load mafft
    mafft --maxiterate 1000 --localpair --thread ${SLURM_NTASKS} --quiet ${working_dir}/tmp.${clade}.fa > ${working_dir}/${new_dir}/${clade}.afa
    rm ${working_dir}/tmp.${clade}.fa

    echo "${clade} alignment finished"
done
