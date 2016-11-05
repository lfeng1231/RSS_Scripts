#!/usr/bin/perl

use warnings;
use strict;

#open(IN, "REDO2_alectinib_FUS_sample2barcode.txt") || die "Cannot open IN: $!";

my $path = "/remote/Overflow/DataAnalysis/Oncology_TE/CM_elim_11092015/designs/new";
opendir (DIR, $path) or die "Can not open DIR/n";

my @filelist = readdir DIR;

#open(OUT, ">/remote/Overflow/DataAnalysis/Oncology_TE/CM_TEstudy_Nov2015/TE1/analysis/analysis/RNG_on-target_rate.txt") || die "Cannot open OUT: $!";

foreach my $file (@filelist)
{
    if ($file =~ /\S+\.bed$/)
    {
	open(IN, "$file") || die "Cannot open IN: $!";
	my $output = "new_".$file;
	open(OUT, ">$output") || die "Cannot open OUT: $!";
	
	while( my $record=<IN> )
	{
	    chomp $record;
	    $record =~ s/\r|\n//g;
	    
	    if ($record =~ /(\w+)\s+(\w+)\s+(\w+)/)
	    {
		print OUT "$1\t$2\t$3\n";
	    }
	}
	close IN;
	close OUT;
    }
}
