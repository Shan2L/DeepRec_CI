echo 'testing DLRM of tf_fp32  .......'
cd /root/modelzoo/DLRM/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/dlrm_tf_fp32_  >/benchmark_result/log/2022-03-28-13-27-11/dlrm_tf_fp32_.log 2>&1
echo 'testing DeepFM of tf_fp32  .......'
cd /root/modelzoo/DeepFM/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/deepfm_tf_fp32_  >/benchmark_result/log/2022-03-28-13-27-11/deepfm_tf_fp32_.log 2>&1
echo 'testing DSSM of tf_fp32  .......'
cd /root/modelzoo/DSSM/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/dssm_tf_fp32_  >/benchmark_result/log/2022-03-28-13-27-11/dssm_tf_fp32_.log 2>&1
echo 'testing WDL of tf_fp32  .......'
cd /root/modelzoo/WDL/
python train.py      --checkpoint /benchmark_result/checkpoint/2022-03-28-13-27-11/wdl_tf_fp32_  >/benchmark_result/log/2022-03-28-13-27-11/wdl_tf_fp32_.log 2>&1
