#!/usr/bin/perl
use SimpleR::Reshape;
use SimpleR::Stat;

my $f = 'qq.china.3.loc.as';

cast(
    $f, 
    #'test',
        sep => '/',

        #key 有 cnt / rank 两种
        names => [ qw/ip_c data inet state prov isp state_en prov_en isp_en as/ ],
        id => [ 3, 5, 6, 8, 1 ],
        measure => 'cnt',
        value => sub { 1 },

        reduce_sub => sub { my ($last, $now) = @_; return $last+$now; },
        reduce_start_value => 0,

        #write_head => 1,

        #default_cell_value => 0,
        default_cast_value => 0,

        cast_file => 'stat_country_isp_data_cnt.csv',
        return_arrayref => 0,
    );

cast(
    $f, 
    #'test',
        sep => '/',

        #key 有 cnt / rank 两种
        names => [ qw/ip_c data inet state prov isp state_en prov_en isp_en as/ ],
        id => [ 3,  6, 1 ],
        measure => 'cnt',
        value => sub { 1 },

        reduce_sub => sub { my ($last, $now) = @_; return $last+$now; },
        reduce_start_value => 0,

        #write_head => 1,

        #default_cell_value => 0,
        default_cast_value => 0,

        cast_file => 'stat_country_data_cnt.csv',
        return_arrayref => 0,
    );


cast(
$f, 
    #'test',
        sep => '/',

        #key 有 cnt / rank 两种
        names => [ qw/ip_c data inet state prov isp state_en prov_en isp_en as/ ],
        id => [ 3, 4, 5, 6, 7, 8, 1 ],
        measure => 'cnt',
        value => sub { 1 },

        reduce_sub => sub { my ($last, $now) = @_; return $last+$now; },
        reduce_start_value => 0,

        #write_head => 1,

        #default_cell_value => 0,
        default_cast_value => 0,

        cast_file => 'stat_country_prov_isp_data_cnt.csv',
        return_arrayref => 0,
    );

