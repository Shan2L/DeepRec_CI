export START_STATISTIC_STEP=100
export STOP_STATISTIC_STEP=200
export TF_LAYOUT_PASS_GRAPH_ENABLE_ONLY_WHITE_LIST=1
export TF_LAYOUT_PASS_GRAPH_CAST_FUSION=1
export TF_LAYOUT_PASS_ONLY_WHITE_LIST=1
 
echo 'testing DLRM of deeprec_bf16  --fusion.......'
cd /root/modelzoo/DLRM/
python train.py   --fusion  --bf16 --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/dlrm_deeprec_bf16_--fusion  >/benchmark_result/log/2022-03-28-13-27-11/dlrm_deeprec_bf16_--fusion.log 2>&1
echo 'testing DeepFM of deeprec_bf16  --fusion.......'
cd /root/modelzoo/DeepFM/
python train.py   --fusion  --bf16 --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/deepfm_deeprec_bf16_--fusion  >/benchmark_result/log/2022-03-28-13-27-11/deepfm_deeprec_bf16_--fusion.log 2>&1
echo 'testing DSSM of deeprec_bf16  --fusion.......'
cd /root/modelzoo/DSSM/
python train.py   --fusion  --bf16 --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/dssm_deeprec_bf16_--fusion  >/benchmark_result/log/2022-03-28-13-27-11/dssm_deeprec_bf16_--fusion.log 2>&1
echo 'testing WDL of deeprec_bf16  --fusion.......'
cd /root/modelzoo/WDL/
python train.py   --fusion  --bf16 --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/wdl_deeprec_bf16_--fusion  >/benchmark_result/log/2022-03-28-13-27-11/wdl_deeprec_bf16_--fusion.log 2>&1
