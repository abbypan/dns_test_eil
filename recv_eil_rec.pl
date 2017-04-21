#!/usr/bin/perl 

require './eil.pm';

our $IS_GUESS = 1;

our %RECUR_CACHE; # simple test, ignore ttl expiration

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
                $res_pkt = $RECUR_CACHE{$c}{$a}{$i} 
                || $RECUR_CACHE{$c}{"*"}{$i} 
                || $RECUR_CACHE{$c}{$a}{"*"} 
                || $RECUR_CACHE{$c}{"*"}{"*"} ;
                
                if($res_pkt){
                    print "\n", strftime("%Y-%m-%d %H:%M:%S", localtime), "  *** find in recursive cache: $DOM, $c, $a, $i\n";
                }else{
                    print "\n", strftime("%Y-%m-%d %H:%M:%S", localtime), "  *** recursive to authority: $DOM, $c, $a, $i\n";
                    my $packet = new Net::DNS::Packet( $DOM, 'IN', 'A' );
                    push @{ $packet->{additional} }, gen_eil_opt( $c, $a, $i );
                    $res_pkt = $RESOLVER_TO_AUT->send($packet);
                }
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
        #cache, ignore ttl expiration for simple test
        my $res_eil_val = is_exists_eil($res_pkt);
        if ($res_eil_val) {
            my $e = read_eil_val($res_eil_val);
            print "write cache: $e->{country_code},$e->{area_code},$e->{isp}\n";
            $RECUR_CACHE{$e->{country_code}}{$e->{area_code}}{$e->{isp}} = $res_pkt;
        }

        return ( $res_pkt->header->rcode, 
            $res_pkt->{answer}, $res_pkt->{authority}, $res_pkt->{additional},
            { aa => 0 }
        );
    }
    return ( $rcode, \@ans, \@auth, \@add, { aa => 0 } );
}
