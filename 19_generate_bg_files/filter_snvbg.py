#!/usr/bin/python
### SNVS
# filter out germline snps from bg file

# look at individual sample freqs
# take union of > 20% AF variants; remove those from bg file


from __future__ import division
from collections import defaultdict
import csv

snvDir = "/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool1/analysis/generate_bg_P1/snv-bg"
snvsuff = "_cfDNA.sorted.freq.paired.Q30.txt"

snvfile = "/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool1/analysis/generate_bg_P1/snv-bg/snvbg.txt"
snvfiltered = "/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool1/analysis/generate_bg_P1/snv-bg/snvbg_filtered2.txt"


# function to print to output
def writeout( var, outfilename ):
    outfile = open(outfilename, 'a')
    outfile.write("\t".join(var) + "\n")
    outfile.close()


# function to write out germline from snv freq
def germlineOut(freqfile, outfile):
    with open(freqfile, 'rb') as ffile:
        reader = csv.reader(ffile, delimiter='\t', quoting=csv.QUOTE_NONE)
        headers = reader.next()
        for row in reader:
            # sum strands
            depA = int(row[6]) + int(row[7])
            depC = int(row[8]) + int(row[9])
            depT = int(row[10]) + int(row[11])
            depG = int(row[12]) + int(row[13])
            depth = int(row[2])
            if depth!=0:
                if float(depA/depth) > 0.2:
                    writeout([row[0], row[1], row[3], "A"], outfile)
                if float(depC/depth) > 0.2:
                    writeout([row[0], row[1], row[3], "C"], outfile)
                if float(depT/depth) > 0.2:
                    writeout([row[0], row[1], row[3], "T"], outfile)
                if float(depG/depth) > 0.2:
                    writeout([row[0], row[1], row[3], "G"], outfile)
                
# function to store germline in set from snv freq
def germlineDict(freqfile, gset):
    with open(freqfile, 'rb') as ffile:
        reader = csv.reader(ffile, delimiter='\t', quoting=csv.QUOTE_NONE)
        headers = reader.next()
        for row in reader:
            # sum strands
            depA = int(row[6]) + int(row[7])
            depC = int(row[8]) + int(row[9])
            depT = int(row[10]) + int(row[11])
            depG = int(row[12]) + int(row[13])
            depth = int(row[2])
            if depth!=0:
                if float(depA/depth) > 0.2:
                    gset.add("\t".join([row[0], row[1], row[3].upper(), "A"]))
                if float(depC/depth) > 0.2:
                    gset.add("\t".join([row[0], row[1], row[3].upper(), "C"]))
                if float(depT/depth) > 0.2:
                    gset.add("\t".join([row[0], row[1], row[3].upper(), "T"]))
                if float(depG/depth) > 0.2:
                    gset.add("\t".join([row[0], row[1], row[3].upper(), "G"]))
           

samples = ["CTRL10_P1_L3", "CTRL12_P1_L3", "CTRL13_P1_L3", "CTRL19_P1_L3", "CTRL1_P1_L3", "CTRL2_P1_L3", "CTRL3_P1_L3", "CTRL4_P1_L3", "CTRL6_P1_L3", "CTRL7_P1_L3", "CTRL8_P1_L3", "CTRL9_P1_L3"]

germVar = set()

for samp in samples:
    germlineDict(snvDir + "/" + str(samp) + snvsuff, germVar)
    #germlineOut(snvDir + "Sample_Donor" + str(samp) + snvsuff, "Donor" + str(samp) + ".snps")
    

#outfile = open(snvDir + "germline.txt", 'a')
#for var in germVar:
#    outfile.write(var + "\n")
#outfile.close()   

# Chr	Pos	Ref	Var	NumPosSamples	TotalSamples	FracSamples	FracBothStrands	MeanReads	MedianReads	StdReads	MeanAF	MedianAF	StdAF	W_Shape	W_Scale	W_Corr	W_Pval


# import bg file and filter out germline
with open(snvfile, 'rb') as bfile:
    reader = csv.reader(bfile, delimiter='\t', quoting=csv.QUOTE_NONE)
    headers = reader.next()
    writeout(headers, snvfiltered)
    for row in reader:
        bgvar = "\t".join([row[0], row[1], row[2], row[3]])
        if bgvar not in germVar:
            writeout(row, snvfiltered)
            
