#!/usr/bin/env perl

use warnings;
use strict;

#########################################################
# Usage: In the "analysis" folder:
#         > perl nextflow_report.pl
#########################################################

#create file names
my $dir =`pwd`;
chomp $dir;

opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

open(OUT, ">$dir/QC_metrics_summary.txt") || die "Cannot open OUT: $!";
print OUT "Sample\tLane_Total_Reads\tReads_Binned_to_Samples\t%PhiX_Reads\t%Reads_Binned_to_Samples_Post_PhiX\t%Expected_SID\t%Adapter_R1\t%Adapter_R2\tSample_Total_Reads\t%Reads_Mapped\t%Paired_Reads_Mapped\t%Reads_On-Target\tNon-dedup_Depth\tDedup_Depth\tDuplication_Rate\tMean_Fragment_Length\t%Genotyping_LOD\t%Error_Free_Positions\t%Error_Rate\t%Barcode_Singleton\tPeak_Family_Size\tFold_Overseq\t%Duplex_Family\t%Duplex_Reads\tInput_Mass(ng)\tGE_Recovery_Rate\t%Bases_in_2-fold_Range\t%Bases_in_10-fold_Range\tRatio_90th-pct/10th-pct\t%Panel_Region_Dedup_Depth>=2000\n";

#metrics: Lane_Total_Reads, Reads_Binned_to_Samples, %PhiX, %Expected_SID
my $R1 = `basename $dir/demux/phix`;
my $f1 = `basename $dir/demux/phix/qc_metrics_demux_phix.txt`;
chomp $R1;
chomp $f1;
my $total_reads;
my $binned_reads;
my $pct_phix;
my $pct_exp;
my $pct_binned;
my $tag = 0;

open(IN, "$dir/demux/$R1/$f1") || die "Cannot open IN: $!";
while( my $record=<IN> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    if ($record =~ /^Total number of reads/)
    {
	my @line = split("\t", $record);
	$total_reads = $line[2] *2;
    }
    elsif ($record =~ /^Number of reads binned to samples/)
    {
	my @line = split("\t", $record);
	$binned_reads = $line[2] *2;
    }
    elsif ($record =~ /^Fraction of reads with expected barcodes/)
    {
	my @line = split("\t", $record);
        $pct_exp = sprintf("%.3f", $line[2]*100);
    }
    elsif ($record =~ /^Percentage of phix reads/)
    {
	$tag++;
	my @line = split("\t", $record);
        $pct_phix = sprintf("%.1f", $line[2]);
    }
    elsif ($record =~ /^Percentage of reads binned to samples/)
    {
	$tag++;
	my @line = split("\t", $record);
	$pct_binned = sprintf("%.1f", $line[2]);
    }
}
close IN;
if ($tag == 0)
{
    $pct_phix = 0;
    $pct_binned = "100.0";
}

