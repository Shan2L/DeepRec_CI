export START_STATISTIC_STEP=100
export STOP_STATISTIC_STEP=200
export MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:60000,muzzy_decay_ms:60000"
export TF_LAYOUT_PASS_GRAPH_CAST_FUSION=1
export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
 
echo 'testing WDL of deeprec_fp32.......'
cd ~/modelzoo/WDL/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py   --steps 3000 --no_eval --timeline 1000  --checkpoint /2022-03-10-10-28-43/wdl_deeprec_fp32 >/2022-03-10-10-28-43/wdl_deeprec_fp32.log 2>&1
echo 'testing DSSM of deeprec_fp32.......'
cd ~/modelzoo/DSSM/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py  --steps 3000 --no_eval --timeline 1000 --checkpoint /2022-03-10-10-28-43/dssm_deeprec_fp32 >/2022-03-10-10-28-43/dssm_deeprec_fp32.log 2>&1
echo 'testing DLRM of deeprec_fp32.......'
cd ~/modelzoo/DLRM/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py  --steps 3000 --no_eval --timeline 1000   --checkpoint /2022-03-10-10-28-43/dlrm_deeprec_fp32 >/2022-03-10-10-28-43/dlrm_deeprec_fp32.log 2>&1
echo 'testing DeepFM of deeprec_fp32.......'
cd ~/modelzoo/DeepFM/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py  --steps 3000 --no_eval --timeline 1000   --checkpoint /2022-03-10-10-28-43/deepfm_deeprec_fp32 >/2022-03-10-10-28-43/deepfm_deeprec_fp32.log 2>&1
echo 'testing DIEN of deeprec_fp32.......'
cd ~/modelzoo/DIEN/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py  --steps 3000 --no_eval --timeline 1000   --checkpoint /2022-03-10-10-28-43/dien_deeprec_fp32 >/2022-03-10-10-28-43/dien_deeprec_fp32.log 2>&1
echo 'testing DIN of deeprec_fp32.......'
cd ~/modelzoo/DIN/
LD_PRELOAD=~/modelzoo/libjemalloc.so.2.5.1 numactl -C 52-55,164-167 -l python train.py  --steps 3000 --no_eval --timeline 1000   --checkpoint /2022-03-10-10-28-43/din_deeprec_fp32 >/2022-03-10-10-28-43/din_deeprec_fp32.log 2>&1
