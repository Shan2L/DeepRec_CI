#!/bin/bash

function codeReview()
{
    current_path=$(pwd)
    if [[ ! -d $ali_repo_dir/DeepRec ]];then
        cd $ali_repo_dir && git clone https://github.com/alibaba/DeepRec.git && cd $current_path
    fi
    cd $ali_repo_dir/DeepRec\
    &&git checkout $branch_name\
    &&git checkout --progress --force $commit_id\
    &&cd $current_path
    if [[ -d ./cache ]];then
        sudo rm -rf ./cache
    fi
}


function runContainer()
{
    host_path1=$(cd "$ali_repo_dir/DeepRec" && pwd)
    host_path2=$(cd ./about_ut && pwd)

    sudo docker volume create ut_cache
    sudo docker pull $test_image_repo \
    && sudo docker run \
    -it \
    -v $host_path1:/DeepRec/ \
    -v $host_path2:/about_ut/ \
    --mount source=ut_cache,target=/root/.cache/ \
    --rm \
    --name ut_et $test_image_repo /bin/bash /about_ut/script/run.sh $currentTime
}


set -x
# 获取当前时间戳
currentTime=`date "+%Y-%m-%d-%H-%M-%S"`
ali_repo_dir="./repo/ali_repo"
branch_name=$(cat ./config.properties | grep branch| awk -F " " '{print $2}' )
commit_id=$(cat ./config.properties | grep commit| awk -F " " '{print $2}' )
test_image_repo=$(cat ./config.properties | grep test_image| awk -F " " '{print $2}' )
log_dir="./about_ut/log/$currentTime"
if [[ ! -d $log_dir ]];then
    mkdir -p $log_dir
fi

codeReview \
&& runContainer
sudo docker volume rm ut_cache
