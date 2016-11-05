#!/usr/bin/env perl

use warnings;
use strict;

#create file names
my $dir =`pwd`;
chomp $dir;

opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

open(OUT, ">$dir/extended_QC_metrics_summary.txt") || die "Cannot open OUT: $!";
print OUT "Sample\tLane_Total_Reads\tReads_Binned_to_Samples\t%PhiX_Reads\t%Expected_SID\tSample_Total_Reads\t%Reads_Mapped\t%Paired_Reads_Mapped\t%Reads_On-Target\tNon-dedup_Depth\tDedup_Depth\tDuplication_Rate\tMean_Fragment_Length\t%Genotyping_LOD\t%Error_Free_Positions\t%Error_Rate\t%Barcode_Singleton\tPeak_Family_Size\tFold_Overseq\t%Duplex_Family\t%Duplex_Reads\tInput_Mass(ng)\tGE_Recovery_Rate\t%Bases_in_2-fold_Range\t%Bases_in_10-fold_Range\tRatio_90th-pct/10th-pct\t%Depth_Bias\t%Non-polished_Error_Rate\t%Non-polished_Error_Rate_A>C\t%Non-polished_Error_Rate_A>G\t%Non-polished_Error_Rate_A>T\t%Non-polished_Error_Rate_C>A\t%Non-polished_Error_Rate_C>G\t%Non-polished_Error_Rate_C>T\t%Non-polished_Error_Rate_G>A\t%Non-polished_Error_Rate_G>C\t%Non-polished_Error_Rate_G>T\t%Non-polished_Error_Rate_T>A\t%Non-polished_Error_Rate_T>C\t%Non-polished_Error_Rate_T>G\t%BG_Polished_Error_Rate\t%BG_Polished_Error_Rate_A>C\t%BG_Polished_Error_Rate_A>G\t%BG_Polished_Error_Rate_A>T\t%BG_Polished_Error_Rate_C>A\t%BG_Polished_Error_Rate_C>G\t%BG_Polished_Error_Rate_C>T\t%BG_Polished_Error_Rate_G>A\t%BG_Polished_Error_Rate_G>C\t%BG_Polished_Error_Rate_G>T\t%BG_Polished_Error_Rate_T>A\t%BG_Polished_Error_Rate_T>C\t%BG_Polished_Error_Rate_T>G\tError_Rate_Ratio\tError_Rate_Ratio_A>C\tError_Rate_Ratio_A>G\tError_Rate_Ratio_A>T\tError_Rate_Ratio_C>A\tError_Rate_Ratio_C>G\tError_Rate_Ratio_C>T\tError_Rate_Ratio_G>A\tError_Rate_Ratio_G>C\tError_Rate_Ratio_G>T\tError_Rate_Ratio_T>A\tError_Rate_Ratio_T>C\tError_Rate_Ratio_T>G\n";

#metrics: Lane_Total_Reads, Reads_Binned_to_Samples, %PhiX, %Expected_SID
my $R1 = `basename $dir/demux/phix`;
my $f1 = `basename $dir/demux/phix/qc_metrics_demux_phix.txt`;
chomp $R1;
chomp $f1;
my $total_reads;
my $binned_reads;
my $pct_phix;
my $pct_exp;
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
}
close IN;
if ($tag == 0)
{
    $pct_phix = 0;
}

