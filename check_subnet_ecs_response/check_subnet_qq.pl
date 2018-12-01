#!/usr/bin/perl
use strict;
use warnings;

use SimpleR::Reshape;
use POSIX;

my ($ns, $dom) = @ARGV;
$ns ||='123.151.66.83';
$dom ||='www.qq.com';

my @subnet_f = glob("data/subnet.x.y.[0-9]*.log");
for my $sf (@subnet_f){
    my $res_f = $sf;
    $res_f=~s/\.log$/.res/;
    print "$sf -> $res_f\n";

    split_file($sf, line_cnt => 100) unless(-f $res_f);
    my @temp_f = glob("$sf.*");
    next unless(@temp_f);

    open my $fhw, '>>', $res_f;
    for my $tf (@temp_f){
        my $now = strftime("%Y%m%d%H%M%S",localtime);
        print "$now: $tf\n";
        open my $fh, '<', $tf;
        while(my $subnet=<$fh>){
            chomp($subnet);
            my $r = dig_dom_ecs($ns, $dom, $subnet);
            print $fhw join(";", @{$r}[2,3,4]),"\n"; 
        }
        close $fh;
        unlink($tf);
    }
    close $fhw;
}

sub dig_dom_ecs {
    my ($ns, $dom, $subnet) = @_;
    my $c = `dig +short \@$ns $dom +subnet=$subnet`;
    my @rr = split /\n+/, $c;
    my @cname;
    while(@rr){
        my $r = $rr[0];
        if($r!~/^\d+\.\d+\.\d+\.\d+$/){
            push @cname, $r;
            shift @rr;
        }else{
            last;
        }
    }
    @rr = sort @rr;
    return [ $ns, $dom, $subnet, join(",", @cname), join(",", @rr) ];
}
