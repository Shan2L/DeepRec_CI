export START_STATISTIC_STEP=100
export STOP_STATISTIC_STEP=200
export TF_LAYOUT_PASS_GRAPH_ENABLE_ONLY_WHITE_LIST=1
export TF_LAYOUT_PASS_GRAPH_CAST_FUSION=1
export TF_LAYOUT_PASS_ONLY_WHITE_LIST=1
 
echo 'testing WDL of deeprec_bf16  .......'
cd /root/modelzoo/WDL/
python train.py     --bf16 --checkpoint /benchmark_result/checkpoint/2022-04-25-14-41-00/wdl_deeprec_bf16_  >/benchmark_result/log/2022-04-25-14-41-00/wdl_deeprec_bf16_.log 2>&1
