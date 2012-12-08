#!/usr/bin/perl
use strict;
use warnings;
use DBI;
my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','lolcoptersarego') or die "Connection Error: $DBI::errstr\n";

#my $sth = $dbh->prepare("SELECT * FROM ipv6;");
#$sth->execute;

#while (my $ref = $sth->fetchrow_hashref())
#{
#	print "$ref->{'pubkey'}, $ref->{'addr'}\n";
#}
#$sth->finish();

my @privkey = split("", "000000000000000000000000000000000000000000000000000000000000");#."0000");
my $privstr;

while(1)
{
	#print join(" ", @privkey)."\n";
	#next;
	$privstr = "0000".privkey_to_str(@privkey);
	print "privstr: ".$privstr."\n";
	
	for(split("\n", `./gen $privstr 65535`))
	{
		print "$_\n";
		my($pub,$addr,$priv) = split(",", $_);
		my $q = "INSERT INTO ipv6_2 VALUES ('".$pub."', '".$priv."'";
		for(ipv6_to_ints($addr))
		{
			$q .= ", $_";
		}
		$q .= ");";
		$dbh->do($q);
		#$dbh->do("INSERT INTO ipv6 VALUES ('".$pub."', '".$addr."', '".$priv."');");
	}
	@privkey = increment_privkey(@privkey);
}

sub privkey_to_str
{
	my @privkey = @_;
	my $str = '';
	for(@privkey)
	{
		if($_ >= 10)
		{
			if($_ == 10)
			{
				$str .= "a";
			}
			elsif($_ == 11)
			{
				$str .= "b";
			}
			elsif($_ == 12)
			{
				$str .= "c";
			}
			elsif($_ == 13)
			{
				$str .= "d";
			}
			elsif($_ == 14)
			{
				$str .= "e";
			}
			else #elsif($_ == 15)
			{
				$str .= "f";
			}
		}
		else
		{
			$str .= $_;
		}
	}
	return $str;
}

sub increment_privkey
{
	my @privkey = @_;
	if(!@privkey)
	{
		return;
	}
	if($privkey[0] == 16)
	{
		shift(@privkey);
		@privkey = increment_privkey(@privkey);
		return (0, @privkey);
	}
	$privkey[0]++;
	return @privkey;
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