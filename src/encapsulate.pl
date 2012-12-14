#!/usr/bin/perl
use strict;
use warnings;
use DBI;
my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','lolcoptersarego') or die "Connection Error: $DBI::errstr\n";
my $privstr;
my @privkey;

my $sth = $dbh->prepare("SELECT privkey FROM ipv6_3_data ORDER BY id DESC LIMIT 1;");
$sth->execute;

#@privkey = split("", "000000000000000000000000000000000000000000000000000000000000");#."0000");
#for(0..32)
#{
#	$privstr = "0000".privkey_to_str(@privkey);
#	print "Running ".$privstr."\n";
#	@privkey = increment_privkey(@privkey);
#}
#exit;

if(my $ref = $sth->fetchrow_hashref())
{
	print "Ensuring the script wasn't abruptly halted during inserts. Starting at ".$ref->{'privkey'}." and going to the end of the /16 block\n";
	my $count = 0;
	for(split("", $ref->{'privkey'}))
	{
		if($_ eq "a")
		{
			$privkey[$count] = 10;
		}
		elsif($_ eq "b")
		{
			$privkey[$count] = 11;
		}
		elsif($_ eq "c")
		{
			$privkey[$count] = 12;
		}
		elsif($_ eq "d")
		{
			$privkey[$count] = 13;
		}
		elsif($_ eq "e")
		{
			$privkey[$count] = 14;
		}
		elsif($_ eq "f")
		{
			$privkey[$count] = 15;
		}
		else
		{
			$privkey[$count] = $_;
		}
		$count++;
	}
	$privstr = privkey_to_str(@privkey);
	my $d = 
		substr($ref->{'privkey'}, 1, 1).
		substr($ref->{'privkey'}, 0, 1).
		substr($ref->{'privkey'}, 3, 1).
		substr($ref->{'privkey'}, 2, 1);
	print "D: $d\n";
	my $many = 65536-hex($d);
	
	print "Many: $many\n";
	
	for(split("\n", `./gen $privstr $many`))
	{
		my($addr,$priv) = split(",", $_);
		print "GOT: $addr - $priv\n";
		#insert_record($addr, $priv, $privstr);
	}
	print "EXIT EARLY\n";
	exit;
	shift(@privkey);
	shift(@privkey);
	shift(@privkey);
	shift(@privkey);
	increment_privkey(@privkey)
}
else
{
	print "No records detected, starting anew\n";
	@privkey = split("", "000000000000000000000000000000000000000000000000000000000000");#."0000");
}
$sth->finish();

print "Starting normal inserts at @privkey\n";

while(1)
{
	$privstr = "0000".privkey_to_str(@privkey);
	print "Running ".$privstr."\n";
	
	for(split("\n", `./gen $privstr 65536`))
	{
		my($addr,$priv) = split(",", $_);
		if(!$addr || !$priv)
		{
			next;
		}
		insert_record($addr, $priv, $privstr);
	}
	@privkey = increment_privkey(@privkey);
}

sub insert_record
{
	my( $addr, $priv, $iter ) = @_;
	$addr =~ s/\://g;
	my @addrlist = split("", $addr);
	
	my $q = "INSERT INTO ipv6_3_addr VALUES (DEFAULT,";
	for(0..$#addrlist)
	{
		$q .= "0x".$addrlist[$_];
		if($_ != $#addrlist)
		{
			$q .= ",";
		}
	}
	$q .= ");";
	$dbh->do($q);
	$dbh->do("INSERT INTO ipv6_3_data VALUES (".$dbh->{'mysql_insertid'}.",'$priv','$iter');");
	print "ADDED: $addr [privkey: $priv]\n";
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
		print "WE HIT THE END? WTF THAT TOOK FOREVER.\n";
		exit;
	}
	#print "IS: ".join(" ", @privkey)."\n";
	if($privkey[0] == 15)
	{
		shift(@privkey);
		@privkey = increment_privkey(@privkey);
		unshift(@privkey, 0);
		return @privkey;
	}
	$privkey[0]++;
	return @privkey;
}