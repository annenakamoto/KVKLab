#!/usr/bin/env bash

while [ "$1" != "" ];
do
	echo "creating db for $1"
	makeblastdb -in $1.fasta -out $1 -dbtype nucl -title $1 -parse_seqids
	echo "blasting mystery seq against $1 db"
	blastn -db $1 -query mystery_sequence.fasta -out mysterBlast_$1.txt
	echo "done, output saved in mysteryBlast_$1.txt"
	shift
done
