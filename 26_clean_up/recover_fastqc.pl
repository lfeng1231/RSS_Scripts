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
	my $dir1 = "$dir/$name/analysis";
	#system("cd $dir1");

	opendir(DIR1,$dir1);
	my @file = readdir(DIR1);
	closedir(DIR1);

	foreach my $sname (sort {$a cmp $b} @file)
	{
	    if ($sname =~ /\.txt/ or $sname =~ /\.pl/ or $sname =~ /demux/ or $sname eq "." or $sname eq "..")
	    {
		next;
	    }
	    else
	    {
		my $dir3 = "$dir/$name/analysis/$sname/fastqc";
		my $dir2 = "/isilon/Analysis/.snapshot/ScheduleName_duration_2016-08-21-_02-00/onco/v1_analyses/$exp/$name/analysis/$sname/fastqc";
		#	print "$dir1\n";
		#	print "$dir2\n\n";
		system("cp $dir2/*fastqc_data.txt $dir3");
	    }
	}
    }
}

