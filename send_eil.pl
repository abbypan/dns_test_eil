#!/usr/bin/perl

require './eil.pm';

my ($dom, $country_code, $area_code, $isp) =@ARGV;

$resolver = new Net::DNS::Resolver(
	nameservers => [ '127.0.0.1' ],
	recurse     => 0,
	debug       => 1
);
$resolver->port(5354);

$packet = new Net::DNS::Packet($dom, 'IN', 'A');
push @{$packet->{additional}}, gen_eil_opt($country_code, $area_code, $isp);

my $reply = $resolver->send($packet);
$reply->print;
