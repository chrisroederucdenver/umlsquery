#!/usr/bin/perl

use strict;
use UMLSQuery;
use Data::Dumper;

my $U = new UMLSQuery;


sub search_for_parents($) {
    my $list_ref = shift; # list of (vocab, concept) pairs, or (SAB, SCUI) pairs
    my @parts = @$list_ref;
    foreach my $a_pair_ref (@parts[0..$#parts]) {
        my ($a_sab, $a_scui) = @$a_pair_ref;
    
        my $detail_a = $U->getRowBySABandSCUI($a_sab, $a_scui);
        if (scalar(@$detail_a) > 0) {
            my $arr_a = @$detail_a[0];
            my $cui_a = @$arr_a[0];
            print("A: (@$arr_a[2], @$arr_a[3]), $cui_a, \"@$arr_a[4]\"\n");
            foreach my $b_pair_ref (@parts[1..$#parts]) {
                my ($b_sab, $b_scui) = @$b_pair_ref;
                my $detail_b = $U->getRowBySABandSCUI($b_sab, $b_scui);
                if (scalar(@$detail_b) > 0) {
                    my $arr_b = @$detail_b[0];
                    my $cui_b = @$arr_b[0];
                    my ($parent_aui, $level_count) = $U->getCommonParent2($cui_a, $cui_b);
                    if ($parent_aui ne "0" and $parent_aui ne "A3684559") {
                        my $parent_detail = $U->getRow($parent_aui);
                        my $arr_p = @$parent_detail[0];
                        my $cui_p = @$arr_p[0];
                        print("    B: $level_count steps from ($b_sab, $b_scui), $cui_b, to parent: (@$arr_p[2], @$arr_p[3]), $cui_p, \"@$arr_p[4]\"\n");
                    }
                }
            }
            print("\n");
        }
    }
}
 
$U->init( u => 'root',
		  p => 'H8rmonization!',
		  h => 'localhost',
		  dbname => 'umls',
		  port => 3306);


print("\nCHEMOTHERAPY\n");
my @chemo = ( ['SNOMEDCT_US','367336001'], ['SNOMEDCT_US','315601005'], ['SNOMEDCT_US','	161653008'], 
              ['SNOMEDCT_US','722480002'], ['LNC','21967-5'], ['LNC','LA6172-6'], ['LNC','21946-9']);
search_for_parents(\@chemo);


print("\nCANCER\n");
my @parts = ( ['LNC','LA10536-3'], ['LNC','LA10542-1'], ['LNC','LA10550-4'], ['LNC','LA10539-7'], ['LNC','LA10538-9'], 
              ['LNC','LA10524-9'], ['LNC','LA10540-5'], ['LNC','54532-7'], ['LNC','54774-5'], 
              ['SNOMEDCT_US', '36716631'], ['SNOMEDCT_US', '32130007'], ['SNOMEDCT_US', '269469005'], ['SNOMEDCT_US','363346000'],
              ['SNOMEDCT_US', '55342001'], ['SNOMEDCT_US', '399981008'],['SNOMEDCT_US', '64572001'],  ['SNOMEDCT_US', '363358000'],
              ['SNOMEDCT_US', '254837009'],['SNOMEDCT_US', '416274001'],['SNOMEDCT_US','399068003'],  ['SNOMEDCT_US', '94098005'],
              ['SNOMEDCT_US','40320128'],  ['SNOMEDCT_US', '1077277007'] );

search_for_parents(\@parts);


$U->finish();













