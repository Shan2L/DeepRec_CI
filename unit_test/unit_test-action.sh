#!/bin/bash

function codeReview()
{
    current_path=$(pwd)
    [[ -d $repo_dir/DeepRec ]] && cd $repo_dir && sudo rm -rf DeepRec

    cd $repo_dir \
    && git clone $code_repo \
    && cd $repo_dir/DeepRec\
    &&git checkout $branch_name\
    &&git checkout --progress --force $commit_id\
    &&cd $current_path
}

function checkCache()
{
    status=$(sudo docker volume ls | grep ut_cache)
    [[ $status ]] && sudo docker volume rm ut_cache
    echo "Finishing checking the cache"
}


function runContainer()
{
    host_path1=$(cd "$repo_dir/DeepRec" && pwd)
    host_path2=$(cd ./about_ut && pwd)

    sudo docker volume create ut_cache
    sudo docker pull $test_image_repo \
    && sudo docker run \
    -v $host_path1:/DeepRec/ \
    -v $host_path2:/about_ut/ \
    --mount source=ut_cache,target=/root/.cache/ \
    --rm \
    --name ut_et $test_image_repo /bin/bash /about_ut/script/run.sh $currentTime $commit_id $mkl_tag
}

function push_to_github()
{
    git add ./about_ut/log/$log_title/*\
    && git commit -m "add new log file: $log_title"\
    && git push
    echo "the files generated is in the directory : $file_path"
}



set -x
# 获取当前时间戳
currentTime=`date "+%m-%d-%H-%M-%S"`
mkl_tag=$1
repo_dir="./repo/ali_repo"
repo_dir=$(cd $repo_dir && pwd)
code_repo=$(cat ./config.properties | grep code_repo | awk -F " " '{print$2}')
branch_name=$(cat ./config.properties | grep branch| awk -F " " '{print $2}' )
commit_id=$(cat ./config.properties | grep commit| awk -F " " '{print $2}' )
test_image_repo=$(cat ./config.properties | grep test_image| awk -F " " '{print $2}' )
part_commit=$(echo $commit_id | cut -c 1-7)
log_title=$currentTime-$part_commit

[[ -n $mkl_tag ]] && log_title=${log_title}_with_$mkl_tag
log_dir="./about_ut/log/$log_title"
[[ ! -d $log_dir ]] && mkdir -p $log_dir
file_path=$(cd ./about_ut/log/$log_title && pwd)


checkCache\
&& codeReview \
&& runContainer

current_path=$(pwd)
cd ./repo/ali_repo/ \
&&sudo rm -rf ./*
cd $current_path
sudo docker volume rm ut_cache
#push_to_github
