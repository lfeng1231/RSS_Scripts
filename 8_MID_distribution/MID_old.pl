#!/usr/bin/perl

use warnings;
use strict;

my $dir = `pwd`;
chomp $dir;
opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

foreach my $name (@files)
{
    if ($name =~ /(\S+)\.fastq/)
    {
	my $base = $1;
	my $out = "dist_MID_".$base.".txt";
    
	open(IN, $name) || die "Cannot open IN: $!";
	open(OUT, ">$out") || die "Cannot open OUT: $!";

	my $n = 0;
	my %count;
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
	    print OUT "$key\t$count{$key}\n";
	}
	close OUT;
    }
}
