#!/usr/bin/env perl

use warnings;
use strict;

open(OUT, ">all_whitelist_depth.txt") || die "Cannot open OUT: $!";
print OUT "Experiment\tLane\tSample\tMedian_Depth_Whitelist\n";

my %P1;
open(INP1, "/isilon/Analysis/onco/indexes/hg38/whitelist_P1.txt") || die "Cannot open IN: $!";
my $n = 0;
while( my $record=<INP1> )
{
    $n++;
    chomp $record;
    $record =~ s/\r|\n//g;

    if ($n ==1)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $chr = $line[0];
	my $pos = $line[1];
	my $ref = $line[3];
	my $alt = $line[4];
	my $gene = $line[5];
	my $cosmic = $line[7];
	my $cds = $line[8];
	my $aa = $line[9];
	my $info = "$chr\t$pos\t$ref\t$alt\t$gene\t$cds\t$aa";
	my $id = "$chr-$pos";
	$P1{$id} = $info;
    }
}
close INP1;

my %P2;
open(INP2, "/isilon/Analysis/onco/indexes/hg38/whitelist_P2.txt") || die "Cannot open IN: $!";
my $m = 0;
while( my $record=<INP2> )
{
    $m++;
    chomp $record;
    $record =~ s/\r|\n//g;

    if ($m ==1)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $chr = $line[0];
	my $pos = $line[1];
	my $ref = $line[3];
	my $alt = $line[4];
	my $gene = $line[5];
	my $cosmic = $line[7];
	my $cds = $line[8];
	my $aa = $line[9];
	my $info = "$chr\t$pos\t$ref\t$alt\t$gene\t$cds\t$aa";
	my $id = "$chr-$pos";
	$P2{$id} = $info;
    }
}
close INP2;

my %P3;
open(INP3, "/isilon/Analysis/onco/indexes/hg38/whitelist_P3.txt") || die "Cannot open IN: $!";
my $k = 0;
while( my $record=<INP3> )
{
    $k++;
    chomp $record;
    $record =~ s/\r|\n//g;

    if ($k ==1)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $chr = $line[0];
	my $pos = $line[1];
	my $ref = $line[3];
	my $alt = $line[4];
	my $gene = $line[5];
	my $cosmic = $line[7];
	my $cds = $line[8];
	my $aa = $line[9];
	my $info = "$chr\t$pos\t$ref\t$alt\t$gene\t$cds\t$aa";
	my $id = "$chr-$pos";
	$P3{$id} = $info;
    }
}
close INP3;


