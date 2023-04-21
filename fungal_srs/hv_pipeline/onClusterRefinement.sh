#!/bin/bash
#SBATCH --job-name=Refinememt
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

working_dir=${1}    # working directory path, where Refinement and Initial directories are located [REFINEMENT]
ref_num=${2}        # the refinement number (1,2,3, etc)

next_ref_num=$((${ref_num}+1))
init_dir="Refinement${ref_num}_init"        # name of initial directory containing the trees and alignments to refine (ie. Refinement1_init)
ref_dir="Refinement${ref_num}"              # name of the directory to output the results of the refinement to (ie. Refinement1)
new_dir="Refinement${next_ref_num}_init"    # name of new directory to output msa to for next refinement step (ie. Refinement2_init)

module purge
source activate /global/scratch/users/annen/anaconda3/envs/R
### Run a Refinement step from the directories specified above and with default settings (are for Zm)
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING ${ref_dir}: ${dt}"
Rscript ../../KVKLab/fungal_srs/hv_pipeline/onCluster_AutoRefinement.R -d ${working_dir} -i ${init_dir} -r ${ref_dir}
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE ${ref_dir}: ${dt}"
source deactivate

### set up the dir/files for the next Refinement step
mkdir -p ${working_dir}/${new_dir}     # create the new refinement directory if it doesn't already exist
num=$((${ref_num}*3+1))     # Refinement1=4, Refinement2=7 , Refinement3=10 (ref_num*3 + 1) for distinguishing new clades
new_todo=$(ls ${ref_dir} | awk -v FS="_" -v n="${num}" '$n ~ /.afa/ { print substr($0,1,length($0)-4); }' | wc -l)
echo
echo "*** There are ${new_todo} split clades for next refinement step ***"
echo

ls ${ref_dir} | awk -v FS="_" -v n="${num}" '$n ~ /.afa/ { print substr($0,1,length($0)-4); }' | while read clade; do    
    # clade = name of a clade that has been split and made it to next refinement step (ie. OG0000110_216_L_149)
    OG=$(echo ${clade} | awk -v FS="_" '{ print $1; }')     # get the name of the orthogroup from the clade name
    
    ### make new fasta file of genes just in the CLADE
    module load seqtk
    fa=OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa
    cat ${working_dir}/${ref_dir}/${clade}.afa | awk '/>/ { print substr($1, 2); }' > ${working_dir}/tmp.${clade}.list.txt
    seqtk subseq -l 60 ${fa} ${working_dir}/tmp.${clade}.list.txt > ${working_dir}/tmp.${clade}.fa
    rm ${working_dir}/tmp.${clade}.list.txt

    ### run mafft
    mafft --maxiterate 1000 --localpair --thread ${SLURM_NTASKS} --quiet ${working_dir}/tmp.${clade}.fa > ${working_dir}/${new_dir}/${clade}.afa
    rm ${working_dir}/tmp.${clade}.fa

    echo "${clade} alignment finished"
done

### go and make trees from alignments in new_dir separately, then run this again for next refinement
