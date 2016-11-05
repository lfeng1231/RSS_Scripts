#!/usr/bin/perl

use warnings;
use strict;

my %sid;

open(IN2, "/home/users/fengl6/my_scripts/8_MID_distribution/v2.1_bcs.txt") || die "Cannot open IN: $!";
while( my $record=<IN2> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $seq = $line[1];
    my $id = $line[0];
    $sid{$seq} = $id;
}
    
my $dir = `pwd`;
chomp $dir;
opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

foreach my $name (@files)
{
    if ($name =~ /\S+_(R\d)_001_(\w+)\.fastq/)
    {
	my $r = $1;
	my $seq = $2;
	my $adapter;

	if (exists $sid{$seq})
	{
	    $adapter=$sid{$seq};
	    $adapter = "adapter$adapter";
	}
	else
	{
	    print "$name\tNo adapter found!\n";
	}
	
	my $out = $adapter."_MID_dist_".$r."_$seq"."_NNNN.txt";
	my $out2 = $adapter."_MID_dist_".$r."_$seq"."_ACGT.txt";
	
	open(IN, $name) || die "Cannot open IN: $!";
	open(OUT, ">$out") || die "Cannot open OUT: $!";
	open(OUT2, ">$out2") || die "Cannot open OUT: $!";
	
	my $n = 0;
	my %count;
	my $j = 0;
	my $k = 0;
	while( my $record=<IN> )
	{
	    $n++;
	    chomp $record;
	    
	    if ($n == 1)
	    {
		next;
	    }
	    elsif ($n == 2)
	    {
		my $mid = substr($record, 0, 2);
		$j++;
		if ($mid !~ /N/)
		{
		    $k++;
		}
		    
		if (exists $count{$mid})
		{
		    $count{$mid}++;
		}
		else
		{
		    $count{$mid} = 1;
		}
	    }
	    elsif ($n == 3)
	    {
		next;
	    }
	    elsif ($n == 4)
	    {
		$n = 0;
	    }
	}
	close IN;
	foreach my $key ( sort {$a cmp $b} keys %count)
	{
	    my $c = $count{$key};
	    my $pct_j = sprintf("%.3f", $c/$j*100);
	    print OUT "$key\t$count{$key}\t$pct_j\n";
	    if ($key !~ /N/)
	    {
		my $pct_k = sprintf("%.3f", $c/$k*100);
		print OUT2 "$key\t$count{$key}\t$pct_k\n";
	    }
	}
	close OUT;
	close OUT2;
    }
}
