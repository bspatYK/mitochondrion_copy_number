#!/usr/bin/perl -w
use strict;
use warnings;

##scripts for MT copy number estimation;
##version: 2.0
##Author: boshiping@yikongenomics.com

my $sample                    = $ARGV[0];
my $outputfile                = $ARGV[1];
my $autosome_count            = 0;
my $autosome_dup_count        = 0;
my $autosome_remove_dup_count = 0;
my $MT_count                  = 0;
my $MT_dup_count              = 0;
my $MT_remove_dup_count       = 0;


open OUT, ">$outputfile" or die "Cannot open output file!";

while(<STDIN>){
	chomp;
	my @line = split;
	next if ($_ =~ /XT\:A\:U/);
	if ($line[2] =~ /^(chr)?\d+$/)
	{
		$autosome_count++;
		if ($line[1] >= 1024){
			$autosome_dup_count++ ;
		}else{
			$autosome_remove_dup_count++;
			}
	}elsif($line[2] =~ /^(chrM|MT)$/){
		$MT_count++;
		if ($line[1] >= 1024){
			$MT_dup_count++ ;
		}else{
			$MT_remove_dup_count++;
			}
		}
	}


#  autosome mapped reads/(autosome mappable region * 2) = relative amplification  efficiency * mitochondrion mapped reads/(mitochondrion mappable region * mitochondrion copy number)
#  => 
#  mitochondrion copy number =relative amplification  efficiency *  autosome mappable region * 2 *  mitochondrion mapped reads / mitochondrion mappable region * autosome mapped reads

my $autosome_mappable_region_hg19 = 2684573005;
my $mitochondrion_mappable_region_hg19 = 16571;

my $mitochondrion_copy_number = int ($autosome_mappable_region_hg19 * 2 * $MT_count/($mitochondrion_mappable_region_hg19 * $autosome_count));
my $mitochondrion_copy_number_rmdup = int ($autosome_mappable_region_hg19 * 2 * $MT_remove_dup_count/($mitochondrion_mappable_region_hg19 * $autosome_remove_dup_count));

print OUT "\#Autosome_mappable_region_hg19: 2,684,573,005\n\#Mitochondrion_mappable_region_hg19: 16,571\n";
print OUT "\#Sample\tAutosome_mapped_reads\tMitochondrion_mapped_reads\tEstimated_MT_genome_copy_number\tAutosome_remove_dup_mapped_reads\tMitochondrion_remove_dup_mapped_reads\tEstimated_MT_genome_copy_number\(remove_dup\)\n";
print OUT "$sample\t$autosome_count\t$MT_count\t$mitochondrion_copy_number\t$autosome_remove_dup_count\t$MT_remove_dup_count\t$mitochondrion_copy_number_rmdup\n";
close OUT or die "Cannot close output file!";