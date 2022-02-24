echo 'testing WDL of tf_fp32.......'
cd /root/modelzoo/WDL/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-02-21-16-24-27/wdl_tf_fp32 >/benchmark_result/log/2022-02-21-16-24-27/wdl_tf_fp32.log 2>&1
echo 'testing DSSM of tf_fp32.......'
cd /root/modelzoo/DSSM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-21-16-24-27/dssm_tf_fp32 >/benchmark_result/log/2022-02-21-16-24-27/dssm_tf_fp32.log 2>&1
echo 'testing DLRM of tf_fp32.......'
cd /root/modelzoo/DLRM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-21-16-24-27/dlrm_tf_fp32 >/benchmark_result/log/2022-02-21-16-24-27/dlrm_tf_fp32.log 2>&1
echo 'testing DeepFM of tf_fp32.......'
cd /root/modelzoo/DeepFM/
python train.py   --checkpoint /benchmark_result/checkpoint/2022-02-21-16-24-27/deepfm_tf_fp32 >/benchmark_result/log/2022-02-21-16-24-27/deepfm_tf_fp32.log 2>&1
