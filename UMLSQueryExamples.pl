use strict;
use UMLSQuery;

my $U = new UMLSQuery;

$U->init( u => 'username',
		  p => 'password',
		  h => 'host',
		  dbname => 'dbname',
		  port => 3306);

print "\n",'$U->getCUI(Malignant tumour of prostate, RCD)',"\n";
@_ = $U->getCUI('Malignant tumour of prostate', 'RCD');
print "    @_";

print "\n",'$U->getAUI(Malignant tumour of prostate, RCD)',"\n";
@_ = $U->getAUI('Malignant tumour of prostate', 'RCD');
print "    @_";

print "\n",'$U->getSTR(A0812060)',"\n";
@_ = $U->getSTR('A0812060');
print "    @_";

print "\n",'$U->getSAB(prostate)',"\n";
@_ = $U->getSAB('prostate');
print "    @_";

print "\n",'$U->mapToId(intraductal carcinoma of prostate, idtype=>cui, sab=>SNOMEDCT)',"\n";
my $Ref = $U->mapToId('intraductal carcinoma of prostate', idtype=>'cui', sab=>'SNOMEDCT');
foreach $_ (sort keys %{$Ref}){
	print "    ",$_,"\t","@{$$Ref{$_}}","\n";
}

	#print "-----------------\n";
	#my $Ref = $U->mapToId('Carcinoma of prostate',idtype=>'aui');
	#foreach $_ (keys %{$Ref}){
	#	print "    ",$_,"\t","@{$$Ref{$_}}","\n";
	#}

print "\n",'$U->getParents(C0600139,rela=>isa)',"\n";
my $Ref = $U->getParents('C0600139',rela=>'isa');
print scalar (keys %{$Ref})," paths to the root\n";

	foreach $_ (keys %{$Ref}){
		print "    ",$_,"\t",$$Ref{$_},"\n";
		my @parents = split(/\./, $_);
		print scalar @parents,"\n";
		foreach my $p (@parents){
			my ($CUI) = $U->getCUI($p);
			my ($STR) = $U->getSTR($CUI);
			print $p," - ", $CUI," - ", $STR,"\n";
		}
	}

print "\n",'$U->getCommonParent(C0600139, C0007124)',"\n";
my ($cp, $dist) = $U->getCommonParent('C0600139','C0007124');
print "    ",$cp,"\t",$dist,"\n";

print "\n",'$U->getChildren(C0376358,rela=>isa)',"\n";
my $Ref = $U->getChildren('C0376358',rela=>'isa');
foreach $_ (keys %{$Ref}){
	print "    ",$_,"\t",$$Ref{$_},"\n";
}

	#print "\n",'$U->getChildren(A0740298)',"\n";
	#my $Ref = $U->getChildren('A0740298');
	#foreach $_ (keys %{$Ref}){
	#	print "    ",$_,"\t",$$Ref{$_},"\n";
	#}

print "\n",'$U->getCommonChild(C0376358,C0346554)',"\n";
my ($cp, $dist) = $U->getCommonChild('C0376358','C0346554');
print "    ",$cp,"\t",$dist,"\n";

	#print "\n",'$U->getCommonChild(A3261244,A3339540)',"\n";
	#my ($cp, $dist) = $U->getCommonChild('A3261244','A3339540');
	#print $cp,"\t",$dist,"\n";

print "\n",'$U->getDistBF(C0600139,C0007124)',"\n";
my $dist = $U->getDistBF('C0600139','C0007124');
print "    ","distance b/w C0600139 and C0007124\t",$dist," links\n";

print "\n",'$U->getAvailableSAB(SNOMED)',"\n";
my $Ref = $U->getAvailableSAB('SNOMED');

foreach $_ (keys %{$Ref}){
	print "    ",$_,"\t",$$Ref{$_},"\n";
}

$U->finish();