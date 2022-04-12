#!/bin/bash

version=$1
currentTime=`date "+%m-%d-%H-%M-%S"`
repo_name="https://github.com/changqi1/DeepRec.git"
branch_name="shan_test_for_matmul"
commit_id="fdc5ead4ce768aeab60e66cf0cd6e7d0fb91d022"
image_name="cesg-prc-registry.cn-beijing.cr.aliyuncs.com/cesg-ali/deeprec:ut"

home_path=$(pwd)

host_path=$(cd ./benchmark_result && pwd)
sudo docker run -it\
                -v $host_path:/benchmark_result \
                --privileged=true \
                --net host
                $image_name /bin/bash /benchmark_result/script/run.sh $currentTime $version

