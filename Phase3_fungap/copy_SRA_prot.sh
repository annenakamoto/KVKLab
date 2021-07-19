cd /Volumes/KVK_HD026/anne_fungap

while read dir; do
    genome=$(basename $dir)
    lineage=$(basename $(dirname $dir))
    cp SRA/${lineage}_s.fastq hq_genomes/${lineage}/${genome}
    cp /Users/pierrj/fungap_runs/guy11_template_run/prot_db.faa hq_genomes/${lineage}/${genome}
    echo "finished $genome"
done < run_tracker/did_not_complete

echo "FINISHED ALL"
