#!/usr/bin/env perl

use warnings;
use strict;

#create file names
my $dir =`pwd`;
chomp $dir;
my $exp;
if ($dir =~ /\/isilon\/Analysis\/onco\/v1_analyses\/(\S+)/)
{
    $exp = $1;
}
else
{
    print "path error\n";
}

opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

foreach my $name (sort {$a cmp $b} @files)
{
    if ($name =~ /\.txt/ or $name =~ /\.csv/ or $name =~ /\.sh/ or $name eq "." or $name eq "..")
    {
	next;
    }
    else
    {
	my $dir1 = "$dir/$name";
	my $dir2 = "/isilon/Analysis/.snapshot/ScheduleName_duration_2016-08-20-_02-00/onco/v1_analyses/$exp/$name";
#	print "$dir1\n";
#	print "$dir2\n\n";
	system("cp $dir2/*trace* $dir1");
    }
}
