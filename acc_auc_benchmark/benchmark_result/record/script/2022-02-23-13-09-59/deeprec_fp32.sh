export START_STATISTIC_STEP=100
export STOP_STATISTIC_STEP=200
export TF_LAYOUT_PASS_GRAPH_ENABLE_ONLY_WHITE_LIST=1
export TF_LAYOUT_PASS_GRAPH_CAST_FUSION=1
export TF_LAYOUT_PASS_ONLY_WHITE_LIST=1
 
echo 'testing WDL of deeprec_fp32.......'
cd /root/modelzoo/WDL/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-02-23-13-09-59/wdl_deeprec_fp32 >/benchmark_result/log/2022-02-23-13-09-59/wdl_deeprec_fp32.log 2>&1
echo 'testing DSSM of deeprec_fp32.......'
cd /root/modelzoo/DSSM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-23-13-09-59/dssm_deeprec_fp32 >/benchmark_result/log/2022-02-23-13-09-59/dssm_deeprec_fp32.log 2>&1
echo 'testing DLRM of deeprec_fp32.......'
cd /root/modelzoo/DLRM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-23-13-09-59/dlrm_deeprec_fp32 >/benchmark_result/log/2022-02-23-13-09-59/dlrm_deeprec_fp32.log 2>&1
echo 'testing DeepFM of deeprec_fp32.......'
cd /root/modelzoo/DeepFM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-23-13-09-59/deepfm_deeprec_fp32 >/benchmark_result/log/2022-02-23-13-09-59/deepfm_deeprec_fp32.log 2>&1
