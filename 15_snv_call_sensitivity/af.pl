#!/usr/bin/perl

use warnings;
use strict;

my $sample = $ARGV[0];
my $file = $ARGV[1];
my $out = $ARGV[2];
my $plex = $ARGV[3];

open(IN, $file) || die "Cannot open IN: $!";
open(OUT, ">$out") || die "Cannot open OUT: $!";
print OUT "Sample\tPlex\tCHR\tPOS\tGENE\tReal_AF\tExpect_AF\n";

my $n = 0;
while( my $record=<IN> )
{
    $n++;
    if ($n ==1)
    {
	next;
    }
    else
    {
	chomp $record;
	$record =~ s/\r|\n//g;
	my @line = split("\t", $record);

	print OUT "$sample\t$plex\t$line[0]\t$line[1]\t$line[4]\t$line[23]\t$line[20]\n";
    }
}

close IN;
close OUT;
