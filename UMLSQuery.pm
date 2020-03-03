package UMLSQuery;
use strict;
use DBI;
use Math::Combinatorics;
use vars qw($VERSION);
$VERSION = 0.3;

# 	Author: Nigam Shah, Version: 0.3
#
#	The software is provided "as is", without warranty of any kind,
#	express or implied, including but not limited to the warranties
#	of merchantability, fitness for a particular purpose and
#	noninfringement. In no event shall the authors or copyright
#	holders be liable for any claim, damages or other liability,
#	whether in an action of contract, tort or otherwise, arising
#	from, out of or in connection with the software or the use or
#	other dealings in the software.
#
#	This package is available under the same terms as PERL itself.

####################################################################################
sub new {
# The class constructer to create the object
####################################################################################
	# required to keep the class inhertiable:
	my $Child_class = shift;

	# The actual Object by definition:
	# (in this case a reference to a hash)
	my $self = {};

	# bless it into the package and future child class:
	bless ($self, $Child_class);
	return $self;
}
####################################################################################
sub init {
# Initialise the object with arguments to create a database connection to UMLS:
####################################################################################
	my $self = shift;
	my (%param) = @_;
	$self->{u} = $param{u};
	$self->{p} = $param{p};
	$self->{h} = $param{h};
	$self->{dbname} = $param{dbname};
	$self->{port} = $param{port};
	$self->{sid} = $param{sid};

	# Connect to a mysql server:
	my $dbname = $self->{dbname};
	my $host = $self->{h};
	my $port = $self->{port};
	$port = 3306 if(! defined $port);

	my $dbh = DBI->connect("dbi:mysql:$dbname:$host:$port",$self->{u},$self->{p});

	$self->{dbh} = $dbh;

	return 1 if (!$DBI::err);
}
####################################################################################
sub finish {
####################################################################################
	my $self = shift;
	$self->{dbh}->disconnect;
	return 1;
}

