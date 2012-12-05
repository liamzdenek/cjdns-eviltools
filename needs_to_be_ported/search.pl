#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use POSIX qw/ floor /;
use File::Slurp;

require 'querymaker.pm';

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


my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','lolcoptersarego') or die "Connection Error: $DBI::errstr\n";

my $sth = $dbh->prepare(all_end_with_same_value());
$sth->execute();

use Data::Dumper qw/ Dumper /;

my $count = 0;
while (my $ref = $sth->fetchrow_hashref())
{
	$count++;
	print "$ref->{'pubkey'}, ".CJDRoute::Utils::ints_to_ipv6($ref->{'addr1'},$ref->{'addr2'},$ref->{'addr3'},$ref->{'addr4'})."\n";
}
$sth->finish();
print "Got $count records\n";

sub all_end_with_same_value
{
	my $q = CJDRoute::Querymaker->new();
	$q->find_with_wildcard('****:****:****:****:****:****:****:xxxx');
	$q->end_query();
	print "QUERY: ".$q->get_querystring()."\n";
	return $q->get_querystring();
}

sub all_end_with_zero
{
	my $str = "SELECT pubkey,addr1,addr2,addr3,addr4 FROM ipv6_2 WHERE (";
	$str .= get_char_isvalue(28, 0);
	$str .= "&&";
	$str .= get_char_isvalue(29, 0);
	$str .= "&&";
	$str .= get_char_isvalue(30, 0);
	$str .= "&&";
	$str .= get_char_isvalue(31, 0);
	$str .= ");";
}

sub collision_check
{
	my $f = read_file("ipv6-cjdnet.data.txt");
	
	my $str = "SELECT pubkey,addr1,addr2,addr3,addr4 FROM ipv6_2 WHERE (\n";
	#my $str;
	
	for my $line (split("\n", $f))
	{
		next if($line =~ /^#/);
		my $addr = '';
		{
			my @v = split(" ", $line);
			$addr = $v[0];
		}
		next if(!defined $addr);
		
		my $c = 0;
		$str .= " (";
		for(ipv6_to_ints($addr))
		{
			$c++;
			$str .= " addr$c = $_";
			$str .= " &&" if($c != 4);
		}
		$str .= " )\n || ";
	}
	substr($str, -3, 3, ");");
	
	#$str .= get_char_isvalue(28, '0');
	#$str .= " && ";
	#$str .= get_char_isvalue(29, '0');
	#$str .= get_chars_compare(28, 29);
	#$str .= " && ";
	#$str .= get_chars_compare(30, 31);
	print "STR: $str\n";
	return $str;
}