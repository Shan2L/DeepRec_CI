#!/bin/bash
currentTime=$1
proxy_address=http://child-prc.intel.com:913
export http_proxy=$proxy_address
export https_proxy=$proxy_address
cd /whl_build/whl_package/$currentTime
whl_file=$(ls)
pip install $whl_file --force-reinstall