####################################################################################
sub getRowBySABandSCUI($$) {
####################################################################################
	my $self = shift;
	my $sab = shift;
	my $scui = shift;

	my @CUIs;

	my $q = "select CUI, AUI, SAB, SCUI, STR from MRCONSO where SAB='$sab' and SCUI='$scui' and LAT='ENG' ";
	my $sth = $self->{dbh}->prepare($q);
	$sth->execute();
    my @umls_stuff;
	while (my ($cui, $aui, $sab, $scui, $str) = $sth->fetchrow) {
		@umls_stuff =  ($cui, $aui, $sab, $scui, $str);
		push (@CUIs, \@umls_stuff);
	}
    my @unique = do { my %seen; grep { !$seen{$_}++ } @CUIs };
	return \@unique;
}
####################################################################################
sub getRow {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $sab = $param{sab};
	my @CUIs;

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);
	my $q = "select CUI, AUI, SAB, SCUI, STR from MRCONSO where $field='$string' and LAT='ENG' ";
	if (defined $sab){
		$sab =~s/\s//gm;
		if (scalar (split (',', $sab)) > 1){
			my $sabs = join ('\',\'', split (',', $sab));
			$q .= " and SAB in ('$sabs')";
		}else{
			$q .= " and SAB = '$sab'";
		}
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
    my @umls_stuff;
	while (my ($cui, $aui, $sab, $scui, $str) = $sth->fetchrow) {
		@umls_stuff =  ($cui, $aui, $sab, $scui, $str);
		push (@CUIs, \@umls_stuff);
	}
    my @unique = do { my %seen; grep { !$seen{$_}++ } @CUIs };
	return \@unique;
}
####################################################################################
sub getCUI {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $sab = $param{sab};
	my @CUIs;

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);
	my $q = "select distinct(CUI) from MRCONSO where $field='$string'";
	if (defined $sab){
		$sab =~s/\s//gm;
		if (scalar (split (',', $sab)) > 1){
			my $sabs = join ('\',\'', split (',', $sab));
			$q .= " and SAB in ('$sabs')";
		}else{
			$q .= " and SAB = '$sab'";
		}
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my $cui = $sth->fetchrow){
		push (@CUIs, $cui);
	}
	return @CUIs;
}
####################################################################################
sub getAUI {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $sab = $param{sab};
	my @AUIs;

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);
	my $q = "select distinct(AUI) from MRCONSO where $field='$string'";
	if (defined $sab){
		$q .= " and SAB = '$sab'";
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my $aui = $sth->fetchrow){
		push (@AUIs, $aui);
	}
	return @AUIs;
}
####################################################################################
sub getLUI {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $sab = $param{sab};
	my @LUIs;

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);
	my $q = "select distinct(LUI) from MRCONSO where $field='$string'";
	if (defined $sab){
		$q .= " and SAB = '$sab'";
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my $lui = $sth->fetchrow){
		push (@LUIs, $lui);
	}
	return @LUIs;
}
####################################################################################
sub getSTR {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $sab = $param{sab};
	my @STRs;

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}
	my $q = "select distinct(STR) from MRCONSO where $field='$string' "
			."and TS = 'P' and STT = 'PF' and  ISPREF = 'Y'";
	if (defined $sab){
		$q .= " and SAB = '$sab'";
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my $str = $sth->fetchrow){
		push (@STRs, $str);
	}
	return @STRs;
}
####################################################################################
sub getSAB {
####################################################################################
	my $self = shift;
	my $string = shift;
	my @SABs;

	# identify the type of ID passed in
	my $field;
	if ($string =~m/L\d{7}/){
		$field = 'LUI';
	}elsif($string =~m/S\d{7}/){
		$field = 'SUI';
	}elsif($string =~m/A\d{7}/){
		$field = 'AUI';
	}elsif($string =~m/C\d{7}/){
		$field = 'CUI';
	}else{
		$field = 'STR';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);

	#my $q = "select distinct(SAB) from MRCONSO where $field='$string'";
	my $q = "select SAB from MRCONSO where $field='$string'";

	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my $sab = $sth->fetchrow){
		push (@SABs, $sab);
	}
	return @SABs;
}
####################################################################################
sub mapToId {
####################################################################################
	my $self = shift;
	my $string = shift;
	my (%param) = @_;
	my $idtype = $param{idtype};
	my $sab = $param{sab};
	my %Matches;

	my $field;
	if ($idtype =~m/LUI/i){
		$field = 'LUI';
	}elsif($idtype =~m/SUI/i){
		$field = 'SUI';
	}elsif($idtype =~m/AUI/i){
		$field = 'AUI';
	}else{
		$field = 'CUI';
	}

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$string =~ s/'/\\'/g if ($string =~ m/$quote/);

	# Capitalize the first character
	my $str1 = reverse ($string);
	my $Char1 = chop $str1;
	$Char1 = uc($Char1);
	$str1 = reverse lc ($str1);
	$string = $Char1.$str1;

	# First try the string as is
	my $q = "select distinct($field), STR from MRCONSO where STR='$string'";
	if (defined $sab){
		$sab =~s/\s//gm;
		if (scalar (split (',', $sab)) > 1){
			my $sabs = join ('\',\'', split (',', $sab));
			$q .= " and SAB in ('$sabs')";
		}else{
			$q .= " and SAB = '$sab'";
		}
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	# prevent repeat matches
	while (my ($c, $s) = $sth->fetchrow){
		if ($Matches{$string}){
			my @matches = @{$Matches{$string}};
			my $seen = 0;
			foreach $_ (@matches){
				$seen = 1 if ($_ eq $s);
			}
			if ($seen !=1){
				push (@matches, $c, $s);
				$Matches{$string} = \@matches;
			}
		}else{
			$Matches{$string} = ["$c", "$s"];
		}
	}
	return \%Matches if ($Matches{$string});

	# If match not found, generate all permutations and check them for a match
	my @Terms = split(/\s/, $string);
	my $combinat = Math::Combinatorics->new(count => 2,	data => \@Terms);
	while(my @permu = $combinat->next_permutation){
		while (scalar@permu >= 1){
			my $perm = "@permu";

			# dont check for acronyms less than 4 characters
			last if (scalar@permu ==1 and length($perm) < 4);

			# try to find in the UMLS
			my $str = reverse ($perm);
			my $Char = chop $str;
			$Char = uc($Char);
			$str = reverse lc ($str);

			my $query = "select distinct($field), STR from MRCONSO where STR='$Char$str'";
			if (defined $sab){
				$sab =~s/\s//gm;
				if (scalar (split (',', $sab)) > 1){
					my $sabs = join ('\',\'', split (',', $sab));
					$q .= " and SAB in ('$sabs')";
				}else{
					$q .= " and SAB = '$sab'";
				}
			}
			my $sth = $self->{dbh}->prepare($query);
			   $sth->execute();
			while (my ($c, $s) = $sth->fetchrow){
				# prevent repeat matches
				if ($Matches{$perm}){
					my @matches = @{$Matches{$perm}};
					my $seen = 0;
					foreach $_ (@matches){
						$seen = 1 if ($_ eq $s);
					}
					if ($seen !=1){
						push (@matches, $c, $s);
						$Matches{$perm} = \@matches;
					}
				}else{
					$Matches{$perm} = ["$c", "$s"];
				}
			}
			pop(@permu);
		}
	}

	return \%Matches;
}
####################################################################################
sub getParents {
####################################################################################
	my $self = shift;
	my $ui = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};

	my %pnodes;
	# decide if its a cui or aui
	my $field;
	if ($ui =~m/C\d{7}/i){
		$field = "CUI";
	}elsif($ui =~m/A\d{7}/i){
		$field = "AUI";
	}else{
		return (0,'Wrong id type provided');
	}

	# Query for getting the parent node list
	my $q = "select distinct(PTR), PAUI
				from MRHIER
				where $field = ?";
	if (defined $sab){
		$q .= " and SAB = '$sab'";
	}
	if (defined $rela){
		$q .= " and RELA = '$rela'";
	}
	# Get the parent nodes for id1
	my $sth = $self->{dbh}->prepare($q);
	$sth->execute($ui);
	while (my ($ptr, $p1) = $sth->fetchrow_array){
		# ptr is a string of AUIs connected by a '.'
		# The immediate parent of the query node is right most and is same as
		# the $p1 e.g. ptr=A0398286.A0130731.A1188532.A0487444 & p1=A0487444
		$pnodes{$ptr} = $p1;
	}

	return \%pnodes;
}
####################################################################################
sub getCommonParent {
####################################################################################
	my $self = shift;
	my $ui_1 = shift;
	my $ui_2 = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};

	if (not(($ui_1 =~m/C\d{7}/i and $ui_2 =~m/C\d{7}/i) or
		  ($ui_1 =~m/A\d{7}/i and $ui_2 =~m/A\d{7}/i))){
		return (0, 'id type mismatch b/w $ui_1 and $ui_2');
	}

	# trivial check if they are the same
	if ($ui_1 eq $ui_2){
		return (0, "ids are the same");
	}

	# Call the getParents subroutine to get a hash of the parent nodes
	# the keys of the hash are the paths going to the root and the values
	# are the immediate parents

	my %pnodes_1 = %{$self->getParents($ui_1,$rela,$sab)};
	my %pnodes_2 = %{$self->getParents($ui_2,$rela,$sab)};

	# Examine the path to the parents for common nodes
	foreach my $p (sort keys %pnodes_1){
		foreach my $k (sort keys %pnodes_2){
			# reverse the arrays to scan them starting from the
			# nearest parent
			my @pn_1 = reverse (split(/\./,$p));
			my @pn_2 = reverse (split(/\./,$k));
			for my $i (0..$#pn_1){
				for my $j (0..$#pn_2){
					if ($pn_1[$i] eq $pn_2[$j]){
						return ($pn_1[$i],"$i links from $ui_1 $j links from $ui_2");
					}
				}
			}
		}
	}

	# If nothing found, tell the user
	return (0,"no common parent found");
}
####################################################################################
sub getCommonParent2 {
    # returns the number of links, not a string as above
####################################################################################
	my $self = shift;
	my $ui_1 = shift;
	my $ui_2 = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};

	if (not(($ui_1 =~m/C\d{7}/i and $ui_2 =~m/C\d{7}/i) or
		  ($ui_1 =~m/A\d{7}/i and $ui_2 =~m/A\d{7}/i))){
		return (0, 'id type mismatch b/w $ui_1 and $ui_2');
	}

	# trivial check if they are the same
	if ($ui_1 eq $ui_2){
		return (0, "ids are the same");
	}

	# Call the getParents subroutine to get a hash of the parent nodes
	# the keys of the hash are the paths going to the root and the values
	# are the immediate parents

	my %pnodes_1 = %{$self->getParents($ui_1,$rela,$sab)};
	my %pnodes_2 = %{$self->getParents($ui_2,$rela,$sab)};

	# Examine the path to the parents for common nodes
	foreach my $p (sort keys %pnodes_1){
		foreach my $k (sort keys %pnodes_2){
			# reverse the arrays to scan them starting from the
			# nearest parent
			my @pn_1 = reverse (split(/\./,$p));
			my @pn_2 = reverse (split(/\./,$k));
			for my $i (0..$#pn_1){
				for my $j (0..$#pn_2){
					if ($pn_1[$i] eq $pn_2[$j]){
						return ($pn_1[$i],$i);
					}
				}
			}
		}
	}

	# If nothing found, tell the user
	return (0,"no common parent found");
}
####################################################################################
sub getChildren {
####################################################################################
	my $self = shift;
	my $ui = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};

	my %children;
	# decide if its a cui or aui and query accordingly
	if ($ui =~m/C\d{7}/i){
		my $q = "select distinct(m2.CUI)
					from MRHIER, MRCONSO as m1, MRCONSO as m2
					where MRHIER.PAUI = m1.AUI
					and m1.CUI = '$ui'
					and MRHIER.AUI = m2.AUI";
		if (defined $sab){
			$q .= " and MRHIER.SAB = '$sab'";
		}
		if (defined $rela){
			$q .= " and MRHIER.RELA = '$rela'";
		}
		my $sth = $self->{dbh}->prepare($q);
		$sth->execute();
		while (my $c1 = $sth->fetchrow){
			$children{$c1} = $ui;
		}
	}elsif ($ui =~m/A\d{7}/i){
		# The method below is recommended by the UMLS documentation
#		my %pnodes = %{$self->getParents($ui,$rela,$sab)};
#		foreach my $p (keys %pnodes){
#			my $qstring = $p.".$ui";
#			my $q = "select distinct(AUI) from MRHIER where PTR='$qstring'";
#			if (defined $sab){
#				$q .= " and SAB = '$sab'";
#			}
#			if (defined $rela){
#				$q .= " and RELA = '$rela'";
#			}
#			#print $q,"\n";
#			# Get the child nodes for id
#			my $sth = $self->{dbh}->prepare($q);
#			$sth->execute();
#			while (my $c1 = $sth->fetchrow){
#				$children{$c1} = $ui;
#			}
#		}
		# The one below seems faster but is unaware of the context dependency of parenthood
		my $q = "select distinct(AUI) from MRHIER where PAUI = '$ui'";
		if (defined $sab){
			$q .= " and SAB = '$sab'";
		}
		if (defined $rela){
			$q .= " and RELA = '$rela'";
		}
		#print $q,"\n";
		# Get the child nodes for id
		my $sth = $self->{dbh}->prepare($q);
		$sth->execute();
		while (my $c1 = $sth->fetchrow){
			$children{$c1} = $ui;
		}
	}else{
		print "Wrong idtype $ui, provide cui or aui\n";
	}

	return \%children;
}
####################################################################################
sub getCommonChild {
####################################################################################
	my $self = shift;
	my $ui_1 = shift;
	my $ui_2 = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};

	if (not(($ui_1 =~m/C\d{7}/i and $ui_2 =~m/C\d{7}/i) or
		  ($ui_1 =~m/A\d{7}/i and $ui_2 =~m/A\d{7}/i))){
		return (0, 'id type mismatch b/w $ui_1 and $ui_2');
	}

	# trivial check if they are the same
	if ($ui_1 eq $ui_2){
		return (0, "ids are the same");
	}

	# Call the getChildren subroutine to get a hash of the child nodes
	# the keys of the hash are the direct children and the values are
	# paths starting from that child going to the root

	my %cnodes_1 = %{$self->getChildren($ui_1,$rela,$sab)};
	my %cnodes_2 = %{$self->getChildren($ui_2,$rela,$sab)};

	# Examine the direct children for common nodes
	foreach my $c (sort keys %cnodes_1){
		foreach my $k (sort keys %cnodes_2){
			if ($c eq $k){
				return ($c,"common child of $ui_1 and $ui_2");
			}
		}
	}

	# If nothing found, tell the user
	return (0,"no common child of $ui_1 and $ui_2");
}

