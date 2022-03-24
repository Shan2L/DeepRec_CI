set -eo pipefail

export TF_NEED_TENSORRT=0
export TF_NEED_ROCM=0
export TF_NEED_COMPUTECPP=0
export TF_NEED_OPENCL=0
export TF_NEED_OPENCL_SYCL=0
export TF_ENABLE_XLA=1
export TF_NEED_MPI=0

yes "" | bash ./configure || true

set -x

TF_ALL_TARGETS="//tensorflow/c/... "\
"//tensorflow/cc/... "\
"//tensorflow/contrib/... "\
"//tensorflow/core/... "\
"//tensorflow/examples/... "\
"//tensorflow/java/... "\
"//tensorflow/js/... "\
"//tensorflow/python/... "\
"//tensorflow/stream_executor/... "

export TF_TOTAL_BAZEL_TARGET="$TF_ALL_TARGETS "\
"-//tensorflow/c:c_api_experimental_test "\
"-//tensorflow/c:c_api_function_test "\
"-//tensorflow/c:while_loop_test "\
"-//tensorflow/c:c_test "\
"-//tensorflow/contrib/android/... "\
"-//tensorflow/contrib/compiler/tests:addsign_test_cpu "\
"-//tensorflow/contrib/distribute/python:parameter_server_strategy_test "\
"-//tensorflow/contrib/distributions:batch_normalization_test "\
"-//tensorflow/contrib/distributions:wishart_test "\
"-//tensorflow/contrib/quantize:quantize_parameterized_test "\
"-//tensorflow/contrib/rpc/python/kernel_tests:rpc_op_test "\
"-//tensorflow/contrib/quantize:fold_batch_norms_test "\
"-//tensorflow/contrib/eager/python:saver_test "\
"-//tensorflow/contrib/distributions:inline_test "\
"-//tensorflow/core/common_runtime/eager:eager_op_rewrite_registry_test "\
"-//tensorflow/core/distributed_runtime:cluster_function_library_runtime_test "\
"-//tensorflow/core:graph_optimizer_fusion_engine_test "\
"-//tensorflow/core/distributed_runtime/eager:eager_service_impl_test "\
"-//tensorflow/core/distributed_runtime/eager:remote_mgr_test "\
"-//tensorflow/core/distributed_runtime:session_mgr_test "\
"-//tensorflow/core/debug:grpc_session_debug_test "\
"-//tensorflow/python/autograph/pyct:inspect_utils_test_par "\
"-//tensorflow/python/autograph/pyct:compiler_test "\
"-//tensorflow/python/autograph/pyct:cfg_test "\
"-//tensorflow/python/autograph/pyct:ast_util_test "\
"-//tensorflow/python/data/experimental/kernel_tests:prefetch_with_slack_test "\
"-//tensorflow/python/debug:debugger_cli_common_test "\
"-//tensorflow/python/debug:dist_session_debug_grpc_test "\
"-//tensorflow/python:deprecation_test "\
"-//tensorflow/python/distribute:values_test "\
"-//tensorflow/python/distribute:parameter_server_strategy_test "\
"-//tensorflow/python/eager:remote_test "\
"-//tensorflow/python/keras/distribute:multi_worker_fault_tolerance_test "\
"-//tensorflow/python/keras:callbacks_test "\
"-//tensorflow/python/keras:simplernn_test "\
"-//tensorflow/python/keras:lstm_test "\
"-//tensorflow/python/keras:hdf5_format_test "\
"-//tensorflow/python/profiler:model_analyzer_test "\
"-//tensorflow/python/tools/api/generator:output_init_files_test "\
"-//tensorflow/python/tpu:datasets_test "\
"-//tensorflow/python/kernel_tests:unique_op_test "\
"-//tensorflow/python/kernel_tests:sparse_conditional_accumulator_test "\
"-//tensorflow/python:server_lib_test "\
"-//tensorflow/python:work_queue_test "\
"-//tensorflow/python/keras:metrics_test "\
"-//tensorflow/python/keras:training_test "\

 bazel test -c opt --config=opt \
 
 
                    --discard_analysis_cache\
                    --nokeep_state_after_build\
                    --notrack_incremental_state\
                    --verbose_failures \
                    --local_test_jobs=40 \
                    --flaky_test_attempts 1 \
                    --test_timeout 3600 \
                    --test_size_filters=small,medium,large,enormous \
                    --keep_going \
                    -- $TF_TOTAL_BAZEL_TARGET

