#!/usr/bin/perl
use strict;
use warnings;
BEGIN { use Net::INET6Glue }
use Mojolicious::Lite;
use DBI;

require 'querymaker.pm';

my $dbh = DBI->connect('dbi:mysql:database=cjdns_ips','root','lolcoptersarego') or die "Connection Error: $DBI::errstr\n";
our $offset_incr = 150;

sub startup
{
	my $self = shift;
}

get '/' => sub {
	my $self = shift;
	$self->stash(offset_incr => $offset_incr); 
	$self->render('template' => 'time');
};

# Route with placeholder
post '/q' => sub {
	my $self = shift;
	my $addr  = $self->param('query');
	
	my $q = CJDRoute::Querymaker->new(offset=>$self->param('offset') // 0);
	$q->find_with_wildcard($addr);
	$q->end_query();
	$q = $q->get_querystring();

	print "FULL QUERY: $q\n";	
	
	my $sth = $dbh->prepare($q);
	$sth->execute();
	
	my @json = ();
	
	my $count = 0;
	while (my $ref = $sth->fetchrow_hashref())
	{
		$count++;
		push @json,
			[
				CJDRoute::Utils::ints_to_ipv6
				(
					$ref->{'addr1'},
					$ref->{'addr2'},
					$ref->{'addr3'},
					$ref->{'addr4'}
				),
				$ref->{'pubkey'}
			];
	}
	$self->render_json(\@json);
};

# Start the Mojolicious command system
app->start;

__DATA__

@@ time.html.ep
<!DOCTYPE html>
	<html>
	<head>
		<title>Search all the things</title>
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
		<script type="text/javascript">
			var offset = 0;
			var offset_incr = <%= $offset_incr %>;
			function get_records()
			{
				$.post(
					"/q",
					{ query:$('#query').val(), 'offset':offset },
					function (data)
					{
						$('#data').html('<pre></pre>');
						for(var ipv6 in data)
						{
							$('#data pre').append(data[ipv6][0]+' - '+data[ipv6][1]+"\n");
						}
						if(offset-offset_incr >= offset_incr)
						{
							$('#data').append('<a href="javascript:offset=0;get_records();"> First </a>');
							$('#data').append('<a href="javascript:offset-=offset_incr;get_records();"> Previous </a>');
						}
						$('#data').append('<a href="javascript:offset+=150;get_records();">Next<a>');
					}
				)
			}
		</script>
	</head>
	<body>
		<h1>CJDNS IPv6 Database Search</h1>
		<form>
			Query String: <input id="query" name="query"><input type="button" value="Submit" onclick="javascript:offset=0;get_records()">
		</form>
		<div id='data'>
		</div>
	</body>
</html>