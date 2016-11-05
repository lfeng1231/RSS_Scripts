#!/usr/bin/perl

use warnings;
use strict;

open(IN1, "R1_properly_paired_fraglen.txt") || die "Cannot open IN: $!";
open(OUT, ">frag_len.txt") || die "Cannot open OUT: $!";

while( my $record=<IN1> )
{
    chomp $record;
    
    my $len = abs($record);
    {
	if ($len>0)
	{
	    print OUT "$len\tproperly_paired\n";
	}
    }
}
close IN1;

open(IN2, "R1_not_properly_paired_fraglen.txt") || die "Cannot open IN: $!";
while( my $record=<IN2> )
{
    chomp $record;

    my $len = abs($record);
    {
	if ($len>0)
	{
	    print OUT "$len\tnot_properly_paired\n";
	}
    }
}
close IN2;
