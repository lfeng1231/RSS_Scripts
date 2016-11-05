#!/usr/bin/perl

use warnings;
use strict;

my $directory = `pwd`;
chomp $directory;
my $target = $ARGV[0];

#system("module load python/2.7.9");
system("date");

opendir (DIR, $directory) or die $!;
my $n =0;
while (my $file = readdir(DIR)) 
{
    if ($file =~ /(\S+)\.sorted\.freq\.paired\.Q30\.txt/)
    {
	$n++;
	my $base = $1;
	my $fig = "fig".$n."_non-deduped_".$base;
	my $out = "out".$n."_".$base;
	
	system("python /home/users/fengl6/bin/plotcoverage_bases.py -i $file -b $target -t $fig > $out");
	system("date");
    }
}
closedir(DIR);

print "Number of file processed: $n\n";
