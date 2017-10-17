# This script helps to correct the file 'mapInfo' produced by the script 'intervals'
# The problems in mapInfo is that some intervals have more than one sequence/og associated.
# This scripts takes the intervals that contain exactly two sequences/ogs, splits the 
# sequences/ogs and put the second sequence/og in the next interval. Beware that this is 
# just a method that I propose to solve the problem. If the first codons of two sequences 
# are in the same interval, it is very likelly that they also occupy the next interval. 
# This iscript resolve most of the problematic cases. However, some cases would need manual
# inspection.

# In which cases this script is not useful (rare cases): 
# - When the next interval already contains a sequence/og.
# - When instead of 2 sequences per interval you have more than 2

my $folder = 'Saccharomyces_cerevisiae/';
my $path = '/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/';
my $out = open(OUT, ">>" . $path . $folder . 'mapInfo_corrected.txt') or die "I cannot open OUT\n";
my $mapinfo = open(MAPINFO, $path . $folder . 'mapInfo.txt');
my @mapinfo = <MAPINFO>;

my @map = ();
my $i = 0;
my $to_add = "";

# Reading mapInfo ...
foreach my $line (@mapinfo) {
	chomp $line;
	$i += 1;
	my @values = split("\t", $line);
	
	# ---------------------------
	# It is going to print each line in the output exactly as in mapInfo except when there 
	# are 2 sequences mapped in the same interval. When it is in a interval with 2
	# sequences, it prints only the first sequence for the current interval and saves 
	# the second sequence in the global variable "to_add". For the next iteration, if the 
	# interval is empty, it adds the sequence saved in to_add. Before ending the iteration 
	# to_add sould be set to "" again, so that it can be used in a further iterations with
	# interval containing two sequences. 
	# ----------------------------	
	
	if (scalar @values == 24) {						# if two sequences in the current interval ...		
		my $first = join("\t", @values[0..12]);		# takes the first seq
		my $second = join("\t", @values[13..23]);	# takes the second seq
		$to_add = "";
		my @nextline = split("\t", $mapinfo[$i]);	# explore ahead the line of mapinfo that would
													# be used in the next iteration.
		if (scalar @nextline == 2) {				# if the next line is epnty ...
			$to_add = $second;						# put the second sequence in global variable "to_add
			$line = $first;							# modify the line of mapInfo and print the interval with 
			print "$line\n";						# only the first sequence.
			print OUT "$line\n";
		} else {									# But is the next iteration is in a interval that already 
			print "$line\n";						# has a sequence, then don't split anything and print	
			print OUT "$line\n";					# exactly as in mapinfo.
		}
	}

	# if the next iteration is in a enpty interval, it would add the sequence saved in 
	# the previous iteration by adding the global variable "to_add" to the line of mapinfo

 	if (scalar @values == 2) {
 		if ($to_add ne "") {
 			my $line = $line . "\t" . $to_add;
 			$to_add = "";
			print "$line\n";
			print OUT "$line\n";
 		} else {
			print "$line\n";
			print OUT "$line\n";
 		}
 	}

	# if the next iteration interval containing either one sequence or more than 2, it
	# would print the line of mapinfo without any modification.  	

 	if (scalar @values == 13 || scalar @values > 24) {
 		$to_add = "";
 		print "$line\n";
		print OUT "$line\n";
 	}
}