#foreach my $name (sort { $a cmp $b || ($a =~ /(\d+)/)[0] <=> ($b =~ /(\d+)/)[0] } @files)
foreach my $name (sort {$a cmp $b} @files)
{
    if ($name =~ /^\w+/ and $name ne "fastqc" and $name ne "demux" and $name !~ m/nextflow_report/ and $name ne "validate" and $name !~ m/QC_metrics_summary/)
    {
	my $sample = $name;
	my $item = $sample."\t".$total_reads."\t".$binned_reads."\t".$pct_phix."\t".$pct_exp;
	my $file_name;

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
	my $exp_depth;
	my $delta_depth;
	
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
		elsif ($record =~ /^BCDEDUP_EFFSTATS\: Predicted mean deduped depth\s+number/)
		{
		    my @line = split("\t", $record);
		    $exp_depth = sprintf("%.1f", $line[2]);
		    my $delta = ($dedup_depth-$exp_depth)/$exp_depth;
		    $delta_depth = sprintf("%.1f", $delta*100);
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
	    $duplex_pct = "NA";
	    $duplex_eff = "NA";
	    $exp_depth = "NA";
	    $delta_depth = "NA";
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
	my $der_all;
	my $der_ac;
	my $der_ag;
	my $der_at;
	my $der_ca;
	my $der_cg;
	my $der_ct;
	my $der_ga;
	my $der_gc;
	my $der_gt;
	my $der_ta;
	my $der_tc;
	my $der_tg;
	
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
		    $der_all = $error_rate;
                }
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc A>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ac = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc A>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ag = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc A>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_at = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc C>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ca = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc C>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_cg = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc C>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ct = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc G>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ga = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc G>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_gc = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc G>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_gt = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc T>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_ta = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc T>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_tc = sprintf("%.8f", $der_all*$line[2]/100);
		}
		elsif ($record =~ /^BGPOLISHED_ERRRATES\: perc T>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $der_tg = sprintf("%.8f", $der_all*$line[2]/100);
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

	
	#metrics: Non-Polished %Error_Free_Positions, %Error_Rate
	my $ner_all;
	my $ner_ac;
	my $ner_ag;
	my $ner_at;
	my $ner_ca;
	my $ner_cg;
	my $ner_ct;
	my $ner_ga;
	my $ner_gc;
	my $ner_gt;
	my $ner_ta;
	my $ner_tc;
	my $ner_tg;
	
	$file_name = "$dir/$sample/bcDedupedQc/qc_metrics_bcdedup_error_rate.txt";

	if (-e $file_name)
	{
	    open(IN, $file_name) || die "Cannot open IN: $!";
	    while( my $record=<IN> )
	    {
		chomp $record;
		$record =~ s/\r|\n//g;
		if ($record =~ /^BCDEDUP_ERRRATES\: Error rate\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_all = sprintf("%.6f", $line[2]*100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc A>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ac = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc A>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ag = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc A>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_at = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc C>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ca = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc C>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_cg = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc C>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ct = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc G>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ga = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc G>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_gc = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc G>T substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_gt = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc T>A substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_ta = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc T>C substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_tc = sprintf("%.8f", $ner_all*$line[2]/100);
		}
		elsif ($record =~ /^BCDEDUP_ERRRATES\: perc T>G substitutions\s+number/)
		{
		    my @line = split("\t", $record);
		    $ner_tg = sprintf("%.8f", $ner_all*$line[2]/100);
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


	my $r_all = sprintf("%.3f", $der_all/$ner_all);
	my $r_ac = sprintf("%.3f", $der_ac/$ner_ac);
	my $r_ag = sprintf("%.3f", $der_ag/$ner_ag);
	my $r_at = sprintf("%.3f", $der_at/$ner_at);
	my $r_ca = sprintf("%.3f", $der_ca/$ner_ca);
	my $r_cg = sprintf("%.3f", $der_cg/$ner_cg);
	my $r_ct = sprintf("%.3f", $der_ct/$ner_ct);
	my $r_ga = sprintf("%.3f", $der_ga/$ner_ga);
	my $r_gc = sprintf("%.3f", $der_gc/$ner_gc);
	my $r_gt = sprintf("%.3f", $der_gt/$ner_gt);
	my $r_ta = sprintf("%.3f", $der_ta/$ner_ta);
	my $r_tc = sprintf("%.3f", $der_tc/$ner_tc);
	my $r_tg = sprintf("%.3f", $der_tg/$ner_tg);
	

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
	
        $item = "$item\t$dup\t$frag_len\t$lod\t$error_pos\t$error_rate\t$singleton\t$famsize\t$overseq\t$duplex_pct\t$duplex_eff\t$input\t$ge\t$fold2\t$fold10\t$ratio\t$delta_depth\t$ner_all\t$ner_ac\t$ner_ag\t$ner_at\t$ner_ca\t$ner_cg\t$ner_ct\t$ner_ga\t$ner_gc\t$ner_gt\t$ner_ta\t$ner_tc\t$ner_tg\t$der_all\t$der_ac\t$der_ag\t$der_at\t$der_ca\t$der_cg\t$der_ct\t$der_ga\t$der_gc\t$der_gt\t$der_ta\t$der_tc\t$der_tg\t$r_all\t$r_ac\t$r_ag\t$r_at\t$r_ca\t$r_cg\t$r_ct\t$r_ga\t$r_gc\t$r_gt\t$r_ta\t$r_tc\t$r_tg";
	print OUT "$item\n";
    }
}

close OUT;
