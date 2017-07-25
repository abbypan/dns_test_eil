# dns_test_eil install guide

## INSTALL
 
    cpan App::cpanminus

    cpanm Net::DNS JSON File::Slurp

## FILES

    eil_whitelist.json :  country_code, area_code, isp

    eil_zone_www.qq.com.csv : take www.qq.com for test, A RRDATA for eil

    recv_eil_aut.pl : demo authority server, listen on 127.0.0.1:53

    recv_eil_rec.pl : demo recursive server, listen on 127.0.0.1:5354, send eil dns query to authority 127.0.0.1:53
    
    send_eil.pl : client, send eil dns query to recursive 127.0.0.1:5354

## TEST

authority:

    $ cd dns_test_eil 
    $ sudo perl recv_eil_aut.pl

recursive:

    $ cd dns_test_eil
    $ sudo perl recv_eil_rec.pl

client:

    $ cd dns_test_eil

    # receive same RR : ECS(114.240.0.0/24) => EIL(CN, 11, UNI), indicates (CHINA, BEIJING, UNICOM)
    $ dig @ns-cmn1.qq.com. www.qq.com  +subnet=114.240.0.0/24 > log/ecs_114.240.0.0.log
    $ perl send_eil.pl www.qq.com CN 11 UNI > log/eil_cn_11_uni.log

    # receive same RR : ECS(219.137.222.0/24) => EIL(CN, 44, TEL), indicates (CHINA, GUANGDONG, TELECOM)
    $ dig @ns-cmn1.qq.com. www.qq.com  +subnet=219.137.222.0/24 > log/ecs_219.137.222.0.log
    $ perl send_eil.pl www.qq.com CN 44 TEL > log/eil_cn_44_tel.log
   
    $ receive same RR : ECS(166.171.186.0/24) => EIL(US, NY, ATT), indicates (United States, New York, AT&T)
    $ dig @ns-cmn1.qq.com www.qq.com +subnet=166.171.186.0/24 > log/ecs_166.171.186.0.log
    $ perl send_eil.pl www.qq.com US NY ATT > log/eil_us_ny_att.log
