#!/bin/bash

# $1 = genome directory (ex. /Volumes/KVK_HD026/anne_fungap/hq_genomes/oryza/guy11)

cd $1
genome=$(basename $1)
lineage=$(basename $(dirname $1))

echo start >> /Volumes/KVK_HD026/anne_fungap/run_tracker/${genome}_run_tracker
date '+%d/%m/%Y %H:%M:%S' >> /Volumes/KVK_HD026/anne_fungap/run_tracker/${genome}_run_tracker


if [ ! -f ${1}/fungap_out/fungap_out/fungap_out.gff3 ]; then
  python /Users/pierrj/fungap_local/FunGAP/fungap.py \
    --output_dir fungap_out \
    --trans_read_single /Volumes/KVK_HD026/anne_fungap/SRA/${lineage}_s.fastq \
    --genome_assembly ${genome}.fasta  \
    --augustus_species magnaporthe_grisea  \
    --sister_proteome /Users/pierrj/fungap_runs/guy11_template_run/prot_db.faa  \
    --busco_dataset sordariomycetes_odb10 \
    --num_cores 1 >& run.out
fi

if [ ! -f ${1}/fungap_out/fungap_out/fungap_out.gff3 ]; then
    echo $1 >> /Volumes/KVK_HD026/anne_fungap/run_tracker/did_not_complete
    echo "did not complete" >> /Volumes/KVK_HD026/anne_fungap/run_tracker/${genome}_run_tracker
fi

if [ -f ${1}/fungap_out/fungap_out/fungap_out.gff3 ]; then
  rm -r ${1}/fungap_out/maker_out/SRR8842990/maker_run1
  rm -r ${1}/fungap_out/maker_out/SRR8842990/maker_run2
  rm -r ${1}/fungap_out/maker_out/SRR8842990/maker_run3
  rm -r ${1}/fungap_out/maker_out/SRR8842990/maker_run4
fi

echo end >> /Volumes/KVK_HD026/anne_fungap/run_tracker/${genome}_run_tracker
date '+%d/%m/%Y %H:%M:%S' >> /Volumes/KVK_HD026/anne_fungap/run_tracker/${genome}_run_tracker