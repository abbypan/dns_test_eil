#!/usr/bin/perl 

require './eil.pm';

our %EIL_Z;
read_eil_zone(\%EIL_Z, $DOM, 'eil_zone_www.qq.com.csv'); # test eil zone for www.qq.com

my $aut = new Net::DNS::Nameserver(
	LocalAddr	 => [ '127.0.0.1' ],
	LocalPort    => 53,
	ReplyHandler => \&reply_handler,
	Verbose      => 1
) || die "couldn't create nameserver object\n";

$aut->main_loop;

sub read_eil_zone {
    my ($eil_z, $dom, $zf) = @_;
    open my $fh, '<', $zf;
    <$fh>; #head
    while(my $d=<$fh>){
        $d=~s/\s+$//;
        my @r = split /,/i,  $d;
        $_ ||='' for @r;
        #@r : COUNTRY_CODE,AREA_CODE,ISP,QTYPE,QCLASS,TTL,RDATA
        push @{$eil_z->{$dom}{$r[3]}{$r[0]}{$r[1]}{$r[2]}}, "$dom $r[5] $r[4] $r[3] $r[6]";
    }
    close $fh;
    return $eil_z;
}

sub reply_handler {
	my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
	my ($rcode, @ans, @auth, @add);

    my $rr_arr;
    if ( $qtype eq "A" && $qname eq $DOM ) {
        my $eil_val = is_exists_eil($query);
        if($eil_val){
            my $e = read_eil_val($eil_val);
            if($e){
                my ($c, $a, $i)= @{$e}{qw/country_code area_code isp/};
                $rr_arr = $EIL_Z{$DOM}{$qtype}{$c}{$a}{$i}
                        || $EIL_Z{$DOM}{$qtype}{$c}{''}{$i}
                        || $EIL_Z{$DOM}{$qtype}{$c}{''}{''}
                        || $EIL_Z{$DOM}{$qtype}{''}{''}{''};

                my $res_eil = gen_eil_opt($c, $a, $i);
                print "\n*** authority find $DOM, $c, $a, $i, $rr_arr->[0]\n";
                push @add, $res_eil;
                $rcode = "NOERROR";
            }else{
                $rcode = "FORMERR";
            }
        }else{
            $rr_arr = $EIL_Z{$DOM}{$qtype}{''}{''}{''};
            $rcode = "NOERROR"; 
        }
    }elsif( $qname eq $DOM ) {
		$rcode = "NOERROR";
	}else{
		$rcode = "NXDOMAIN";
	}

    if($rr_arr){
        for my $rrd (@{$rr_arr}){
            my $rr = new Net::DNS::RR($rrd);
            push @ans, $rr;
        }
    }
	return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}
