#!/bin/bash
#SBATCH --job-name=itol_dom_arch
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### generate itol domain tracks (following: https://colab.research.google.com/drive/1WaYbDixdeW4cqxlx1zDdvBEaxji-wI-j?authuser=1#scrollTo=T7BpAnHpIVoQ)

OG=${1}     ## specify which orthogroup

# cd /global/scratch/users/annen
# git clone https://github.com/daniilprigozhin/ProteinFamily.git

#cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline
#og_dir=OrthoFinder_out/Results_Mar16/Orthogroup_Sequences
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
og_dir=OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences

module purge
module load hmmer

## need to generate pbNB-ARC.hmmalign.afa
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
wget -O pbNB-ARC.hmm https://static-content.springer.com/esm/art%3A10.1186%2Fs13059-018-1392-6/MediaObjects/13059_2018_1392_MOESM16_ESM.hmm
hmmsearch -E 1e-5 -A pbNB-ARC.hmmalign.sto --domtblout pbNB-ARC.hmmalign.tbl ${og_dir}/${OG}.fa
esl-alimask --rf-is-mask pbNB-ARC.hmmalign.sto | esl-alimanip --lmin 100 -|esl-reformat afa - |cut -d ' ' -f 1 |tr -d ' ' > pbNB-ARC.hmmalign.afa
source deactivate

source activate /global/scratch/users/annen/anaconda3/envs/R
# cp -r ../Tuning_hvPipeline/Pfam_lib Pfam_lib
# cat Pfam_lib/Pfam-A.hmm ../../ProteinFamily/HMM_models/* > Pfam-A.plus.hmm
# hmmpress Pfam-A.plus.hmm
hmmsearch --domtblout ${OG}.Pfam.tbl Pfam-A.plus.hmm ${og_dir}/${OG}.fa
tr -s ' ' <${OG}.Pfam.tbl > ${OG}.Pfam.ws.tbl
Rscript ../../ProteinFamily/scripts/reduce_pfam.R -i ${OG}.Pfam.ws.tbl -o ${OG}.Pfam.reduced.tbl -e 1e-3 -f 0.3 -a 10
#Rscript ../../ProteinFamily/scripts/DomainDiagrams_sm.R -o ${OG}.iTOL.domains.txt -i ${OG}.Pfam.reduced.tbl -f ${og_dir}/${OG}.fa -a pbNB-ARC.hmmalign.afa
source deactivate

python ../../KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/itol_domains.py ${OG}

