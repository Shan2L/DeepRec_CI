#!/bin/bash

currentTime=$1
commit_id=$2

proxy_address=http://child-prc.intel.com:913
export http_proxy=$proxy_address
export https_proxy=$proxy_address

part_id=$(echo $commit_id | cut -c 1-7)
log_tag=$currentTime-$part_id

cd /DeepRec \
&& bash -x /about_BM/script/BM_test.sh $log_tag\
&& bazel clean
