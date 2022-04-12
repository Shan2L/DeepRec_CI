#!/bin/bash

function code_review()
{
    cd /benchmark_result/repo
    git clone https://github.com/oneapi-src/oneDNN.git\
    && git checkout $version
}

function make()
{
    apt-get install cmake -y \
    && apt-get install numactl -y\
    &&cd /benchmark_result/repo/oneDNN\
    &&mkdir build\
    &&cd build\
    &&cmake ..\
    &&make -j\
    &&cd tests/benchdnn
}

function benchdnn()
{
    cd /benchmark_result/repo/oneDNN/build/tests/benchdnn

    ISA_set="AVX512_CORE_BF16 AVX_512_COREAMX"
    core_num="1 2 4 8 16"
    for ISA in $ISA_set
    do
        for num in $core_num
        do 
            export OMP_NUM_THREADS=$num
            if [[ $version == "v2.3.2" ]];then
                DNNL_MAX_CPU_ISA=$ISA numactl -C 56-71 -l ./benchdnn --matmul\
                                    --mode=P --cfg=bf16bf16bf16bf16,f32
            else if [[ $version == "v2.5.4" ]];then
                oneDNN_MAX_CPU_ISA=$ISA numactl -C 56-71 -l ./benchdnn --matmul\
                                    --mode=P --cfg=bf16bf16bf16bf16,f32 --batch ./test_case
            else
                echo "[ERROR] Wrong Version has been spercified."
                exit -1;
            unset OMP_NUM_THREADS
        done
    done

}

function main(){
    code_review
    make
}

currentTime=$1
version=$2
http_proxy=127.0.0.1:5556
main



