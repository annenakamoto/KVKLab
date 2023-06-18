#!/bin/bash
#SBATCH --job-name=fungap
#SBATCH --partition=savio
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

SRA=${1}
genome_name=${2}
augustus_species=${3}   # magnaporthe_grisea, neurospora_crassa
busco_dataset=${4}      # sordariomycetes_odb10, dothideomycetes_odb10, saccharomycetes_odb10
working_dir=${5}    # should contain an assemblies directory, and a run_files directory containing the fastq and prot_db.faa

cd ${working_dir}
mkdir -p ${genome_name}
cd ${genome_name}

module purge
export PERL5LIB=''
## this path has to be set otherwise augustus tries to write within the singularity container
export AUGUSTUS_CONFIG_PATH=/global/scratch/users/annen/fungap_tarball/fungap_config_copy/
## this path is necessary, otherwise braker fails
export AUGUSTUS_SCRIPTS_PATH=/opt/conda/bin

## for GeneMark to work, a non-expired gm_key_64 has to be placed at ~/.gm_key (done)

singularity exec /global/scratch/users/annen/fungap_tarball/fungap.sif python /workspace/FunGAP/fungap.py \
        --output_dir fungap_out \
        --trans_read_1 ../run_files/${SRA}_1.fastq \
        --trans_read_2 ../run_files/${SRA}_2.fastq \
        --genome_assembly ../assemblies/${genome_name}.fna  \
        --augustus_species ${augustus_species}  \
        --sister_proteome ../run_files/prot_db.faa  \
        --busco_dataset ${busco_dataset} \
        --num_cores ${SLURM_NTASKS}

if [ -f fungap_out/fungap_out/fungap_out.gff3 ]; then
    echo "fungap finished, removing dirs to make space"
    rm -r busco_downloads
    cd fungap_out
    rm -r augustus_out  braker_out  busco_out  gene_filtering  hisat2_out  maker_out  repeat_modeler_out  trinity_out
fi

