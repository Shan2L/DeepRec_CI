#!/bin/bash

#function codeReview()
#{
#    current_path=$(pwd)
#    if [[ -d $repo_dir/DeepRec ]];then
#        cd $repo_dir \
#        && sudo rm -rf DeepRec
#    fi
#    cd $repo_dir \
#    && git clone $code_repo \
#    && cd $repo_dir/DeepRec\
#    &&git checkout $branch_name\
#    &&git checkout --progress --force $commit_id\
#    &&cd $current_path
#}


function runContainer()
{
    host_path1=$(cd "$repo_dir/DeepRec" && pwd)
    host_path2=$(cd ./about_BM && pwd)

    sudo docker pull $test_image_repo \
    && sudo docker run -it\
    -v $host_path1:/DeepRec/ \
    -v $host_path2:/about_BM/ \
    -v $cache_path:/root/.cache/ \
    --rm \
    --name BM_test $test_image_repo /bin/bash /about_BM/script/run.sh $currentTime $commit_id
}


set -x
# 获取当前时间戳
currentTime=`date "+%m-%d-%H-%M-%S"`


repo_dir="./repo/ali_repo"
repo_dir=$(cd $repo_dir && pwd)
code_repo=$(cat ./config.properties | grep code_repo | awk -F " " '{print$2}')
branch_name=$(cat ./config.properties | grep branch| awk -F " " '{print $2}' )
commit_id=$(cat ./config.properties | grep commit| awk -F " " '{print $2}' )

part_commit=$(echo $commit_id | cut -c 1-7)
log_title=$currentTime-$part_commit

test_image_repo=$(cat ./config.properties | grep test_image| awk -F " " '{print $2}' )
log_dir="./about_BM/log/$log_title"
if [[ ! -d $log_dir ]];then
    mkdir -p $log_dir
fi

cache_path=./cache
if [[ ! -d $cache_path ]];then
	mkdir -p $cache_path
fi
cache_path=$(cd $cache_path && pwd)

file_path=$(cd ./about_BM/log/$log_title && pwd)

#codeReview 
runContainer


