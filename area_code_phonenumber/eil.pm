use Net::DNS::Nameserver;
use Net::DNS::Resolver;
use Net::DNS;
use POSIX;
use Encode;
use JSON;
use File::Slurp qw/slurp/;
use Data::Dumper;

our $DOM = 'www.qq.com';
our $EIL_CODE = 0xFDF0;
my $whitelist= slurp('eil_whitelist.json');
our $EIL_W = decode_json( $whitelist );    #whitelist

sub is_exists_eil {
    my ($query) = @_;
    my $opt = $query->edns;
    return unless ($opt);
    my $eil_val = $opt->{option}{$EIL_CODE};
    return $eil_val;
}

sub read_eil_val {
    my ($eil_val, $is_guess) = @_;

    my ( $country_code, $area_code, $isp ) = $eil_val =~ /^(.{2})(.{4})(.{4})/;
    $country_code =~ s/^\s+|\s+$//g;
    $area_code =~ s/^\s+|\s+$//g;
    $isp =~ s/^\s+|\s+$//g;

    my $eil = {
        country_code => $country_code,
        area_code    => $area_code,
        isp          => $isp,
    };
    return $is_guess ? guess_eil($eil) : strict_eil($eil) ;
}

sub strict_eil {
    my ($eil) = @_;
    my ( $c, $a, $i ) = @{$eil}{ 'country_code', 'area_code', 'isp' };

    return unless ( exists $EIL_W->{$c} );
    return unless ( exists $EIL_W->{$c}{area}{$a} );
    return unless ( exists $EIL_W->{$c}{isp}{$i} );

    return $eil;
}

sub guess_eil {
    my ($eil) = @_;

    my ( $c, $a, $i ) = @{$eil}{ 'country_code', 'area_code', 'isp' };

    $eil->{'country_code'} = '' unless ( exists $EIL_W->{$c} );
    $eil->{'area_code'} = ''
      unless ( exists $EIL_W->{$c}{area}{$a} );
    $eil->{'isp'} = '' unless ( exists $EIL_W->{$c}{isp}{$i} );

    return $eil;
}

sub gen_eil_opt {
    my ( $country_code, $area_code, $isp ) = @_;
    my $eil_opt = new Net::DNS::RR(
        type  => 'OPT',
        flags => 0,
        rcode => 0,
    );
    my $eil_val = gen_eil_val( $country_code, $area_code, $isp );
    $eil_opt->option( $EIL_CODE => $eil_val );
    return $eil_opt;
}

sub gen_eil_val {
    my ( $country_code, $area_code, $isp ) = @_;
    $country_code = uc($country_code);
    $isp    = uc($isp);

    my $eil_val = pack( 'A2A4A4', $country_code, $area_code, $isp );
    return $eil_val;
}

