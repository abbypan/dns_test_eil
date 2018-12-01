#!/bin/bash 
apt-get update
apt-get -y install rsync build-essential vim dnsutils 
apt-get -y install cpanminus bind9
cpanm -n SimpleR::Reshape
cpanm -n Data::Validate::IP
