#!/usr/bin/perl


for my $f (glob("qq/*.res")){
    print "$f add inet\n";
    `add_inet.pl -f $f -i 0 -s '/' -d $f.inet`;
    `sort -t '/' -k3,3 -n $f.inet > $f.inet.sort`;
    print "$f loc\n";
    `add_ip_info.pl -f $f.inet.sort -d $f.loc -i 2 -t loc -s '/'`;
    `rm $f.inet $f.inet.sort`;
}

`cat qq/*.loc > qq.loc`;

for my $f (glob("qq/*.res")){
    print "$f as\n";
    `add_ip_info.pl -f $f.loc -d $f.loc.as -i 2 -t as -s '/'`;
    #`rm $f.inet $f.inet.sort $f.loc`;
}

`cat qq/*.as > qq.loc.as`;
