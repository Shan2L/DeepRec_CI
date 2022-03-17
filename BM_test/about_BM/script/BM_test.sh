#!/bin/bash

BM_targets="\
	     //tensorflow/core/kernels:mkl_aggregate_ops_test \
            //tensorflow/core/kernels:mkl_batch_matmul_op_test \
            //tensorflow/core/kernels:mkl_concat_op_test \
            //tensorflow/core/kernels:mkl_cwise_ops_test \
            //tensorflow/core/kernels:mkl_fused_batch_norm_op_test \
            //tensorflow/core/kernels:mkl_identity_op_test \
            //tensorflow/core/kernels:mkl_lrn_op_test \
            //tensorflow/core/kernels:mkl_matmul_op_test \
            //tensorflow/core/kernels:mkl_matmul_op_test \
            //tensorflow/core/kernels:mkl_relu_op_test \
            //tensorflow/core/kernels:mkl_reshape_op_test \
            //tensorflow/core/kernels:mkl_slice_op_test \
            //tensorflow/core/kernels:mkl_softmax_op_test \
           //tensorflow/core/kernels:mkl_transpose_op_test"

default_opts="--remote_cache=http://crt-e302.sh.intel.com:9092 \
             --cxxopt=-D_GLIBCXX_USE_CXX11_ABI=0 \
             --copt=-O2 \
             --copt=-Wformat \
             --copt=-Wformat-security \
             --copt=-fstack-protector \
             --copt=-fPIC \
             --copt=-fpic \
             --linkopt=-znoexecstack \
             --linkopt=-zrelro \
             --linkopt=-znow \
             --linkopt=-fstack-protector"

mkl_opts="--config=mkl_threadpool \
           --define build_with_mkl_dnn_v1_only=true \
           --copt=-DENABLE_INTEL_MKL_BFLOAT16 \
           --copt=-march=skylake-avx512"

test_opts="--nocache_test_results \
           --test_output=all \
           --verbose_failures \
           --test_verbose_timeout_warnings \
           --flaky_test_attempts 1 \
           --test_timeout 99999999 \
           --test_size_filters=small,medium,large,enormous \
           -c opt \
           --keep_going"

#BM_targets="//tensorflow/core/kernels:mkl_reshape_op_test"

function get_target_name() 
{
  echo $1 | awk -F ':' '{print $2}'
}

function cpu_bazel_test_BM() {
  test_options="--test_arg=--benchmarks=all"
  yes "" | ./configure
  for test_target in ${BM_targets[@]}; do
    target_name=$(echo $test_target| awk -F ':' '{print $2}')
    bazel test ${default_opts} ${mkl_opts} \
      ${test_opts} ${test_options} \
      -- ${test_target} | tee /about_BM/log/$log_tag/$target_name.log 2>&1
    python /about_BM/script/ExeclWriter.py BM /about_BM/log/$log_tag/$target_name.log
  done
}

log_tag=$1
pip install -r /about_BM/script/requirements.txt
cpu_bazel_test_BM
