![SRP.png](https://github.com/GosTraight2020/DeepRec_CI/blob/master/.asset/SRP.png)

## The process of ACC/AUC benchmark of DeepRec

1. Modify necessary parameters to the config file(config.properties)
2. Run gstep_benchmark.sh, it will read parameters from config file
3. The gstep_benchmark.sh will make three script: deeprec_bf16.sh, deepre_fp23.sh and tf_fp32.sh accroding to the config file.
4. The gstep_benchark.sh will run the scipts orderly.
5. The scripts will produce serveral log files.
6. The gstep_count.py will analyze the log files to produce the final gstep.csv
tips: You can also use the Github Action UI interface to Benchmark.
https://github.com/GosTraight2020/DeepRec_CI/actions/workflows/SPR.yml

**How to Use**

1. Modify the important parameters in the config.properties <br/>
`cpus`: The cpu you limit the docker to use.<br/>
`CMD`: The model and corresponding parameters you want to run<br/>
`ENV`: The environment variables you want to export to the docker container<br/>
2. Run acc_auc_benchmark.sh
