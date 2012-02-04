package CJDRoute::Querymaker;
use Moose;
use POSIX qw/ floor /;
use feature qw/ switch /;

has 'query_privkey' => (is=>"rw", isa=>"Bool", default=>0);
has 'order' => (is=>"rw", isa=>"Str", default=>'ORDER BY (addr4 & 0x0000ffff)');
has 'limit' => (is=>"rw", isa=>"Int", default=>150);
has 'offset' => (is=>"rw", isa=>"Int", default=>0);

has 'query' => (is=>"rw", isa=>"Str", default=>"");
has 'count' => (is=>"rw", isa=>"Int", default=>0);

sub BUILD
{
	my $self = shift;
	$self->query('SELECT pubkey,'.($self->query_privkey()? 'privkey,' : '').'addr1,addr2,addr3,addr4 FROM ipv6_2 ');
}

sub find_with_wildcard
{
	my( $self, $search ) = @_;
	print "SEARCH: $search\n";
	$search =~ s/://g; # strip colons
	my %charalloc = ();
	for my $iter (0..31)
	{
		my $char = substr($search, 0, 1, "") // "*"; # provided or wildcard
		given($char)
		{
			when('*')
			{
				# do nothing
			};
			when(/[0-9a-f]/)
			{
				$self->get_char_isvalue($iter, $char);
			};
			when(/[g-z]/)
			{
				if(defined $charalloc{$char})
				{
					print "COMPARING: $charalloc{$char}, $iter\n";
					$self->compare_chars($charalloc{$char}, $iter);
				}
				else
				{
					$charalloc{$char} = $iter;
				}
			}
		}
	}
}

sub get_querystring
{
	my $self = shift;
	return $self->query();
}

sub append_query
{
	my( $self, $str ) = @_;
	$self->query($self->query().'WHERE (') if($self->count() == 0);
	$self->query($self->query().$str." && ");
	$self->count($self->count()+1);
}

sub end_query
{
	my( $self ) = @_;
	my $str = $self->query();
	if($self->count == 0)
	{
		$str .= "WHERE(1=1)";
	}
	else
	{
		substr($str, -4, 4, ")")
	}
	$str .= " ".$self->order." LIMIT ".$self->limit." OFFSET ".$self->offset.";"; # remove " && " from append_query
	$self->query($str);
}

sub compare_chars
{
	my( $self, $offseta, $offsetb ) = @_;
	($offseta, my $segnamea) = pos_to_segments($offseta);
	($offsetb, my $segnameb) = pos_to_segments($offsetb);
	
	my $offdiff = $offseta-$offsetb;
	
	$self->append_query(
		"(`addr$segnamea`) & 0x".("0" x ($offseta))."f".("0" x (7-$offseta))." = ".
		"(((`addr$segnameb`) & 0x".("0" x ($offsetb))."f".("0" x (7-$offsetb)).") ".($offdiff < 0 ? "<<" : ">>").abs($offdiff*4).")"
	);
}

sub get_char_isvalue
{
	my( $self, $offset, $desired ) = @_;

	($offset, my $segname) = pos_to_segments($offset);
	
	$self->append_query(
		"(`addr$segname` & 0x".("0" x ($offset))."f".("0" x (7-$offset)).") = 0x".("0" x $offset).$desired.("0" x (7-$offset))
	);
}

##
## INTERNAL
##

sub pos_to_segments
{
	my $offset = shift;
	
	my $segname = floor($offset / 8);
	$offset -= $segname*8;
	$segname++;
	
	return ($offset, $segname);
}

package CJDRoute::Utils;
use strict;
use warnings;

sub fixcolons 
{
	my $ipv6 = shift;
	$ipv6 =~ s/://g; # strip
	$ipv6 =~ s/(.{4})(?=.)/$1:/g; #re-add every 4
	$ipv6;
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

1;