#foreach my $name (sort { $a cmp $b || ($a =~ /(\d+)/)[0] <=> ($b =~ /(\d+)/)[0] } @files)
foreach my $name (sort {$a cmp $b} @files)
{
    if ($name =~ /^\w+/ and $name ne "fastqc" and $name ne "demux" and $name ne "validate" and $name !~ m/\.txt/ and $name !~ m/\.sh/ and $name !~ m/\.pl/)
    {
	my $sample = $name;
	my $item = $sample."\t".$total_reads."\t".$binned_reads."\t".$pct_phix."\t".$pct_binned."\t".$pct_exp;
	my $file_name;
	my $f;

	#metrics: %Adapter_R1, %Adapter_R2
	my $adapter1;
	my $adapter2;
	$f = `basename $dir/$sample/fastqc/*R1*data.txt`;
	chomp $f;
	$file_name = "$dir/$sample/fastqc/$f";

	if (-e $file_name)
	{
	    open(IN, $file_name) || die "Cannot open IN: $!";
	    my($save_input_separator) = $/;
	    $/ = ">>END_MODULE";
	    
	    while( my $record=<IN> )
	    {
		chomp $record;
		if ($record =~ /\>\>Adapter Content.*\n84\s+(\S+)\s+/s)
		{
		    $adapter1 = sprintf("%.2f", $1);
		}
	    }
	    close IN;
	    $/ = $save_input_separator;
	}
	else
	{
	    print "$file_name not exists\n";
	    $adapter1 = "NA";
	}
	
	$f = `basename $dir/$sample/fastqc/*R2*data.txt`;
	chomp $f;
	$file_name = "$dir/$sample/fastqc/$f";

	if (-e $file_name)
	{
	    open(IN, $file_name) || die "Cannot open IN: $!";
	    my($save_input_separator) = $/;
	    $/ = ">>END_MODULE";
	    
	    while( my $record=<IN> )
	    {
		chomp $record;
		if ($record =~ /\>\>Adapter Content.*\n84\s+(\S+)\s+/s)
		{
		    $adapter2 = sprintf("%.2f", $1);
		}
	    }
	    close IN;
	    $/ = $save_input_separator;
	}
	else
	{
	    print "$file_name not exists\n";
	    $adapter2 = "NA";
	}
	
	$item = $item."\t".$adapter1."\t".$adapter2;

	#metrics: Sample_Total_Reads
	my $sample_reads;
	$file_name = "$dir/$sample/bcExtract/qc_metrics_barcode.txt";

	if (-e $file_name)
	{
	    open(IN, $file_name) || die "Cannot open IN: $!";
	    while( my $record=<IN> )
	    {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^Number of read pairs\s+number/)
		{
		    my @line = split("\t", $record);
		    $sample_reads = $line[2] *2;
		}
	    }
	    close IN;
	}
	else
	{
	    print "$file_name not exists\n";
	    $sample_reads = "NA";
	}
	$item = $item."\t".$sample_reads;


	#metrics: %Reads_Mapped, %Paired_Reads_Mapped
        my $mapped;
	my $paired;
	$file_name = "$dir/$sample/posSorted/qc_metrics_flagstat.txt";

	if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^Sorted BAM\: Percentage of aligned reads\s+number/)
		{
                    my @line = split("\t", $record);
                    $mapped = sprintf("%.1f", $line[2]);
		}
		elsif ($record =~ /^Sorted BAM\: Fraction of properly paired aligned reads\s+number/)
		{
                    my @line = split("\t", $record);
                    $paired = sprintf("%.1f", $line[2]);
		}
            }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
            $mapped = "NA";
	    $paired = "NA";
	}
        $item = $item."\t".$mapped."\t".$paired;


	#metrics: %Reads_On-Target
        my $ontarget;
        $file_name = "$dir/$sample/posSorted/qc_metrics_ontarget.txt";

	if (-e $file_name)
        {
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
                chomp $record;
                $record =~ s/\r|\n//g;
                if ($record =~ /^sortedbam\: On-target rate\s+number/)
                {
                    my @line = split("\t", $record);
                    $ontarget = sprintf("%.1f", $line[2]);
                }
	    }
            close IN;
	}
        else
        {
            print "$file_name not exists\n";
            $ontarget="NA";
        }
        $item = $item."\t".$ontarget;
	
	
	#metrics: Non-dedup_Depth (Average)
	my $depth;
	$file_name = "$dir/$sample/posSorted/qc_metrics_depth.txt";
	
        if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
                $record =~ s/\r|\n//g;
                if ($record =~ /^SORTEDBAM_DEPTH\: Median\s+number/)
		{
                    my @line = split("\t", $record);
                    $depth = sprintf("%.1f", $line[2]);
		}
            }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
            $depth="NA";
	}
        $item = $item."\t".$depth;

	
	#metrics: Dedup_Depth (Average)
        my $dedup_depth;
        $file_name = "$dir/$sample/bcDedupedQc/qc_metrics_bcdedup_depth.txt";
	
	if (-e $file_name)
        {
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
                chomp $record;
                $record =~ s/\r|\n//g;
                if ($record =~ /^BCDEDUP_DEPTH: Median\s+number/)
                {
                    my @line = split("\t", $record);
                    $dedup_depth = sprintf("%.1f", $line[2]);
                }
            }
            close IN;
        }
        else
        {
            print "$file_name not exists\n";
            $dedup_depth="NA";
	}
	$item = $item."\t".$dedup_depth;
	
	
	#metrics: Duplication_Rate, %Genotyping_LOD, %Barcode_Singleton, Peak_Family_Size, Fold_Overseq, Input_Mass(ng), GE_Recovery_Rate, %Duplex_Family, Duplex_Efficiency
	my $dup;
	my $singleton;
	my $famsize;
	my $overseq;
	my $lod;
	my $input;
	my $ge;
	my $duplex_pct;
	my $duplex_eff;
	
	$file_name = "$dir/$sample/bcDedupedQc/qc_metrics_bcdedup_efficiency.txt";

	if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
                $record =~ s/\r|\n//g;
		
		if ($record =~ /^BCDEDUP_EFFSTATS\: % of barcode singletons\s+number/)
		{
		    my @line = split("\t", $record);
		    $singleton = sprintf("%.2f", $line[2]);
		}
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Peak family size\s+number/)
		{
                    my @line = split("\t", $record);
                    $famsize = $line[2];
		}
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Fold oversequencing\s+number/)
                {
                    my @line = split("\t", $record);
                    $overseq = sprintf("%.2f", $line[2]);
                }
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Fraction of duplex families\s+number/)
		{
		    my @line = split("\t", $record);
		    $duplex_pct = sprintf("%.1f", $line[2]*100);
		}
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: duplex efficiency\s+number/)
		{
		    my @line = split("\t", $record);
		    $duplex_eff = sprintf("%.1f", $line[2]*100);
		}
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Genotyping LOD %\s+number/)
                {
                    my @line = split("\t", $record);
                    $lod = sprintf("%.3f", $line[2]);
                }
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Expected duplication rate\s+number/)
                {
                    my @line = split("\t", $record);
                    $dup = sprintf("%.1f", $line[2]*100);
                }
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: input genome equivalents\s+number/)
                {
                    my @line = split("\t", $record);
                    $input = $line[2]/330;
                }
		elsif ($record =~ /^BCDEDUP_EFFSTATS: GE recovery rate\s+number/)
                {
                    my @line = split("\t", $record);
                    $ge = sprintf("%.3f", $line[2]);
                }
	    }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
            $dup = "NA";
	    $singleton = "NA";
	    $famsize="NA";
	    $overseq = "NA";
	    $lod = "NA";
	    $input = "NA";
	    $ge = "NA";
	}
	
	
	#metrics: Mean_Fragment_Length
        my $frag_len;
        $file_name = "$dir/$sample/posSorted/qc_metrics_fraglength.txt";
	
        if (-e $file_name)
        {
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
                chomp $record;
                $record =~ s/\r|\n//g;
                if ($record =~ /^SORTEDBAMFRAGLEN\: Average\s+number/)
                {
                    my @line = split("\t", $record);
                    $frag_len = sprintf("%.1f", $line[2]);
                }
            }
            close IN;
        }
        else
        {
            print "$file_name not exists\n";
            $frag_len="NA";
        }
	
	#metrics: %Error_Free_Positions, %Error_Rate
	my $error_pos;
	my $error_rate;
	$file_name = "$dir/$sample/bgPolishedQc/qc_metrics_bgpolished_error_rate.txt";

	if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
	    while( my $record=<IN> )
	    {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^BGPOLISHED_ERRRATES\: Percentage of positions without errors\s+number/)
		{
		    my @line = split("\t", $record);
		    $error_pos = sprintf("%.1f", $line[2]);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: Error rate\s+number/)
                {
                    my @line = split("\t", $record);
                    $error_rate = sprintf("%.6f", $line[2]*100);
                }
	    }
            close IN;
	}
        else
        {
            print "$file_name not exists\n";
            $error_pos="NA";
	    $error_rate="NA";
	}
	
	#metrics: %Bases_in_2-fold_Range, %Bases_in_10-fold_Range, Ratio_90th-pct/10th-pct
	my $fold2;
	my $fold10;
	my $ratio;
	$file_name = "$dir/$sample/bcDedupedQc/qc_metrics_bcdedup_coverage.txt";
	
        if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
                $record =~ s/\r|\n//g;
		if ($record =~ /^BCDEDUP_COVUNIF\: percent bases in 2-fold range\s+number/)
		{
                    my @line = split("\t", $record);
                    $fold2 = sprintf("%.2f", $line[2]);
		}
                elsif ($record =~ /^BCDEDUP_COVUNIF\: percent bases in 10-fold range\s+number/)
                {
                    my @line = split("\t", $record);
                    $fold10 = sprintf("%.2f", $line[2]);
		}
		elsif ($record =~ /^BCDEDUP_COVUNIF\: Ratio of 90th percentile to 10th percentile \(bases\)\s+number/)
		{
                    my @line = split("\t", $record);
                    $ratio = sprintf("%.2f", $line[2]);
		}
            }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
            $fold2="NA";
            $fold10="NA";
	    $ratio="NA";
	}

	#metrics: %Panel_Region_Dedup_Depth>=2000
	my $dep2000;
	$file_name = "$dir/$sample/${sample}.dualindex-deduped.sorted.bam.snv.target.freq";
	if (-e $file_name)
	{
	    $dep2000 = &pct_depth_2000($file_name);
	}
	else
	{
	    print "$file_name not exists\n";
	    $dep2000 = "NA";
	}
	
        $item = "$item\t$dup\t$frag_len\t$lod\t$error_pos\t$error_rate\t$singleton\t$famsize\t$overseq\t$duplex_pct\t$duplex_eff\t$input\t$ge\t$fold2\t$fold10\t$ratio\t$dep2000";
	print OUT "$item\n";
    }
}

close OUT;

#########################################################################
# Subroutine to calculate %panel region dedup depth >=2000
sub pct_depth_2000
{
    my ($freq) = @_;
    
    open(IN, $freq) || die "Cannot open IN: $!";
    my $n = 0;
    my $total = 0;
    my $over2000=0;
    while( my $record=<IN> )
    {
	$n++;
	if ($n ==1)
	{
	    next;
	}
	else
	{
	    $total++;
	    chomp $record;
	    $record =~ s/\r|\n//g;
	    my @line = split("\t", $record);
	    my $dep = $line[2];
	    if ($dep >=2000)
	    {
		$over2000++;
	    }
	}
    }
    close IN;
    
    my $dep2000 = sprintf("%.1f", $over2000/$total*100);
    return($dep2000);
}
