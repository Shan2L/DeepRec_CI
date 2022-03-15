#!/bin/bash

function codeReview()
{
    current_path=$(pwd)
    if [[ -d $repo_dir/DeepRec ]];then
        cd $repo_dir \
        && sudo rm -rf DeepRec
    fi
    cd $repo_dir \
    && git clone $code_repo \
    && cd $repo_dir/DeepRec\
    &&git checkout $branch_name\
    &&git checkout --progress --force $commit_id\
    &&cd $current_path
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
    --name ut_et $test_image_repo /bin/bash /about_ut/script/run.sh $currentTime
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
log_dir="./about_ut/log/$currentTime"
if [[ ! -d $log_dir ]];then
    mkdir -p $log_dir
fi

file_path=$(cd ./about_ut/log/$log_title && pwd)

codeReview \
&& runContainer\
&& git add ./about_ut/log/$log_title\
&& git commit -m "add new log file: $log_title"\
&& git push\
&& echo "the files generated is in the directory : $file_path"
sudo docker volume rm ut_cache
