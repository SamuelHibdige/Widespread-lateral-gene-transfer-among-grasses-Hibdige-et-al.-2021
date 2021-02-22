use strict;

my($target,$target_same,$tree,@tree_cut,$i,$nameprov,$blreading,$bvreading,@group,@sisters,@sisters2,$semialata_name,$bootstrap,$folder,@treefiles,$j,$boot1,$boot2,$k,$ignoredgroup,$ignoredgroup1,$ignoredgroup2,$ignoresame,@ignored);
my(@paniceae,@pooideae,@oryzeae,@chloridoideae,@andropogoneae,@other);
my($paniceae_count,$oryzeae_count,$pooideae_count,$chloridoideae_count,$andropogoneae_count,$other_count);

$folder=$ARGV[0]; # folder that contains the trees to scan
if(not $folder){die "forgot to specify a folder\n";}

#$ignoresame="on"; #value must be "on" to ignore the names from the same group as the target
$ignoresame="off";

$target=$ARGV[1];
if(not $target){die "forgot to specify a target\n";}
#$target="Andropogoneae_zea_mays";  #name of the target species

@ignored=(); # list of taxa that will be ignored if $ignorename is not "on"
@paniceae=("Lasiacis_sorghoidea","Dichanthelium_oligosanthes","Dichanthelium_clandestinum","Panicum_hallii","Panicum_queenslandicum","Panicum_vigratum","Cenchrus_americanus","Setaria_barbata","setaria_italica","Megathirsus_maximus","Acroceras_zizanioides","Digitaria_ciliaris","Homopholis_proluta","Panicum_pygmaeum","Sacciolepis_striata","GENOME_Alloteropsis","GENOME_Alloteropsis_semialata_ASEM","Echinochloa_crus-galli","Echinochloa_stagnina","Cyrtococcum_patens");if($target~~ @paniceae and $ignoresame eq "on"){@ignored=@paniceae;@paniceae=();}
@pooideae=("brachypodium_distachyon","hordeum_vulgare","Poeae_spp","triticum_aestivum");if($target~~ @pooideae and $ignoresame eq "on"){@ignored=@pooideae;@pooideae=();}
@oryzeae=("leersia_perrieri","oryza_sativa");if($target~~ @oryzeae and $ignoresame eq "on"){@ignored=@oryzeae;@oryzeae=();}
@chloridoideae=("Dactyloctenium_aegyptium","Eragrostis_tef","Oropetium_thomaeum","Zoysia_japonica");if($target~~ @chloridoideae and $ignoresame eq "on"){@ignored=@chloridoideae;@chloridoideae=();}
@andropogoneae=("zea_mays","sorghum_bicolor");if($target~~ @andropogoneae and $ignoresame eq "on"){@ignored=@andropogoneae;@andropogoneae=();}
@other=("Chasmanthium_latifolium","Danthonia_californica","Stipagrostis_hirtigluma","Hymenachne_amplexicaulis","Otachyrinae_spp","Paspalum_fimbriatum");if($target~~ @other and $ignoresame eq "on"){@ignored=@other;@other=();}

`ls $folder/*phyml_tree.txt >list_trees`;

