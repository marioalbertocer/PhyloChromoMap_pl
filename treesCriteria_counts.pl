# This script is for counting presence/absence of minor clades in trees
# It also says if a tree contains more than 10 leaves (criterion)
# It needs the report from screipt bestOGsXseq

my $path = '/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/';
my $folder = 'Saccharomyces_cerevisiae/';

# Reading report of bestOGsXseq...
my $listOGs = open(LISTOGS, $path . $folder . 'bestOGsXseq_out.txt');
my $out = open(OUT, ">>" . $path . $folder . "criteriaANDcounts_out.txt");
my @listOGs = <LISTOGS>;

sub uniq {
	my %seen;
	return grep {!$seen{$_}++} @_;
}

foreach my $line (@listOGs){
 	$line =~ s/\n$//;

 	#some of the lines in the report says that there is not an OG, so it avoids those ones
	#some of the lines in the report says that there is not an OG, so it avoids those ones
	if ($line =~ "OG5_"){
		my @values = split("\t", $line);
		my $og = $values[2];
		my @minCs = ();
		$_ = 0 for my ($op, $am, $pl, $ex, $sr, $ee, $ba, $za);
 		my $criterion = 'no';
		
 		# for each OG read the folder of the trees and read the tree for the OG		
		my $treesDir = opendir(TREESDIR, $path . 'Pipelinev2_2_archive/') or die "folder TREESDIR cannot be opened";
		my @treesDir = readdir TREESDIR;
		
 		foreach my $i (@treesDir) {
 			if ($i =~ $og){
 				my $tree = open(TREE, $path . 'Pipelinev2_2_archive/' . $i) or die "the tree $i cannot be open";
 				my $tree = <TREE>;
 				
  				# As the trees are in neweck format, we can make a list of leaves by 
  				# splitting the tree by the comas.
  				my @leaves = split(",", $tree);
  				
  				# if there are more than 10 leaves in the tree, it meets the criterion
 				if (scalar @leaves > 10){
 					$criterion = 'yes';

  					# Here we are going to clean the leaves, so that we can extract
  					# the major clade and minor clade (e.g., Sr_di).
  					# We collect all cleaned leaves in a list.
					foreach my $leaf (@leaves){
						$leaf =~ s/\(//g;
						$leaf =~ s/\)//g;
						my @rank = split("_", $leaf);
						my $minC = $rank[0]."_".$rank[1];
						push @minCs, $minC;
					}
 				}
			  	# Now that we have all the leaves (as Sr_di) in a list, we need to 
  				# remove duplicates:
 				@minCs = uniq(@minCs);
 				
 	  			# Finally, we count the number of minor clades per major clade there are 
  				# in the tree. 
  				foreach my $minC (@minCs){
					if ($minC =~ "Op_") {$op = $op + 1 }
					if ($minC =~ "Am_") {$am = $am + 1 }
					if ($minC =~ "Pl_") {$pl = $pl + 1 }
					if ($minC =~ "Ex_") {$ex = $ex + 1 }
					if ($minC =~ "Sr_") {$sr = $sr + 1 }
					if ($minC =~ "EE_") {$ee = $ee + 1 }
					if ($minC =~ "Ba_") {$ba = $ba + 1 }
					if ($minC =~ "Za_") {$za = $za + 1 }				
  				}				
 			}
 		}

 	  	# The report is corrected with criterion and counts and printed in the terminal
  		print "$line\t$og\t$criterion\t$op\t$am\t$pl\t$ex\t$sr\t$ee\t$ba\t$za\n";
  		print OUT "$line\t$og\t$criterion\t$op\t$am\t$pl\t$ex\t$sr\t$ee\t$ba\t$za\n";

	} else {
 	 	print "$line\n";
 	 	print OUT "$line\n";
 	}	
}