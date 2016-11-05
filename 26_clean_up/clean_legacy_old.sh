#!/usr/bin/env bash

shopt -s extglob
rm -rf trimmed
rm -rf subsample
rm -f log/trimlog.txt

#1. demultiplexed
cd demultiplexed/barcode-deduped/*/
rm -f !(*dualindex-deduped.sorted.bam*)
cd ../../../
rm -f demultiplexed/non-barcode-extracted/*
rm -f demultiplexed/*/*sorted.samtools-deduped.sorted.bam*
rm -f demultiplexed/*/*.fastq.gz

#2. cfdna-barcode-deduped
cd analysis/*barcode-deduped/adaptive
rm -rf !(Variants.adaptive-snvs.unpaired.txt)
cd ../filtered
rm -rf !(heuristic.annotated.txt)
cd ../whitelist
rm -rf !(whitelist.annotated.txt)
cd ..
rm -rf !(adaptive|filtered|whitelist|QCReport.paired.transpose.txt|*dualindex-deduped.sorted.freq.paired.Q30.rmbg.txt|*dualindex-deduped.sorted.freq.paired.Q30.txt|*dualindex-deduped.sorted.stats.paired.txt)

#3. cfdna-nondeduped
cd ../*nondeduped/fusions
rm -rf !(Variants.fusions.txt)
cd ..
rm -rf !(fusions|QCReport.paired.txt|*sorted.freq.paired.Q30.txt|*sorted.stats.paired.txt)

#4. cfdna-samtools-deduped
cd ../*samtools-deduped
rm -rf !(QCReport.paired.txt)

#5. snp-cross-comparison
cd ../snp-cross-comparison
rm -f *

#6. output
cd ../output
rm -rf !(*barcode-deduped.QCReport.paired.transpose.txt|*barcode-deduped.Variants.adaptive-snvs.unpaired.txt|*barcode-deduped.Variants.heuristic.txt|*barcode-deduped.Variants.whitelist-heuristic-combined.txt|*barcode-deduped.Variants.whitelist.txt|*nondeduped.QCReport.paired.txt|*nondeduped.Variants.fusions.txt|*samtools-deduped.QCReport.paired.txt)

#7. symlinks
cd ../../
/isilon/Analysis/onco/prog/built_packages/symlinks-master/symlinks -rc analysis
