#!/bin/sh

##################################################################
# SNV post filtering
# Usage:
#         > SNV_PostFiltering.sh panel sample
##################################################################

date
#source /home/shiny/.bashrc
source /home/users/fengl6/.bashrc
module load java/1.8.0_73

#Input files
PANEL=$1
SAMPLE=$2
VCF_CROSSCON=${SAMPLE}.crosscon.vcf

#Resource files
VT=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/vt/vt
REF=/isilon/Analysis/onco/indexes/hg38/hg38.fa
SNPEFF=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/sw_from_Bina/snpEff/snpEff.jar
SNPSIFT=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/sw_from_Bina/snpEff/SnpSift.jar
GENOMIC_REGION_DIR=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/sw_from_Bina/genomicsRegion
TR_FILE=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/resources_files_from_Bina/RUO_PAllB_snpEFF_transcript_08082016.txt
ANN_DB_BINA=/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/resources_files_from_Bina/RUO_default_annotations_08302016.vcf
REF_DB=GRCh38.82

#Intermediate files
VCF_INPUT=input_${SAMPLE}.vcf
VT_OUTPUT=vt_${SAMPLE}.vcf
ANN_SNPEFF=ann_${SAMPLE}.vcf
VCF_WITH_TRS=trs_${SAMPLE}.vcf
ANN_HAS_EFFECT=effect_${SAMPLE}.vcf
ANN_VT_BLOCK_DECOMP=vtblock_${SAMPLE}.vcf
ANN_BINA=bina_${SAMPLE}.vcf

#Output files
ANN_UNFILTERED=unfiltered_${SAMPLE}.vcf
ANN_FILTERED=filtered_${SAMPLE}.vcf

#Step 0: Sort VCF files
grep '#' $VCF_CROSSCON > tmp1.txt
grep -v '#' $VCF_CROSSCON > tmp2.txt
sort -V tmp2.txt > tmp3.txt
cat tmp1.txt tmp3.txt > $VCF_INPUT
rm tmp1.txt
rm tmp2.txt
rm tmp3.txt

#Step 1: Run vt tool
echo
echo -e "###### Step 1: Run vt tool ######"
$VT decompose -s $VCF_INPUT | $VT normalize - -r $REF | $VT uniq - -o $VT_OUTPUT
echo -e "###### Step 1 done ######"
echo

#Step 2: Run snpEff standard annotation
echo
echo -e "###### Step 2: Run snpEff standard annotation ######"
java -Xmx4g -jar $SNPEFF ann -v -nodownload \
     -filterInterval $PANEL \
     -noShiftHgvs \
     -no-downstream \
     -no-intergenic \
     -no REGULATION -no UTR_3_PRIME -no UTR_3_DELETED -no UTR_5_DELETED \
     -no TRANSCRIPT -upDownStreamLen 500\
     $REF_DB $VT_OUTPUT > $ANN_SNPEFF
echo -e "Step 2 done"
echo

#Step 4.0: Run SnpEffTranscriptFilter
echo
echo -e "###### Step 4.0: Run SnpEffTranscriptFilter ######"
java -cp "${GENOMIC_REGION_DIR}/genomics-region-3.3.0-SNAPSHOT.jar:${GENOMIC_REGION_DIR}/loomis2libs/*" com.bina.seqalto.genomics.region.GenomicsRegion SnpEffTranscriptFilter \
     --no-intron --no-intron-conserved --skip-filter-genes MET \
     --vcf $ANN_SNPEFF \
     --tr $TR_FILE \
     > $VCF_WITH_TRS
echo -e "Step 4.0 done"
echo

#Step 4.1: Run SnpSift to filter out entries with no effects and filter out upstream and 5'UTR variants except for TERT
echo
echo -e "###### Step 4.1: Run SnpSift to filter out entries with no effects ######"
java -jar $SNPSIFT filter "(((exists ANN) & ((ANN[0].EFFECT != 'upstream_gene_variant' & ANN[0].EFFECT != '5_prime_UTR_variant')) & (na WHITELIST)) | (ANN[0].GENE = 'TERT')  | ((exists ANN) & (exists WHITELIST) & (AF > 0.001) & (exists INDEL)) | ((exists ANN) & (exists WHITELIST) & (na INDEL)))" -v $VCF_WITH_TRS  > $ANN_HAS_EFFECT
echo -e "Step 4.1 done"
echo

#Step 5: Run vt tool to decompose allelic blocks
echo
echo -e "###### Step 5: Run vt tool to decompose allelic blocks ######"
$VT decompose_blocksub $ANN_HAS_EFFECT -o $ANN_VT_BLOCK_DECOMP
echo -e "Step 5 done"
echo

#Step 7: Run SnpSift against Bina annotation file
echo
echo -e "###### Step 7: Run SnpSift against Bina annotation file ######"
java -jar $SNPSIFT annotate -v $ANN_DB_BINA $ANN_VT_BLOCK_DECOMP > $ANN_BINA
echo -e "Step 7 done"
echo

#Step 8: Run SnpSift filter
echo
echo -e "###### Step 8: Run SnpSift filter ######"
FILTER1="((exists WHITELIST) | !((exists SMID) & ((EXAC_AF > 0.001) | (KG_AF > 0.001) | (DBSNP_COMMON[*] = 1))))"
FILTER2="(((( (na IN_EXAC) | (EXAC_AF_AFR < 0.001 & EXAC_AF_AMR < 0.001 & EXAC_AF_EAS < 0.001 & EXAC_AF_FIN < 0.001 & EXAC_AF_OTH < 0.001 & EXAC_AF_NFE < 0.001 & EXAC_AF_SAS < 0.001) ) & ( (na IN_KG)|(KG_AFR_AF < 0.001 & KG_AMR_AF < 0.001 & KG_EAS_AF < 0.001 & KG_EUR_AF < 0.001 & KG_SAS_AF < 0.001)) & ((DBSNP_COMMON[0] != 1 & DBSNP_COMMON[1] != 1 & DBSNP_COMMON[2] != 1 & DBSNP_COMMON[3] != 1 & DBSNP_COMMON[4] != 1) | (na DBSNP_COMMON))) & ((COSMIC_SITE_COUNT_SOMATIC[ANY] >= 1) | (TCGA_COUNT >= 1 ))) | (exists WHITELIST))"
java -jar $SNPSIFT filter -v "$FILTER1" $ANN_BINA > $ANN_UNFILTERED
java -jar $SNPSIFT filter -v "$FILTER2" $ANN_BINA > $ANN_FILTERED
echo -e "Step 8 done"
echo

#Clean up intermediate files
echo
echo -e "###### Clean up intermediate files ######"
rm $VCF_INPUT
rm $VT_OUTPUT
rm $ANN_SNPEFF
rm $VCF_WITH_TRS
rm $ANN_HAS_EFFECT
rm $ANN_VT_BLOCK_DECOMP
rm $ANN_BINA
rm snpEff_genes.txt
rm snpEff_summary.html
echo -e "Clean up done"
echo
date
