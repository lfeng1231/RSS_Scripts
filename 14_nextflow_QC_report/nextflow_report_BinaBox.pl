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

open(OUT, ">$dir/QC_metrics_summary_BinaBox.txt") || die "Cannot open OUT: $!";
print OUT "Sample\tLane_Total_Reads\t%PhiX_Reads\tSample_Total_Reads\t%Paired_Reads_Mapped\t%Reads_On-Target\tNon-dedup_Depth_Median\tNon-dedup_Depth_5th\tNon-dedup_Depth_95th\tDedup_Depth_Median\tDedup_Depth_5th\tDedup_Depth_95th\tFragment_Length_Median\tFragment_Length_5th\tFragment_Length_95th\tError_Rate\t%Bases_in_10-fold_Range\n";

#metrics: Lane_Total_Reads, Reads_Binned_to_Samples, %PhiX, %Expected_SID
my $R1 = `basename $dir/demux/phix`;
my $f1 = `basename $dir/demux/phix/qc_metrics_demux_phix.txt`;
chomp $R1;
chomp $f1;
my $total_reads;
my $pct_phix;
my $tag = 0;

open(IN, "$dir/demux/$R1/$f1") || die "Cannot open IN: $!";
while( my $record=<IN> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    if ($record =~ /^Total number of reads/)
    {
	my @line = split("\t", $record);
	my $tot = sprintf("%.0f", $line[2]/1000000+0.0000000001);
	$total_reads = $tot."M";
    }
    elsif ($record =~ /^Percentage of phix reads/)
    {
	$tag++;
	my @line = split("\t", $record);
        $pct_phix = sprintf("%.2f", $line[2]+0.0000000001);
    }
}
close IN;
if ($tag == 0)
{
    $pct_phix = 0;
}

#foreach my $name (sort { $a cmp $b || ($a =~ /(\d+)/)[0] <=> ($b =~ /(\d+)/)[0] } @files)
foreach my $name (sort {$a cmp $b} @files)
{
    if ($name =~ /^\w+/ and $name ne "fastqc" and $name ne "demux" and $name ne "validate" and $name !~ m/\.txt/ and $name !~ m/\.sh/ and $name !~ m/\.pl/)
    {
	my $sample = $name;
	my $item = $sample."\t".$total_reads."\t".$pct_phix;
	my $file_name;
	my $f;

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
		    my $sam = sprintf("%.0f", $line[2]/1000000+0.0000000001);
		    $sample_reads = $sam."M";
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


	#metrics: %Paired_Reads_Mapped
	my $paired;
	$file_name = "$dir/$sample/posSorted/qc_metrics_flagstat.txt";
	
	if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^Sorted BAM\: Fraction of properly paired aligned reads\s+number/)
		{
                    my @line = split("\t", $record);
                    $paired = sprintf("%.2f", $line[2]+0.0000000001);
		}
            }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
	    $paired = "NA";
	}
        $item = $item."\t".$paired;
	
	
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
                    $ontarget = sprintf("%.2f", $line[2]+0.0000000001);
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
	my $depth5;
	my $depth95;
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
                    $depth = sprintf("%.1f", $line[2]+0.0000000001);
		}
		elsif ($record =~ /^SORTEDBAM_DEPTH\: 5th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $depth5 = sprintf("%.1f", $line[2]+0.0000000001);
		}
		elsif ($record =~ /^SORTEDBAM_DEPTH\: 95th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $depth95 = sprintf("%.1f", $line[2]+0.0000000001);
		}
            }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
            $depth="NA";
	    $depth5="NA";
	    $depth95="NA";
	}
        $item = $item."\t".$depth."\t".$depth5."\t".$depth95;

	
	#metrics: Dedup_Depth (Average)
        my $dedup_depth;
	my $dedup_depth5;
	my $dedup_depth95;
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
                    $dedup_depth = sprintf("%.1f", $line[2]+0.0000000001);
                }
		elsif ($record =~ /^BCDEDUP_DEPTH: 5th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $dedup_depth5 = sprintf("%.1f", $line[2]+0.0000000001);
		}
		elsif ($record =~ /^BCDEDUP_DEPTH: 95th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $dedup_depth95 = sprintf("%.1f", $line[2]+0.0000000001);
		}
            }
            close IN;
        }
        else
        {
            print "$file_name not exists\n";
            $dedup_depth="NA";
	    $dedup_depth5="NA";
	    $dedup_depth95="NA";
	}
	$item = $item."\t".$dedup_depth."\t".$dedup_depth5."\t".$dedup_depth95;
	
	
	#metrics: Mean_Fragment_Length
        my $frag_len;
	my $frag_len5;
	my $frag_len95;
        $file_name = "$dir/$sample/bcDedupedQc/qc_metrics_bcdedup_fraglength.txt";
	
        if (-e $file_name)
        {
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
                chomp $record;
                $record =~ s/\r|\n//g;
                if ($record =~ /^BCDEDUP_FRAGLEN\: Median\s+number/)
                {
                    my @line = split("\t", $record);
                    $frag_len = sprintf("%.0f", $line[2]+0.0000000001);
                }
		if ($record =~ /^BCDEDUP_FRAGLEN\: 5th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $frag_len5 = sprintf("%.0f", $line[2]+0.0000000001);
		}
		if ($record =~ /^BCDEDUP_FRAGLEN\: 95th percentile\s+number/)
		{
		    my @line = split("\t", $record);
		    $frag_len95 = sprintf("%.0f", $line[2]+0.0000000001);
		}
	    }
            close IN;
        }
        else
        {
            print "$file_name not exists\n";
            $frag_len="NA";
	    $frag_len5="NA";
	    $frag_len95="NA";
        }
	$item = $item."\t".$frag_len."\t".$frag_len5."\t".$frag_len95;
	
	#metrics: %Error_Free_Positions, %Error_Rate
	my $error_rate;
	$file_name = "$dir/$sample/bgPolishedQc/qc_metrics_bgpolished_error_rate.txt";

	if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
	    while( my $record=<IN> )
	    {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^BGPOLISHED_ERRRATES\: Error rate\s+number/)
                {
                    my @line = split("\t", $record);
                    $error_rate = sprintf("%.2e", $line[2]+0.0000000001);
                }
	    }
            close IN;
	}
        else
        {
            print "$file_name not exists\n";
	    $error_rate="NA";
	}
	
	#metrics: %Bases_in_2-fold_Range, %Bases_in_10-fold_Range, Ratio_90th-pct/10th-pct
	my $fold10;
	$file_name = "$dir/$sample/posSorted/qc_metrics_coverage.txt";
	
        if (-e $file_name)
	{
            open(IN, $file_name) || die "Cannot open IN: $!";
            while( my $record=<IN> )
            {
		chomp $record;
                $record =~ s/\r|\n//g;
		if ($record =~ /^SORTEDBAM_COVUNIF\: percent bases in 10-fold range\s+number/)
                {
                    my @line = split("\t", $record);
                    $fold10 = sprintf("%.2f", $line[2]+0.0000000001);
		}
	    }
            close IN;
	}
        else
	{
            print "$file_name not exists\n";
	    $fold10="NA";
	}
	
        $item = "$item\t$error_rate\t$fold10";
	print OUT "$item\n";
    }
}

close OUT;

