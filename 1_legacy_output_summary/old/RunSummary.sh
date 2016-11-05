#!/usr/bin/env bash

run_name='REDO2_FUS'

CURRENT_DIR=$(pwd)
INPUT_DIR=../analysis/output
OUTPUT_DIR=${CURRENT_DIR}
sample2barcode=../*sample2barcode.txt
nondeduped_file=*nondeduped.QCReport.paired.txt
deduped_file=*barcode-deduped.QCReport.paired.transpose.txt

awk 'NR==1{print "Name\tQC Sum.\tLane PF Reads\tSample PF Reads\tLane Share\tMapped %\tPaired %\tOn Target %\tNon-dedup. Depth\tDedup. Depth\tDup. Rate %\tMean Frag. Len.\tGenotyping LOD %\tError Free Pos. %\tError Rate %\tPeak Fam. Size\tFold Overseq"};
FNR==NR && $1!="Name" && $1!="SAMPLE" && $3$4$5$6$7$8$9$10$11$12$13 ~ /!FAIL/{qcsum2[$1]="PASS"};
FNR==NR && $1!="Name" && $1!="SAMPLE" && $3$4$5$6$7$8$9$10$11$12$13 ~ /FAIL/{qcsum2[$1]="FAIL"};
FNR==NR && $1!="Name" && $1!="SAMPLE" {samplename1[$1]=$1;laneqcreads3 = laneqcreads3+$14;sampleqcreads4[$1]=$14;percentmapped6[$1]=($16/$14)*100;percentpaired7[$1]=($20/$14)*100;percentontarget8[$1]=($25)*100;nondedupeddepth9[$1]=$26;meanfraglen12[$1]=$37;next};
FNR!=NR && $1!="Name" && $1!="SAMPLE" {split($1,n,".");printf "%s\t %s\t %.0f\t %.0f\t %.1f\t %.1f\t %.1f\t %.1f\t %.0f\t %.0f\t %.1f\t %.0f\t %.6f\t %.1f\t %.6f\t %.0f\t %.0f\n", samplename1[n[1]], qcsum2[n[1]], laneqcreads3, sampleqcreads4[n[1]], (sampleqcreads4[n[1]]/laneqcreads3)*100, percentmapped6[n[1]], percentpaired7[n[1]], percentontarget8[n[1]], nondedupeddepth9[n[1]], $25, (1-$25/nondedupeddepth9[n[1]])*100, meanfraglen12[n[1]], (log(1-0.95)/(-$25*1))*100, $91, $94, $135, $136};
' ${INPUT_DIR}/${nondeduped_file} ${INPUT_DIR}/${deduped_file} > ${OUTPUT_DIR}/${run_name}.RunSummaryTable.txt