####################################################################################
sub getAvailableSAB {
####################################################################################
	my $self = shift;
	my $son = shift;
	my %SABs;

	# replace the ' with \' to keep mysql happy
	my $quote = "'";
	$son =~ s/'/\\'/g if ($son =~ m/$quote/);
	my $q = "select RSAB, SON from MRSAB";
	if (defined $son){
		$q .= " where UPPER(SON) like UPPER('%$son%')";
	}
	my $sth = $self->{dbh}->prepare($q);
	   $sth->execute();
	while (my ($r, $s) = $sth->fetchrow){
		$SABs{$r} = $s;
	}
	return \%SABs;
}
####################################################################################
sub getDistBF {
# Breadthfirst search from CUI1 to see how far is CUI2
####################################################################################
	my $self = shift;
	my $cui_1 = shift;
	my $cui_2 = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};
	my $maxR = $param{maxR};

	# Datastructures needed for BF search
	my @nodesinqueue;
	my %Visited;
	my %RadiusIndex;
	my $queindex = 0;
	my $r = 0;
	$RadiusIndex{$r} = 0;

	# Set the maxR to a reasonable cutoff if its not defined
	$maxR = 3 if(!defined $maxR);

	push (@nodesinqueue, $cui_1);
	$Visited{$cui_1}=1;

	while (scalar@nodesinqueue > 0){
		my $node = shift @nodesinqueue;

		# Examine the first node in the Queue
		if ($node eq $cui_2){
			return $r;
		}

		# Get the adjacent nodes
		my @adjacentnodes;
		my $q = "select distinct(CUI2) from MRREL where CUI1 = '$node' and (rel='PAR' or rel='CHD')";
		if (defined $sab){
			$q .= " and SAB = '$sab'";
		}
		if (defined $rela){
			$q .= " and RELA='$rela'";
		}

		my $sth = $self->{dbh}->prepare($q);
		$sth->execute();

		while (my $c2 = $sth->fetchrow){
			# Keep only the unvisited adjacent nodes
			if ($Visited{$c2} != 1){
				push (@adjacentnodes, $c2);
			}
		}
#		print "radius = $r, Que processed = $queindex, RadiusIndex at = $RadiusIndex{$r},",
#			  "in que = ",scalar@nodesinqueue," adj of $node = ",scalar@adjacentnodes,"\n";

		# Calculate where in the queue a certain radius will be reached
		if (!$RadiusIndex{$r+1}){
			$RadiusIndex{$r+1} = $queindex + scalar@nodesinqueue;
		}
		$RadiusIndex{$r+1} +=  scalar@adjacentnodes;

		# If queue is processed to that node, increase the radius examined
		if ($queindex == $RadiusIndex{$r}){
			$r++;
		}
		# Increment the processed queue counter
		$queindex++;

		# Add the unvisited adjacent nodes to the queue
		foreach my $c (@adjacentnodes){
			$Visited{$c}=1;
			push (@nodesinqueue, $c);
		}

		# If the search is past a certain radius, break and return
		return $r if ($r > $maxR);
	}
}
####################################################################################
sub getNeighbours {
####################################################################################
	my $self = shift;
	my $ui = shift;
	my (%param) = @_;
	my $rela = $param{rela};
	my $sab = $param{sab};
	my $rel = $param{rel};
	#print %param;
	# decide if its a cui or aui
	my $field;
	if ($ui =~m/C\d{7}/i){
		$field = "CUI1";
	}elsif($ui =~m/A\d{7}/i){
		$field = "AUI1";
	}else{
		return (0,'Wrong id type provided');
	}

	# Get the  adjacent nodes
	my @adjacentnodes;
	my $q = "select distinct(CUI2) from MRREL where $field = '$ui'";
	if (defined $sab){
		$q .= " and SAB = '$sab'";
	}
	if (defined $rela){
		$q .= " and RELA = '$rela'";
	}
	if (defined $rel){
		$q .= " and REL = '$rel'";
	}
	my $sth = $self->{dbh}->prepare($q);
	$sth->execute();

	while (my $c2 = $sth->fetchrow){
		# Dont give reflexive relationships
		next if (($c2 eq $ui) and ($field eq "CUI1"));
		push (@adjacentnodes, $c2);
	}
	return \@adjacentnodes;
}
1;

