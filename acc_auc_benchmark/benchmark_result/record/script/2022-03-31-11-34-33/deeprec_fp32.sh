export START_STATISTIC_STEP=100
export STOP_STATISTIC_STEP=200
export TF_LAYOUT_PASS_GRAPH_ENABLE_ONLY_WHITE_LIST=1
export TF_LAYOUT_PASS_GRAPH_CAST_FUSION=1
export TF_LAYOUT_PASS_ONLY_WHITE_LIST=1
 
echo 'testing SimpleMultiTask of deeprec_fp32  --timeline 1000.......'
cd /root/modelzoo/SimpleMultiTask/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/simplemultitask_deeprec_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/simplemultitask_deeprec_fp32_--timeline_1000.log 2>&1
echo 'testing MMoE of deeprec_fp32  --timeline 1000.......'
cd /root/modelzoo/MMoE/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/mmoe_deeprec_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/mmoe_deeprec_fp32_--timeline_1000.log 2>&1
echo 'testing DBMTL of deeprec_fp32  --timeline 1000.......'
cd /root/modelzoo/DBMTL/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/dbmtl_deeprec_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/dbmtl_deeprec_fp32_--timeline_1000.log 2>&1
echo 'testing ESMM of deeprec_fp32  --timeline 1000.......'
cd /root/modelzoo/ESMM/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/esmm_deeprec_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/esmm_deeprec_fp32_--timeline_1000.log 2>&1
