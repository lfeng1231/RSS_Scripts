#!/usr/bin/env bash

runDir=$1

du -sh $runDir

cd $runDir

shopt -s extglob
rm -rf */trimmed
rm -rf */subsample
rm -f */log/trimlog.txt

#1. demultiplexed
rm -f */demultiplexed/barcode-deduped/*/*.sorted.copies.txt
rm -f */demultiplexed/non-barcode-extracted/*
rm -f */demultiplexed/*/*sorted.samtools-deduped.sorted.bam*
rm -f */demultiplexed/*/*.fastq.gz

#2. *-barcode-deduped
rm -f */analysis/*barcode-deduped/adaptive/*Q30*
rm -f */analysis/*barcode-deduped/filtered/*Q30*
rm -f */analysis/*barcode-deduped/whitelist/*Q30*
rm -f */analysis/*barcode-deduped/*.dualindex-deduped.sorted.bam*
rm -f */analysis/*barcode-deduped/*.sorted.copies.txt
rm -f */analysis/*barcode-deduped/*.sorted_fastqc.zip
rm -rf */analysis/*barcode-deduped/*.sorted_fastqc
rm -f */analysis/*barcode-deduped/*.sorted.frag.tmp.txt
rm -f */analysis/*barcode-deduped/makeplots.R
rm -f */analysis/*barcode-deduped/*.png
rm -rf */analysis/*barcode-deduped/selectorbg
rm -f */analysis/*barcode-deduped/*.Q30.onlybg.txt
rm -rf */analysis/*barcode-deduped/duplex
rm -f */analysis/*barcode-deduped/*.snps


#3. cfdna-nondeduped
rm -f */analysis/*-nondeduped/*.factera.*
rm -f */analysis/*-nondeduped/*.sorted.bam*
rm -f */analysis/*-nondeduped/*.sorted_fastqc.zip
rm -rf */analysis/*-nondeduped/*.sorted_fastqc
rm -f */analysis/*-nondeduped/*.frag.tmp.txt
rm -f */analysis/*-nondeduped/makeplots.R
rm -f */analysis/*-nondeduped/*.png
rm -f */analysis/*-nondeduped/*.snps

#4. cfdna-samtools-deduped
rm -f */analysis/*samtools-deduped/*.sorted.bam*
rm -rf */analysis/*samtools-deduped/filtered
rm -rf */analysis/*samtools-deduped/*.sorted_fastqc
rm -rf */analysis/*samtools-deduped/selectorbg
rm -rf */analysis/*samtools-deduped/whitelist
rm -f */analysis/*samtools-deduped/*.sorted_fastqc.zip
rm -f */analysis/*samtools-deduped/makeplots.R
rm -f */analysis/*samtools-deduped/*.png
rm -f */analysis/*samtools-deduped/*.sorted.frag.tmp.txt
rm -f */analysis/*samtools-deduped/*Q30*
rm -f */analysis/*samtools-deduped/*stats*
rm -f */analysis/*samtools-deduped/*.snps

#5. snp-cross-comparison

#6. output
rm -f */analysis/output/*.png

#7. symlinks

/isilon/Analysis/onco/prog/built_packages/symlinks-master/symlinks -rc */analysis

cd ..

du -sh $runDir
