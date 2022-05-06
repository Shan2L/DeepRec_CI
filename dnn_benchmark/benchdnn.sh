#!/bin/bash
currentTime=`date "+%m-%d-%H-%M-%S"`
config_file='./config.yml'

check_tool=$(pip3 list | grep shyaml)
if [[ -z $check_tool ]];then
    pip3 install shyaml
fi
ln -s /usr/local/python3/bin/shyaml /usr/bin/shyaml

onednn_version=$(cat $config_file | shyaml get-value onednn_version)
repo_name=$(cat $config_file | shyaml get-value repo_name)
image_name=$(cat $config_file | shyaml get-value bench_image)

home_path=$(pwd)

if [[ -d $home_path/repo/oneDNN ]];then
    sudo rm -rf $home_path/repo/oneDNN
fi

cd $home_path/repo && git clone $repo_name
cd oneDNN && git checkout $onednn_version


sudo docker run -it \
                --rm \
                -v $home_path:/dnn_benchmark \
                $image_name /bin/bash /dnn_benchmark/about_dnnbench/script/run.sh $currentTime

sudo rm -rf $home_path/repo/oneDNN