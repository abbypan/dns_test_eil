#!/usr/bin/perl 

require './eil.pm';

our $IS_GUESS = 1;

our $RESOLVER_TO_AUT = new Net::DNS::Resolver(
    nameservers => ['127.0.0.1'],
    recurse     => 0,
    debug       => 1
);

my $recur = new Net::DNS::Nameserver(
    LocalAddr    => ['127.0.0.1'],
    LocalPort    => 5354,
    ReplyHandler => \&reply_handler,
    Truncate     => 0,
    Verbose      => 1
) || die "couldn't create nameserver object\n";

$recur->main_loop;

sub reply_handler {
    my ( $qname, $qclass, $qtype, $peerhost, $query, $conn ) = @_;
    my ( $rcode, @ans, @auth, @add );

    my $res_pkt;
    if ( $qtype eq "A" && $qname eq $DOM ) {
        my $eil_val = is_exists_eil($query);
        if ($eil_val) {
            my $e = read_eil_val($eil_val, $IS_GUESS);
            if ($e) {
                my ( $c, $a, $i ) = @{$e}{qw/country_code area_code isp/};
                print "\n*** recursive to authority: $DOM, $c, $a, $i\n";

                my $packet = new Net::DNS::Packet( $DOM, 'IN', 'A' );
                push @{ $packet->{additional} }, gen_eil_opt( $c, $a, $i );
                $res_pkt = $RESOLVER_TO_AUT->send($packet);
            }
            else {
                $rcode = "FORMERR";
            }
        }
        else {
            $res_pkt = $RESOLVER_TO_AUT->send($query);
        }
    }

    if ($res_pkt) {
        return ( $res_pkt->header->rcode, 
            $res_pkt->{answer}, $res_pkt->{authority}, $res_pkt->{additional},
            { aa => 0 }
        );
    }
    return ( $rcode, \@ans, \@auth, \@add, { aa => 0 } );
}
