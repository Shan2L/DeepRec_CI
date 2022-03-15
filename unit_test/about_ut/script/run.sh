#!/bin/bash

currentTime=$1

proxy_address=http://child-prc.intel.com:913
export http_proxy=$proxy_address
export https_proxy=$proxy_address

commit_id=$(cat ../../config.properties|grep commit| awk -F " " '{print $2}')
part_id=$(echo $commit_id | cut -c 1-7)
log_title=$currentTime-$part_id

cd /DeepRec \
&& bash -x /about_ut/script/ut.sh | tee /about_ut/log/$log_title/ut_res.log\
&& bazel clean\
&& pip install -r /about_ut/script/requirements.txt \
&& cd /about_ut/script/ \
&& echo ------------------ >> /about_ut/log/$log_title/ut_res.log\
&& python /about_ut/script/ExeclWriter.py BM /about_ut/log/$log_title/ut_res.log
