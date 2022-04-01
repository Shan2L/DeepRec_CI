echo 'testing SimpleMultiTask of tf_fp32  .......'
cd /root/modelzoo/SimpleMultiTask/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-31-13-39-04/simplemultitask_tf_fp32_  >/benchmark_result/log/2022-03-31-13-39-04/simplemultitask_tf_fp32_.log 2>&1
echo 'testing MMoE of tf_fp32  .......'
cd /root/modelzoo/MMoE/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-31-13-39-04/mmoe_tf_fp32_  >/benchmark_result/log/2022-03-31-13-39-04/mmoe_tf_fp32_.log 2>&1
echo 'testing DBMTL of tf_fp32  .......'
cd /root/modelzoo/DBMTL/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-31-13-39-04/dbmtl_tf_fp32_  >/benchmark_result/log/2022-03-31-13-39-04/dbmtl_tf_fp32_.log 2>&1
echo 'testing ESMM of tf_fp32  .......'
cd /root/modelzoo/ESMM/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-31-13-39-04/esmm_tf_fp32_  >/benchmark_result/log/2022-03-31-13-39-04/esmm_tf_fp32_.log 2>&1