=head1 NAME

UMLSQuery - A module to query a umls mysql installation

=head1 SYNOPSIS

    use UMLSQuery;

	my $U = new UMLSQuery;

	$U->init( u => 'username',
			  p => 'password',
			  h => 'hostname',
			  dbname => 'umls');

	$U->getCUI(string/aui/sui/lui, sab=>)
	$U->getAUI(string/cui/sui/lui, sab=>)
	$U->getSTR(string/cui/aui/sui/lui, sab=>)
	$U->getSAB(string/cui/aui/sui/lui)

	$U->mapToId(phrase, idtype=>cui/lui/sui/aui, sab=>)

	$U->getParents(aui/cui, rela=>, sab=>)
	$U->getCommonParent(aui/cui, aui/cui, rela=>, sab=>)

	$U->getChildren(aui/cui, rela=> sab=>)
	$U->getCommonChild(aui/cui, aui/cui, rela=>, sab=>)

	$U->getDistBF(cui_1, cui_2,rela=>)
	$U->getAvailableSAB()

	$U->finish()

=head1 CHANGES
	0.2 sab can take multiple dictionaries as value e.g. "RXNORM, SNOMEDCT"
	0.3 getParents only returned a single path to the root even if multiple
		paths existed. That is now fixed. This leads to a change in the out
		put of that funtion. The output hash now has paths as key and the
		immediate parent node as value.

