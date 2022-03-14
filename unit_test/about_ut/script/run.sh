#!/bin/bash

currentTime=$1

proxy_address=http://child-prc.intel.com:913
export http_proxy=$proxy_address
export https_proxy=$proxy_address


cd /DeepRec \
&& bash -x /about_ut/script/ut.sh | tee /about_ut/log/$currentTime/ut_res.log\
&& bazel clean\
&& pip install -r /about_ut/script/requirements.txt \
&& cd /about_ut/script/ \
&& echo ------------------ >> /about_ut/log/$currentiTime/ut_res.log\
&& python /about_ut/script/ExeclWriter.py BM /about_ut/log/$currentTime/ut_res.log
