#!/usr/bin/perl

use warnings;
use strict;

open(IN, "PRED1_pilot_FUS_m_sample2barcode.txt") || die "Cannot open IN: $!";
open(OUT, ">new.txt") || die "Cannot open OUT: $!";

while( my $record=<IN> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    
    if ($record =~ /(\S+)\s+(\w+)\s+(\w+)/)
    {
	print OUT "$1\t$2\t$3\n";
    }
}
close IN;
close OUT;
