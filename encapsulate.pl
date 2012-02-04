#!/usr/bin/perl
use strict;
use warnings;
use DBI;
my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','x59f3liam') or die "Connection Error: $DBI::errstr\n";

#my $sth = $dbh->prepare("SELECT * FROM ipv6;");
#$sth->execute;

#while (my $ref = $sth->fetchrow_hashref())
#{
#	print "$ref->{'pubkey'}, $ref->{'addr'}\n";
#}
#$sth->finish();

while(1)
{
	for(split("\n", `./build/cjdroute --genlots 100`))
	{
		print "STR: $_\n";
		my($pub,$addr,$priv) = split(",", $_);
		my $q = "INSERT INTO ipv6_2 VALUES ('".$pub."', '".$priv."'";
		for(ipv6_to_ints($addr))
		{
			$q .= ", $_";
		}
		$q .= ");";
		print "query: $q\n";
		$dbh->do($q);
		#$dbh->do("INSERT INTO ipv6 VALUES ('".$pub."', '".$addr."', '".$priv."');");

	}
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