#$tree="((((((((Paspalum_fimbriatum:0.05315901,(Hymenachne_amplexicaulis:0.02965566,Otachyrinae_spp:0.03373466)97:0.0153187)100:0.02523481,zea_mays:0.09813171)97:0.01298781,(Cyrtococcum_patens:0.0569121,((Panicum_queenslandicum:0.01682194,Panicum_hallii:0.01216195)100:0.03079131,(Dichanthelium_clandestinum:0.00288363,Dichanthelium_oligosanthes:0.00646181)96:0.02002557)72:0.00655885)81:0.01499054)68:0.0265112,(Panicum_pygmaeum:0.03030886,(Homopholis_proluta:0.03299191,(((setaria_italica:0.01575365,(Setaria_barbata:0.01669581,Cenchrus_americanus:0.03353789)71:0.00362161)85:0.02553629,(Sacciolepis_striata:0.0372731,Digitaria_ciliaris:0.05019398)96:0.01283437)24:0.00133218,((Acroceras_zizanioides:0.04907078,((Echinochloa_stagnina:0.00232862,Echinochloa_crusgalli:0.00183758)100:0.0441026,(Panicum_vigratum:0.04512719,ASEM_C4_00084:0.04656175)38:0.00238627)53:0.00337235)20:0.00112179,Lasiacis_sorghoidea:0.04887761)36:0.00230704)73:0.02921038)72:0.01343289)58:0.01381934)55:0.01660822,Chasmanthium_latifolium:0.09757951)91:0.02106562,(Stipagrostis_hirtigluma:0.10224271,(Dactyloctenium_aegyptium:0.09481914,Eragrostis_tef:0.06386771)98:0.045322)63:0.01284151)24:2.498e-05,Danthonia_californica:0.08332094)100:0.03636223,(((triticum_aestivum:0.02147066,hordeum_vulgare:0.04654187):0.08159273,Poeae_spp:0.13146301)100:0.02465448,leersia_perrieri:0.18729435)95:0.02439742)Root;";

open(FILE1,"<list_trees");
$i=0;
while(!eof(FILE1)){
	$treefiles[$i]=readline *FILE1;
	$treefiles[$i]=~ s/\n//g;
	$treefiles[$i]=~ s/\r//g;
	$i++;
	}
close(FILE1);

