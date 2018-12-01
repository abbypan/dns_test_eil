#!/usr/bin/perl
use Data::Validate::IP qw/is_public_ipv4/;

for my $t ( 0 .. 255 ){
    my $f = "data/subnet.x.y.$t.log";
    open my $fh, '>', $f;
    for my $i ( 0 .. 255 ) {
        for my $j ( 0 .. 255 ) {
            my $ip = "$i.$j.$t.0";
            next unless(is_public_ipv4($ip));
            print $fh "$ip/24\n";
        }
    }
    close $fh;
    system("sort -R $f > $f.random");
    system("mv $f.random $f");
}
