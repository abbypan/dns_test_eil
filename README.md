# dns_test_eil

dns test eil

EDNS option code should be assigned by the expert review process as defined by the DNSEXT working group and the IESG. For test case, we set EIL's OPTION-CODE : 0xFDF0

AREA-CODE : use ISO 3166-2 standard country subdivision code, 6 octets

Paper :  [Paper_EIL_Dealing_with_the_Privacy_Problem_of_ECS.pdf](ietf_draft/Paper_EIL_Dealing_with_the_Privacy_Problem_of_ECS.pdf)

Slide :  [EIL: Dealing with the Privacy Problem of ECS](https://drive.google.com/open?id=0B5gNT4RRJ0xPcUhuV2JlV2ZYWHc)

Draft (area-code : country subdivision code)
- Newest draft: [ietf_draft/draft.txt](ietf_draft/draft.txt)
- Status:         https://datatracker.ietf.org/doc/draft-pan-dnsop-edns-isp-location/

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
    $ perl recv_eil_aut.pl

recursive:

    $ cd dns_test_eil
    $ perl recv_eil_rec.pl

client:

    $ cd dns_test_eil

    # receive same RR : ECS(114.240.0.0/24) => EIL(CN, 11, UNI), indicates (CHINA, BEIJING, UNICOM)
    $ dig @ns-cmn1.qq.com. www.qq.com  +subnet=114.240.0.0/24 > ecs_114.240.0.0.log
    $ perl send_eil.pl www.qq.com CN 11 UNI > eil_cn_11_uni.log

    # receive same RR : ECS(219.137.222.0/24) => EIL(CN, 44, TEL), indicates (CHINA, GUANGDONG, TELECOM)
    $ dig @ns-cmn1.qq.com. www.qq.com  +subnet=219.137.222.0/24 > ecs_219.137.222.0.log
    $ perl send_eil.pl www.qq.com CN 44 TEL > eil_cn_44_tel.log
