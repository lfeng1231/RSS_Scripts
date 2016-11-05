#!/usr/bin/env bash

rm -rf work
rm -rf analysis/validate
rm -f analysis/demux/subsample*/*.fastq.gz
rm -f analysis/demux/*/*fastq
rm -f analysis/demux/*/*fq

rm -f analysis/*/*indels*
rm -f analysis/*/*deduped.bam.snv.freq
rm -f analysis/*/*duplex.sorted.bam
rm -f analysis/*/*duplex.sorted.bam.bai
rm -f analysis/*/*barcode-copies.txt
rm -f analysis/*/*deduped.bam*
rm -f analysis/*/*MIDtrimmed.bam*

rm -f analysis/*/bcExtract/*.fastq

rm -f analysis/*/fastqc/*.fastq
rm -f analysis/*/fastqc/*.txt
rm -f analysis/*/fastqc/*.zip

#rm -f analysis/*/fusion/*.bam
#rm -f analysis/*/fusion/*.bed