=head1 DESCRIPTION

This module will allow you to connect to a mysql UMLS installation and run common
queries. If you have a query that you want, contact me at nigam@stanford.edu.

=item $U->init(u => 'username', p => 'password', h => 'hostname', dbname => 'umls');

Provide a username, password, host and dbname of a valid UMLS mysql database.
You can optionally provide a port=> if your mysql is not on port 3306

=item $U->getCUI(string/aui/sui/lui, sab=>)

This function accepts any text string, an aui (Atom Unique Identifier),
sui (String Unique Identifier) or lui (Lexical Unique Identifer) and gets its cui
(Concept Unique Identifier). The search is for an exact match. To restrict the
search to a particular dictionary provide the sab value. The following searches
for 'prostate' in the SNOMED-CT vocabulary.

	$U->getCUI('prostate', sab=>'SNOMEDCT')

=item $U->getAUI(string/cui/sui/lui, sab=>)

This function accepts any text string, a cui (Concept Unique Identifier),
sui (String Unique Identifier) or lui (Lexical Unique Identifier) and gets its aui
(Atom Unique Identifer). The search is for an exact match. To restrict the
search to a particular dictionary provide the sab value. The following searches
for 'prostate' in the SNOMED-CT vocabulary.

	$U->getAUI('prostate', sab=>'SNOMEDCT')

