#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use POSIX qw/ floor /;
use File::Slurp;

#mysql> DESC ipv6_2;
#+---------+------------------+------+-----+---------+-------+
#| Field   | Type             | Null | Key | Default | Extra |
#+---------+------------------+------+-----+---------+-------+
#| pubkey  | varchar(52)      | YES  |     | NULL    |       |
#| privkey | varchar(64)      | YES  |     | NULL    |       |
#| addr1   | int(10) unsigned | NO   |     | NULL    |       |
#| addr2   | int(10) unsigned | NO   |     | NULL    |       |
#| addr3   | int(10) unsigned | NO   |     | NULL    |       |
#| addr4   | int(10) unsigned | NO   |     | NULL    |       |
#+---------+------------------+------+-----+---------+-------+


my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','<ENTER YOUR MYSQL PASSWORD HERE>') or die "Connection Error: $DBI::errstr\n";

my $sth = $dbh->prepare(genquery());
$sth->execute();

my $count = 0;
while (my $ref = $sth->fetchrow_hashref())
{
	$count++;
	print "$ref->{'pubkey'}, ".ints_to_ipv6($ref->{'addr1'},$ref->{'addr2'},$ref->{'addr3'},$ref->{'addr4'})."\n";
}
$sth->finish();
print "Got $count records\n";

sub genquery
{
	my $str = "SELECT pubkey,addr1,addr2,addr3,addr4 FROM ipv6_2 WHERE (";
	#$str .= get_chars_compare(1, 3);
	#$str .= "&&";
	#$str .= get_chars_compare(0, 2);
	$str .= "1);";
}

#sub genquery
#{
#	my $f = read_file("ipv6-cjdnet.data.txt");
#	
#	my $str = "SELECT pubkey,addr1,addr2,addr3,addr4 FROM ipv6_2 WHERE (\n";
#	#my $str;
#	
#	for my $line (split("\n", $f))
#	{
#		next if($line =~ /^#/);
#		my $addr = '';
#		{
#			my @v = split(" ", $line);
#			$addr = $v[0];
#		}
#		next if(!defined $addr);
#		
#		my $c = 0;
#		$str .= " (";
#		for(ipv6_to_ints($addr))
#		{
#			$c++;
#			$str .= " addr$c = $_";
#			$str .= " &&" if($c != 4);
#		}
#		$str .= " )\n || ";
#	}
#	substr($str, -3, 3, ");");
#	
#	#$str .= get_char_isvalue(28, '0');
#	#$str .= " && ";
#	#$str .= get_char_isvalue(29, '0');
#	#$str .= get_chars_compare(28, 29);
#	#$str .= " && ";
#	#$str .= get_chars_compare(30, 31);
#	print "STR: $str\n";
#	return $str;
#}

sub get_chars_compare
{
	my( $offseta, $offsetb ) = @_;
	($offseta, my $segnamea) = pos_to_segments($offseta);
	($offsetb, my $segnameb) = pos_to_segments($offsetb);
	
	my $offdiff = $offseta-$offsetb;
	
	"(`addr$segnamea`) & 0x".("0" x ($offseta))."f".("0" x (7-$offseta))." = ".
	"(((`addr$segnameb`) & 0x".("0" x ($offsetb))."f".("0" x (7-$offsetb)).") ".($offdiff < 0 ? "<<" : ">>").abs($offdiff*4).")";
}

sub get_char_isvalue
{
	my( $offset, $desired ) = @_;

	($offset, my $segname) = pos_to_segments($offset);
	
	my $test = "0x".("0" x $offset).$desired.("0" x (7-$offset));
	"(`addr$segname` & 0x".("0" x ($offset))."f".("0" x (7-$offset)).") = $test";
}

sub pos_to_segments
{
	my $offset = shift;
	
	my $segname = floor($offset / 8);
	$offset -= $segname*8;
	$segname++;
	
	return ($offset, $segname);
}

sub ipv6_to_ints
{
	my $ipv6 = shift;
	(my $clean = $ipv6) =~ s/://g;
	my @ints = ();
	while($clean=~s/(.{8})//)
	{
		my $i = hex($1);
		push @ints, $i;
	}
	@ints;
}

sub ints_to_ipv6
{
	my @ints = @_;
	my $addr = '';
	for(@ints)
	{
		my $i = sprintf("%08x", $_);
		$addr .= $i;
	}
	$addr =~ s/(.{4})(?=.)/$1:/g;
	$addr;
}
