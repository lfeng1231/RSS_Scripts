#!/usr/bin/perl
use warnings;
use strict;

my $bam = $ARGV[0];
my $sample = $ARGV[1];
system("samtools view -h -f 2 $bam | samtools view -f 64 - > frag_len.sam");

open(IN, "frag_len.sam") || die "Cannot open IN: $!";

my $a = 0;
my $b = 0;
while( my $record=<IN> )
{
    chomp $record;
    
    if ($record =~ /^\@/)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $rname = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $strand = "+";
	my $frag = abs($line[8]);
	if ($frag > 0)
	{
	    $a++;
	    if ($frag <=100)
	    {
		$b++;
	    }
	}
	
    }
}
close IN;

my $c = sprintf("%.3f", $b/$a*100);
print "$sample\t$c\n";
