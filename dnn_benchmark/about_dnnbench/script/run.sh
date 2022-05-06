#!/bin/bash


function code_review()
{
    cd /dnn_benchmark/repo/oneDNN
    oneDNN_version=$(git branch | awk -F "(" '{print $2}' |  awk -F ")" '{print $1}' | awk -F " " '{print $4}')
    if [[ $oneDNN_version != $version ]];then
        echo "[ERROR] The version of oneDNN doesn't match with the version in config file!"
        exit -1
    fi

    ISA_num=$(cat config_file | shyaml get-length ISA_set)
    dt_num=$(cat config_file | shyaml get-length data_type)
    if [[ $ISA_num != $dt_num ]];then
        echo "[ERROR] The num of ISA is not equal to the num of datatype"
        exit -1
    fi
}

function make_code()
{
    cd /dnn_benchmark/repo/oneDNN
    mkdir build
    cd build
    cmake ..
    make -j
    cd tests/benchdnn
}


function benchdnn()
{
    cd /dnn_benchmark/repo/oneDNN/build/tests/benchdnn
    ISA=$1
    datatype=$2

    for num in $core_num
    do 
        OMP_NUM_THREADS=$num oneDNN_MAX_CPU_ISA=$ISA DNNL_MAX_CPU_ISA=$ISA numactl -C $numa ./benchdnn --matmul\
                             --mode=P --cfg=$data_type --batch=/dnn_benchmark/about_dnnbench/script/test_case | \
                             tee /dnn_benchmark/about_dnnbench/benchmark_result/$currentTime/$ISA.log
    done

}

function main(){
    code_review
    make_code
    mkdir -p  /dnn_benchmark/about_dnnbench/benchmark_result/$currentTime/

    for i in `seq 1 ${#ISA_set[@]}`
    do 
        benchdnn ${ISA_set[i-1]} ${data_type[i-1]}
    done
}


currentTime=$1
config_file=/dnn_benchmark/config.yml
export PYTHONIOENCODING=utf-8

version=$(cat $config_file | shyaml get-value onednn_version)
core_num=$(cat $config_file | shyaml get-values thread_num)
ISA_set=($(cat $config_file | shyaml get-values ISA_set))
data_type=($(cat $config_file | shyaml get-values data_type))
numa=$(cat $config_file | shyaml get-value numa)
main



