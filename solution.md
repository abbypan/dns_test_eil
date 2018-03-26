# Some solutions

## public resolvers map client subnet into topological close resolver ip, then send to authoritatives.

It is unrealistic thought, just want to keep the tranditional resolver -> authoritative structure.

    $ dig +subnet=123.120.41.0/24 www.qq.com @8.8.8.8

because 123.120.41.0/24 's topological close resolver ip is 202.106.196.0/24

then 8.8.8.8 send the queries to www.qq.com 's authoritative with subnet=202.106.196.0/24

such as  @ns-cnc1.qq.com www.qq.com +subnet=202.106.196.0/24 

## geolocation authoritatives give an additional TXT to tell recursive resolver more information.

Recursive resolvers can use this information to simplify its cache management, if it support the TXT analysis.

    $ dig +subnet=123.120.41.0/24 www.qq.com      
    www.qq.com.        600    IN    A    61.135.157.156
    www.qq.com.        600    IN    A    125.39.240.113
    www.qq.com.        600    IN    TXT  "China, Beijing, Unicom: 600 | IN | A | 61.135.157.156, 125.39.240.113"

## use ANAME,  let recursive help to select the best IP by latency, traceroute, geolocation, etc.

Evan Hunt mentioned some at https://www.ietf.org/mail-archive/web/dnsop/current/msg20051.html

This need recursive resolvers support ANAME, and run some route policy for clients.

There maybe some risks depends on recursive resolver's operational level. If recursive resolver deployed an "shortest ping time" policy which only select 1 IP from the response IPset, then the load balance of the website will be affected.

    $ dig +subnet=123.120.41.0/24 www.qq.com      
    www.qq.com.        600    IN    ANAME    china-beijing-unicom.www.qq.com.
    www.qq.com.        600    IN    ANAME    china-shanghai-unicom.www.qq.com.
    www.qq.com.        600    IN    ANAME    china-shenzhen-unicom.www.qq.com.

## EIL

If we find hard to avoid adjustment on recursive resolvers, we can try to aggregate client subnet with <country, area, isp>. 

Because simply shorten client subnet prefix can not solve the problem, the precise loss is offen larger than <country, area, isp>, they prefer ipv4 address cidr 24, or even >24.

    $ dig +eil=china,beijing,unicom www.qq.com      
    www.qq.com.        600    IN    A    61.135.157.156
    www.qq.com.        600    IN    A    125.39.240.113
