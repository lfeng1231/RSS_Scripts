#!/usr/bin/env bash
EVALUATOR=/isilon/Analysis/onco/prog/CM_gitclone/ctEval-v1.3.0/bin/Evaluator.sh
PANEL=/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed
EXON=/isilon/Analysis/onco/indexes/hg38/Bina_panel_exon.bed
BLACKLIST=/isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed

TRUTH=/isilon/Analysis/onco/projects/ctDNA_RUO_V1/milestones/DO/truth_sets/truth9_7_8.vcf
VCF=LODsample4.vcf
BREAK="0.001,0.001,.005,.005,0.1,.1,1.0"
EXPAF_NAME="expAF.1"

$EVALUATOR -T $TRUTH -P $VCF -L $PANEL -e $EXON -m $BLACKLIST -a $BREAK -A $EXPAF_NAME -v SNV -S -C > output_eval.txt
