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

my $dir2 = "/isilon/Analysis/.snapshot/ScheduleName_duration_2016-08-20-_02-00/onco/v1_analyses/$exp";
#	print "$dir1\n";
#	print "$dir2\n\n";
system("cp $dir2/*trace* $dir");