open(OUTFILE,">results_sister");
print OUTFILE "gene\tboot1\tboot2\tsister1\tsister1_group\tignoredgroup1\tsister2\tsister2_group\tignoredgroup2\n";
$j=0;
while($j<@treefiles){
open(FILE1,"<$treefiles[$j]");
$tree=readline *FILE1;
$tree=~ s/\n//g;
$tree=~ s/\r//g;

undef @group;
undef @sisters;
undef @sisters2;
undef $semialata_name;
@tree_cut=split(//,$tree);
$i=0;
$blreading=0;
$bvreading=0;
$boot1="NA";
$boot2="NA";
$ignoredgroup1=0;
$ignoredgroup2=0;

$bootstrap="";
while($i<@tree_cut){
if($tree_cut[$i] eq "("){$nameprov="";$bvreading=0;}
elsif($tree_cut[$i] eq ","){
	$bvreading=0;
	if($nameprov ne ""){
		if($nameprov=~ m/$target/){$semialata_name=$nameprov;}
		push @group,[$nameprov];
		$nameprov="";
		}
	$blreading=0;
	}
elsif($tree_cut[$i] eq ")"){
	$bvreading=1;
	if($boot1 eq "prov"){$boot1=$bootstrap;}
	if($boot2 eq "prov"){$boot2=$bootstrap;}
	if($nameprov ne ""){
		if($nameprov=~ m/$target/){$semialata_name=$nameprov;}
		push @group,[$nameprov];
		$nameprov="";
		}
	if($boot1 eq "NA" and @group>1){
		$k=0;
		$ignoredgroup=0;
		while($k<@{$group[-1]}){
			if($group[-1][$k]~~ @ignored){$ignoredgroup++;}
			$k++;
			}
		if($semialata_name~~ @{$group[-2]} and $ignoredgroup==@{$group[-1]}){$ignoredgroup1=$ignoredgroup1+$ignoredgroup;}
		if($semialata_name~~ @{$group[-2]} and $ignoredgroup<@{$group[-1]}){
			@sisters=@{$group[-1]};
			$ignoredgroup1=$ignoredgroup1+$ignoredgroup;;
			$boot1="prov";
			}
		$k=0;
		$ignoredgroup=0;
		while($k<@{$group[-2]}){
			if($group[-2][$k]~~ @ignored){$ignoredgroup++;}
			$k++;
			}
		if($semialata_name~~ @{$group[-1]} and $ignoredgroup==@{$group[-2]}){$ignoredgroup1=$ignoredgroup1+$ignoredgroup;}
		if($semialata_name~~ @{$group[-1]} and $ignoredgroup<@{$group[-2]}){
			@sisters=@{$group[-2]};
			$ignoredgroup1=$ignoredgroup1+$ignoredgroup;
			$boot1="prov";
			}
		}
	elsif($boot2 eq "NA"){
		$k=0;
		$ignoredgroup=0;
		while($k<@{$group[-2]}){
			if($group[-2][$k]~~ @ignored){$ignoredgroup++;}
			$k++;
			}
		if($semialata_name~~@{$group[-1]} and $ignoredgroup==@{$group[-2]}){$ignoredgroup2=$ignoredgroup2+$ignoredgroup;}
		if($semialata_name~~@{$group[-1]} and $ignoredgroup<@{$group[-2]}){
			@sisters2=@{$group[-2]};
			$ignoredgroup2=$ignoredgroup2+$ignoredgroup;
			$boot2="prov";
			}
		$k=0;
		$ignoredgroup=0;
		while($k<@{$group[-1]}){
			if($group[-1][$k]~~ @ignored){$ignoredgroup++;}
			$k++;
			}
		if($semialata_name~~@{$group[-2]} and $ignoredgroup==@{$group[-1]}){$ignoredgroup2=$ignoredgroup2+$ignoredgroup;}
		if($semialata_name~~@{$group[-2]} and $ignoredgroup<@{$group[-1]}){
			@sisters2=@{$group[-1]};
			$ignoredgroup2=$ignoredgroup2+$ignoredgroup;
			$boot2="prov";
			}
		}
	if(@group>1){
		push @{$group[-2]},@{$group[-1]};
		splice (@group,-1);
		}
	$bootstrap="";
	}
elsif($tree_cut[$i] eq ":"){
	$blreading=1;
	$bvreading=0;
	}
elsif($tree_cut[$i] eq ";"){
	$bvreading=0;
	}
elsif($bvreading==1){
	$bootstrap=$bootstrap.$tree_cut[$i];
	}
elsif($blreading==0 and $bvreading==0){$nameprov=$nameprov.$tree_cut[$i];}
$i++;
}

print OUTFILE $semialata_name."\t";
if($boot1 ne "" and $boot1 ne "prov"){print OUTFILE $boot1."\t";}
else{print OUTFILE "NA\t";}
if($boot2 ne "" and $boot2 ne "prov"){print OUTFILE $boot2."\t";}
else{print OUTFILE "NA\t";}

$i=1;
print OUTFILE $sisters[0];
if($sisters[0]~~@paniceae){$paniceae_count=1;}else{$paniceae_count=0;}
if($sisters[0]~~@pooideae){$pooideae_count=1;}else{$pooideae_count=0;}
if($sisters[0]~~@oryzeae){$oryzeae_count=1;}else{$oryzeae_count=0;}
if($sisters[0]~~@chloridoideae){$chloridoideae_count=1;}else{$chloridoideae_count=0;}
if($sisters[0]~~@andropogoneae){$andropogoneae_count=1;}else{$andropogoneae_count=0;}
if($sisters[0]~~@other){$other_count=1;}else{$other_count=0;}
if($sisters[0]~~@ignored){$ignoredgroup=1;}else{$ignoredgroup=0;}
while($i<@sisters){
	if($sisters[$i]~~@paniceae){$paniceae_count++;}
	if($sisters[$i]~~@pooideae){$pooideae_count++;}
	if($sisters[$i]~~@oryzeae){$oryzeae_count++;}
	if($sisters[$i]~~@chloridoideae){$chloridoideae_count++;}
	if($sisters[$i]~~@andropogoneae){$andropogoneae_count++;}
	if($sisters[$i]~~@other){$other_count++;}
	if($sisters[$i]~~@ignored){$ignoredgroup++;}
	print OUTFILE ",".$sisters[$i];
	$i++;
	}
if($sisters[0] eq ""){print OUTFILE "\tNA";print "check1\n";}
elsif($paniceae_count==@sisters or $ignoredgroup+$paniceae_count==@sisters){print OUTFILE "\tpaniceae";}
elsif($pooideae_count==@sisters or $pooideae_count+$ignoredgroup==@sisters){print OUTFILE "\tpooideae";}
elsif($oryzeae_count==@sisters or $oryzeae_count+$ignoredgroup==@sisters){print OUTFILE "\toryzeae";}
elsif($oryzeae_count+$pooideae_count==@sisters or $pooideae_count+$oryzeae_count+$ignoredgroup==@sisters){print OUTFILE "\tBEP";}
elsif($chloridoideae_count==@sisters or $chloridoideae_count+$ignoredgroup==@sisters){print OUTFILE "\tchloridoideae";}
elsif($andropogoneae_count==@sisters or $andropogoneae_count+$ignoredgroup==@sisters){print OUTFILE "\tandropogoneae";}
elsif($other_count==@sisters or $other_count+$ignoredgroup==@sisters){print OUTFILE "\tother";}
else{print OUTFILE "\tmixed";}

print OUTFILE "\t".$ignoredgroup1;
$i=1;
print OUTFILE "\t";
print OUTFILE $sisters2[0];

if($sisters2[0]~~@paniceae){$paniceae_count=1;}else{$paniceae_count=0;}
if($sisters2[0]~~@pooideae){$pooideae_count=1;}else{$pooideae_count=0;}
if($sisters2[0]~~@oryzeae){$oryzeae_count=1;}else{$oryzeae_count=0;}
if($sisters2[0]~~@chloridoideae){$chloridoideae_count=1;}else{$chloridoideae_count=0;}
if($sisters2[0]~~@andropogoneae){$andropogoneae_count=1;}else{$andropogoneae_count=0;}
if($sisters2[0]~~@other){$other_count=1;}else{$other_count=0;}
if($sisters2[0]~~@ignored){$ignoredgroup=1;}else{$ignoredgroup=0;}
while($i<@sisters2){
	if($sisters2[$i]~~@paniceae){$paniceae_count++;}
	if($sisters2[$i]~~@pooideae){$pooideae_count++;}
	if($sisters2[$i]~~@oryzeae){$oryzeae_count++;}
	if($sisters2[$i]~~@chloridoideae){$chloridoideae_count++;}
	if($sisters2[$i]~~@andropogoneae){$andropogoneae_count++;}
	if($sisters2[$i]~~@other){$other_count++;}
	if($sisters2[$i]~~@ignored){$ignoredgroup++;}
	print OUTFILE ",".$sisters2[$i];
	$i++;
	}
if($sisters2[0] eq ""){print OUTFILE "\tNA";}
elsif($paniceae_count==@sisters2 or $ignoredgroup+$paniceae_count==@sisters2){print OUTFILE "\tpaniceae";}
elsif($pooideae_count==@sisters2 or $pooideae_count+$ignoredgroup==@sisters2){print OUTFILE "\tpooideae";}
elsif($oryzeae_count==@sisters2 or $oryzeae_count+$ignoredgroup==@sisters2){print OUTFILE "\toryzeae";}
elsif($oryzeae_count+$pooideae_count==@sisters2 or $oryzeae_count+$pooideae_count+$ignoredgroup==@sisters2){print OUTFILE "\tbep";}
elsif($chloridoideae_count==@sisters2 or $chloridoideae_count+$ignoredgroup==@sisters2){print OUTFILE "\tchloridoideae";}
elsif($andropogoneae_count==@sisters2 or $andropogoneae_count+$ignoredgroup==@sisters2){print OUTFILE "\tandropogoneae";}
elsif($other_count==@sisters2 or $other_count+$ignoredgroup==@sisters2){print OUTFILE "\tother";}
else{print OUTFILE "\tmixed";}
print OUTFILE "\t".$ignoredgroup2."\n";
$j++;
}
