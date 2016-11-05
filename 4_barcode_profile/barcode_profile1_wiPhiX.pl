#!/usr/bin/env perl

use warnings;
use strict;

#create file names
my $dir = `pwd`;
chomp $dir;
my $s2b = "/isilon/Analysis/onco/cappmed_analyses/20151109_A102_Dan_Pred_SNV_FUS/PRED5_norm_SNV/PRED5_SNV_sample2barcode.txt";
my $R1_gz = "/isilon/Data/external_data/elim/11092015/PRED5_SNV_lane4/PRED5_SNV_lane4_Undetermined_L004_R1_001.fastq.gz";
my $R1;
my @name = split("/", $R1_gz);
my $rgz = $name[@name-1];

if ($rgz =~ /(\S+)\.gz/)
{
    my @name = split("/", $R1_gz);
    $R1 = $1;
}
else
{
    print "R1 format error";
    exit;
}

my $position = 1; #0 if barcode is on left side of sequence tag; 1 if on right
my $bases = 4; #size of SID


#1. create %SID24 to store 24 SIDs
my %SID24;
open(IN1, "/isilon/Analysis/onco/barcodes/sample_barcodes_24_adapter_v2.txt") || die "Cannot open IN: $!";
while( my $record=<IN1> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $idx = $line[0];
    my $sid = $line[1];
    $SID24{$sid} = $idx;
}
close IN1;


#2. put used SID in this experiment in %SIDuse
my %SIDuse;
open(IN2, $s2b) || die "Cannot open IN: $!";
while( my $record=<IN2> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $index = $line[1];

    my $pos = length($index)-$bases;
    my $sid = substr($index,$pos,$bases);

    $SIDuse{$sid} = 1;
}
close IN2;


#3. barcode count for R1
my $R1_profile = "SID_counts.txt";
my $R1_stat = "SID_stats.txt";

#unzip R1
system("date");
system("gunzip -c $R1_gz > $dir/$R1");
system("date");

open(IN3, "$dir/$R1") || die "Cannot open IN: $!";

my $n1 = -1;
my %barcode;
while( my $record=<IN3> )
{
    $n1++;
    chomp $record;
    $record =~ s/\r|\n//g;
    
    if($n1 % 4 == 0)
    {
	my @vars = split(":", $record);
	my $index = $vars[@vars-1];
	
	if($position == 1) 
	{
	    $position = length($index)-$bases;
	}
	my $sid = substr($index,$position,$bases);
	
	if (exists $barcode{$sid})
	{
	    $barcode{$sid}++;
	}
	else
	{
	    $barcode{$sid} = 1;
	}
    }
}


#4. print out barcode profile
my (%unex, %ex);
my $c1 = 0;
my $c2 = 0;
my $c3 = 0;
foreach my $id (keys %barcode)
{
    my $count = $barcode{$id};
    if ( exists $SID24{$id} )
    {
	my $idx = $SID24{$id};
	if (exists $SIDuse{$id})
	{
	    $c1 = $c1+$count;
	    my $item = "$id\t$idx\texpected_used\t$count";
	    $ex{$idx} = $item;
	}
	else
	{
	    $c2 = $c2+$count;
	    my $item = "$id\t$idx\texpected_not_used\t$count";
	    $ex{$idx} = $item;
	}
    }
    else
    {
	$c3 = $c3+$count;
	my $idx = "NA";
	    my $item = "$id\t$idx\tunexpected\t$count";
	$unex{$item} = $count;
    }
}
    

open(OUT1, ">$dir/$R1_profile") || die "Cannot open OUT: $!";
foreach my $key (sort { $a <=> $b} keys %ex) 
{
    print OUT1 "$ex{$key}\n";
}
    
foreach my $key (sort { $unex{$b} <=> $unex{$a}} keys %unex) 
{
    print OUT1 "$key\n";
}
close OUT1;
    
open(OUT2, ">$dir/$R1_stat") || die "Cannot open OUT: $!";
my $puse_all = sprintf("%.1f", $c1/($c1+$c2+$c3)*100);
my $pnonuse = sprintf("%.1f", $c2/($c1+$c2+$c3)*100);
my $puse_24 = sprintf("%.1f", $c1/($c1+$c2)*100);
my $punex = sprintf("%.1f", $c3/($c1+$c2+$c3)*100);
    
print OUT2 "% used SID\t$puse_all\n";
print OUT2 "% non-used SID\t$pnonuse\n";
print OUT2 "% unexpected SID\t$punex\n";
print OUT2 "% used SID within 24SID\t$puse_24\n";
close OUT2;


#5. plot SID distribution
system("cp /home/users/fengl6/bin/barcode_distribution.R $dir/barcode_distribution.R");
system("R CMD BATCH $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.Rout");
