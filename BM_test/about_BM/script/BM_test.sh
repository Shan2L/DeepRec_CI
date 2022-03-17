#!/bin/bash

#BM_targets="\
#	     //tensorflow/core/kernels:mkl_aggregate_ops_test \
#            //tensorflow/core/kernels:mkl_batch_matmul_op_test \
#            //tensorflow/core/kernels:mkl_concat_op_test \
#            //tensorflow/core/kernels:mkl_cwise_ops_test \
#            //tensorflow/core/kernels:mkl_fused_batch_norm_op_test \
#            //tensorflow/core/kernels:mkl_identity_op_test \
#            //tensorflow/core/kernels:mkl_lrn_op_test \
#            //tensorflow/core/kernels:mkl_matmul_op_test \
#            //tensorflow/core/kernels:mkl_matmul_op_test \
#            //tensorflow/core/kernels:mkl_relu_op_test \
#            //tensorflow/core/kernels:mkl_reshape_op_test \
#            //tensorflow/core/kernels:mkl_slice_op_test \
#            //tensorflow/core/kernels:mkl_softmax_op_test \
#            //tensorflow/core/kernels:mkl_transpose_op_test"

BM_targets="//tensorflow/core/kernels:mkl_reshape_op_test"


function cpu_bazel_test_BM() {
  test_options="--test_arg=--benchmarks=all"
  yes "" | ./configure
  for test_target in ${BM_targets[@]}; do
    target_name=$(get_target_name $test_target)
    bazel test ${default_opts} ${mkl_opts} \
      ${test_opts} ${test_options} \
      -- ${test_target} | tee ./../BM_log/$target_name.log 2>&1
    python /repo/writer/ExcelWriter.py BM /repo/BM_log/$target_name.log
  done
}

log_tag=$1
cpu_bazel_test_BM