open(IN1, "experiment_list.txt") || die "Cannot open IN: $!";
while( my $record=<IN1> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    if ($record =~ /^#/)
    {
	next;
    }
    else
    {
	my $expdir = "/isilon/Analysis/onco/v1_analyses/$record";
	my $exp = $record;
	my $date;
		
	if ($record =~ /^(\d\d\d\d)(\d\d)(\d\d)\_/)
	{
	    $date = "$2/$3/$1";
	}
	else
	{
	    $date = "NA";
	}
	
	#read lanes
	opendir(EXPDIR,$expdir);
	my @lanefiles = readdir(EXPDIR);
	closedir(EXPDIR);
	
	foreach my $lanename (sort {$a cmp $b} @lanefiles)
	{
	    if ($lanename =~ /^\w+/ and $lanename !~ m/\.txt/ and $lanename !~ /\.csv/ and $lanename !~ m/\.sh/)
	    {
		my $lane = $lanename;
		my $dir = "$expdir/$lane/analysis";

		opendir(DIR,$dir);
		my @files = readdir(DIR);
		closedir(DIR);
		
		foreach my $name (sort {$a cmp $b} @files)
		{
		    if ($name =~ /^\w+/ and $name ne "fastqc" and $name ne "demux" and $name !~ m/nextflow_report/ and $name ne "validate" and $name !~ m/QC_metrics_summary/ and $name !~ m/\.txt/)
		    {
			my $sample = $name;
			my $freq = "$dir/$sample/$sample.dualindex-deduped.sorted.bam.snv.freq";
			if (-e $freq)
			{
			    my $config = "$expdir/$lane/lane.txt";
			    my $config2 = "$expdir/$lane/lane-demux.txt";
			    my $config3 = "$expdir/$lane/run_config.txt";
			    my $panel;

			    print "\n\n****************** $exp\t$lane\t$sample ******************\n\n";
			    
			    if (-e $config)
			    {
				local $/ = undef;
				open CON, "$config" or die "Couldn't open file: $!";
				my $text = <CON>;
				close CON;
				
				if ($text =~ /RUO_P1B_capture_targets/ or $text =~ /RUO_P1A_capture_targets/)
				{
				    $panel = "P1";
				}
				elsif ($text =~ /RUO_P2B_capture_targets/ or $text =~ /RUO_P2A_capture_targets/)
				{
				    $panel = "P2";
				}
				elsif ($text =~ /RUO_P3B_capture_targets/ or $text =~ /RUO_P3A_capture_targets/)
				{
				    $panel = "P3";
				}
				else
				{
				    print "$exp\t$lane\tpanel error\n";
				    $panel = "NA";
				}
				
			    }
			    elsif (-e $config2)
			    {
				local $/ = undef;
				open CON, "$config2" or die "Couldn't open file: $!";
				my $text = <CON>;
				close CON;
				
				if ($text =~ /RUO_P1B_capture_targets/ or $text =~ /RUO_P1A_capture_targets/)
				{
				    $panel = "P1";
				}
				elsif ($text =~ /RUO_P2B_capture_targets/ or $text =~ /RUO_P2A_capture_targets/)
				{
				    $panel = "P2";
				}
				elsif ($text =~ /RUO_P3B_capture_targets/ or $text =~ /RUO_P3A_capture_targets/)
				{
				    $panel = "P3";
				}
				else
				{
				    print "$exp\t$lane\tpanel error\n";
				    $panel = "NA";
				}
			    }
			    elsif (-e $config3)
			    {
				local $/ = undef;
				open CON, "$config3" or die "Couldn't open file: $!";
				my $text = <CON>;
				close CON;

				if ($text =~ /RUO_P1B_capture_targets/ or $text =~ /RUO_P1A_capture_targets/)
				{
				    $panel = "P1";
				}
				elsif ($text =~ /RUO_P2B_capture_targets/ or $text =~ /RUO_P2A_capture_targets/)
				{
				    $panel = "P2";
				}
				elsif ($text =~ /RUO_P3B_capture_targets/ or $text =~ /RUO_P3A_capture_targets/)
				{
				    $panel = "P3";
				}
				else
				{
				    print "$exp\t$lane\tpanel error\n";
				    $panel = "NA";
				}
			    }
			    else
			    {
				print "$exp\t$lane\t$sample\tconfig not found\n";
			    }
			    
			    open(FREQ, $freq) || die "Cannot open IN: $!";
			    my @alldep;
			    my @vdep;
			    my $test = 0;
			    my $j =0;
			    while( my $rec=<FREQ> )
			    {
				$j++;
				chomp $rec;
				$rec =~ s/\r|\n//g;
				
				if ($j == 1)
				{
				    next;
				}
				else
				{
				    my @row = split("\t", $rec);
				    my $chr = $row[0];
				    my $pos = $row[1];
				    my $ref = uc($row[3]);
				    my $totaldep = $row[2];
				    my $id = "$chr-$pos";
				    
				    if ($panel eq "P1")
				    {
					if (exists $P1{$id})
					{
					    push @alldep, $totaldep;
					}
				    }
				    elsif ($panel eq "P2")
				    {
					if (exists $P2{$id})
					{
					    push @alldep, $totaldep;
					}
				    }
				    elsif ($panel eq "P3")
				    {
					if (exists $P3{$id})
					{
					    push @alldep, $totaldep;
					}
				    }
				}
			    }
			    my $medtotal = &median(@alldep);
			    print OUT "$exp\t$lane\t$sample\t$medtotal\n";
			}
		    }
		}
	    }
	}
    }
}

close IN1;
close OUT;


sub median
{
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;
    if($len%2) #odd?
    {
	return $vals[int($len/2)];
    }
    else #even
    {
	return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}
