#!/bin/bash
#SBATCH --job-name=fungap
#SBATCH --partition=savio
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/global/scratch/users/annen/stdout_slurm/slurm-%j.out
#SBATCH --error=/global/scratch/users/annen/stderr_slurm/slurm-%j.out

GCA=${1}
SRA=${2}

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoFunGAP
mkdir ${GCA}
cd ${GCA}

module purge
export PERL5LIB=''
## this path has to be set otherwise augustus tries to write within the singularity container
export AUGUSTUS_CONFIG_PATH=/global/scratch/users/annen/fungap_tarball/fungap_config_copy/
## this path is necessary, otherwise braker fails
export AUGUSTUS_SCRIPTS_PATH=/opt/conda/bin

## for GeneMark to work, a non-expired gm_key_64 has to be placed at ~/.gm_key (done)

assembly=$(ls ../../MoGENOMES_all/${GCA}*.fna)

singularity exec /global/scratch/users/annen/fungap_tarball/fungap.sif python /workspace/FunGAP/fungap.py \
        --output_dir fungap_out \
        --trans_read_1 ../run_files/${SRA}_1.fastq \
        --trans_read_2 ../run_files/${SRA}_2.fastq \
        --genome_assembly ${assembly}  \
        --augustus_species magnaporthe_grisea  \
        --sister_proteome ../run_files/prot_db.faa  \
        --busco_dataset sordariomycetes_odb10 \
        --num_cores ${SLURM_NTASKS}

if [ -f fungap_out/fungap_out/fungap_out.gff3 ]; then
    echo "${GCA}: fungap finished, removing dirs to make space"
    rm -r busco_downloads
    cd fungap_out
    rm -r augustus_out  braker_out  busco_out  gene_filtering  hisat2_out  maker_out  repeat_modeler_out  trinity_out
fi
