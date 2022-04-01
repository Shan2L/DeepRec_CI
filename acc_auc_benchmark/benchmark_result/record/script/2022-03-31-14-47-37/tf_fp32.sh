echo 'testing DIN of tf_fp32  .......'
cd /root/modelzoo/DIN/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/din_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/din_tf_fp32.log 2>&1
echo 'testing DIEN of tf_fp32  .......'
cd /root/modelzoo/DIEN/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/dien_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/dien_tf_fp32.log 2>&1
echo 'testing DLRM of tf_fp32  .......'
cd /root/modelzoo/DLRM/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/dlrm_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/dlrm_tf_fp32.log 2>&1
echo 'testing DeepFM of tf_fp32  .......'
cd /root/modelzoo/DeepFM/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/deepfm_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/deepfm_tf_fp32.log 2>&1
echo 'testing DSSM of tf_fp32  .......'
cd /root/modelzoo/DSSM/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/dssm_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/dssm_tf_fp32.log 2>&1
echo 'testing WDL of tf_fp32  .......'
cd /root/modelzoo/WDL/
python train.py    --checkpoint /benchmark_result/checkpoint/2022-03-31-14-47-37/wdl_tf_fp32  >/benchmark_result/log/2022-03-31-14-47-37/wdl_tf_fp32.log 2>&1
