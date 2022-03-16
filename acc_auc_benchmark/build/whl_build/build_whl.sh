#！/bin/bash

proxy_address=http://child-prc.intel.com:913
export http_proxy=$proxy_address
export https_proxy=$proxy_address

apt update
apt install libsnappy-dev

cd /whl_build/repo/ali_DeepRec/DeepRec

mkdir /whl_build/whl_package/$1 
bash /whl_build/bazel_build cpu \
&&cp /whl_build/repo/ali_DeepRec/DeepRec/wheels/tensorflow/* /whl_build/whl_package/$1/ \
&&echo "success copy the whl file to /whl_build/whl_package/$1"