=item $U->getSTR(cui/aui/sui/lui, sab=>)

This function accepts a cui (Concept Unique Identifier), aui (Atom Unique Identifer)
sui (String Unique Identifier) or lui (Lexical Unique Identifier) and gets its string.
The search is for an exact match. To restrict the search to a particular dictionary
provide the sab value. The following searches for 'A0812060' in the SNOMED-CT vocabulary.

	$U->getSTR('A0812060', sab=>'SNOMEDCT')

=item $U->getSAB(string/cui/aui/sui/lui)

This function accepts a cui (Concept Unique Identifier), aui (Atom Unique Identifer)
sui (String Unique Identifier) or lui (Lexical Unique Identifier) and gets the dictionary/s
it belongs to. The search is for an exact match (if a string is provided).

	$U->getSAB('prostate')

=item $U->mapToId(phrase, idtype=>cui/lui/sui/aui, sab=>)

This function accepts a phrase (upto 10 words) and maps it to the chosen idtype (can be
restricted by sab if desired. The function first looks for an exact match for the phrase,
if none is found, then will generate all possible permutations and attempt an exact match
for each one (with right truncation of words to look for partial matches). The following
tries to find a CUI belonging to the SNOMED-CT for 'intraductal carcinoma of prostate'.

	$U->mapToId('intraductal carcinoma of prostate', idtype=>'cui', sab=>'SNOMEDCT');

The function returns a hash which has a particular permutation as its key and the value is
an array of pairs of id - string. The above examle returns:

	key		id	string
	------------------------------
	carcinoma       C0007097 Carcinoma
	intraductal     C1644197 Intraductal
	prostate        C0033572 Prostate
	carcinoma prostate      C0600139 Carcinoma prostate
	intraductal carcinoma   C0007124 Intraductal carcinoma
	prostate carcinoma      C0600139 Prostate carcinoma
	carcinoma of prostate   C0600139 Carcinoma of prostate

in case of mutliple matches, the id - string pair will be pushed onto the array.

=item $U->getParents(aui/cui, rela=>, sab=>)

This function accepts a cui or aui and returns all its parents (optionally restricted
along a particular relationship type (rela, 188 posible values) and a vocabulary). The
example below finds all isa parents of 'C0600139'.

	$U->getParents('C0600139', rela=>'isa');

The function returns a hash, where the keys are the string of ids forming the path to the
root node and the values are the direct parents of the id. The ids are always reported as
aui. The example above returns:

	direct parent	Path to the root
	---------------------------------------------------
	A3407646        A3684559.A3713095.A3506985.A3407646

=item $U->getCommonParent(aui/cui, aui/cui, rela=>, sab=>)

This function accepts a pair of cuis or auis and returns the common parent (optionally restricted
along a particular relationship type (rela, 188 posible values) and a vocabulary). The
example below finds common parents of 'C0600139','C0007124' along any rela type.

	$U->getCommonParent('C0600139','C0007124');

The function returns the common parent (aui) and the distance (dist) from the query nodes.
The above example returns:

	aui		dist
	-------------------------------------------------------
	A0689089	4 links from C0600139 3 links from C0007124

=item $U->getChildren(aui/cui, rela=> sab=>)

This function accepts a cui or aui and returns all its direct children (optionally restricted
along a particular relationship type (rela, 188 posible values) and a vocabulary). The
example below finds all isa children of 'C0376358'.

	$U->getChildren('C0376358',rela=>'isa');

The function returns a hash, where the keys are the direct children of the id and the
values is the query id. The ids are reported in the form of the query id. The example above
returns:

	child	parent
	------------------------
	C0347001        C0376358
	C1330959        C0376358
	C1302530        C0376358
	C1282482        C0376358

=item $U->getCommonChild(aui/cui, aui/cui, rela=>, sab=>)

This function accepts a pair of cuis or auis and returns the common child (optionally restricted
along a particular relationship type (rela, 188 posible values) and a vocabulary (sab)). The
example below finds common parents of 'C0376358','C0346554' along any rela type.

	$U->getCommonChild('C0376358','C0346554')

The function returns the common child and the ids of the query nodes. The example above returns

	C0600139	common child of C0376358 and C0346554

=item $U->getDistBF(cui_1, cui_2,rela=>,maxR=>,sab=>)

This function accepts two cuis and performs a breadth first search from cui_1 to find cui_2 and
reports the number of links at which cui_2 is found. The search is aborted if cui_2 is not found
in a radius of maxR links. (maxR is set to 3 if it is not provided). The search can be limited
to a particular vocabulary by specifying the sab.

	$U->getDistBF('C0600139','C0007124')

The above example returns 2.

=item $U->getAvailableSAB('search string')

This function returns a hash where the keys are the 'sab' and the values are the descriptions
of those sab that contain the 'search string'. The example below searches for sab that have
SNOMED in their description.

	$U->getAvailableSAB('SNOMED')

It returns:

	sab		description
	-------------------------------------------------
	SNOMEDCT        SNOMED Clinical Terms, 2006_01_31
	SCTSPA  SNOMED Clinical Terms, Spanish Language Edition, 2005_10_31
	SNM     SNOMED-2, 2
	SNMI    SNOMED International, 1998

=item $U->finish()

Disconnect and end the querying.
