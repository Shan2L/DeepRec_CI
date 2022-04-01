echo 'testing SimpleMultiTask of tf_fp32  --timeline 1000.......'
cd /root/modelzoo/SimpleMultiTask/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/simplemultitask_tf_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/simplemultitask_tf_fp32_--timeline_1000.log 2>&1
echo 'testing MMoE of tf_fp32  --timeline 1000.......'
cd /root/modelzoo/MMoE/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/mmoe_tf_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/mmoe_tf_fp32_--timeline_1000.log 2>&1
echo 'testing DBMTL of tf_fp32  --timeline 1000.......'
cd /root/modelzoo/DBMTL/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/dbmtl_tf_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/dbmtl_tf_fp32_--timeline_1000.log 2>&1
echo 'testing ESMM of tf_fp32  --timeline 1000.......'
cd /root/modelzoo/ESMM/
python train.py   --timeline 1000   --checkpoint /benchmark_result/checkpoint/2022-03-31-11-34-33/esmm_tf_fp32_--timeline_1000  >/benchmark_result/log/2022-03-31-11-34-33/esmm_tf_fp32_--timeline_1000.log 2>&1
