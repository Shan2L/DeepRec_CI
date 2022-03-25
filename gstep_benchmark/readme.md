![gstep.png](https://github.com/GosTraight2020/DeepRec_CI/blob/master/.asset/gstep.png)
The process of ACC/AUC benchmark of DeepRec

Modify necessary parameters to the config file(config.properties)
Run gstep_benchmark.sh, it will read parameters from config file
The gstep_benchmark.sh will make three script: deeprec_bf16.sh, deepre_fp23.sh and tf_fp32.sh accroding to the config file.
The gstep_benchmark.sh will run three contrainers named deeprec_bf16, deeprec_fp32, tf_fp32 orderly.
In each contrainer, a scipt will be implemented automatically.
The script implemented in container will produce serveral log files.
The gstep_count.py will analyze the log files to produce the final acc.csv and auc.csv
tips: You can also use the Github Action UI interface to Benchmark. https://github.com/GosTraight2020/DeepRec_CI/actions/workflows/acc_auc.yml

How to Use

Modify the important parameters in the config.properties deeprec_test_image: Image that has already installed the DeepRec environment you want to benchmark
tf_test_image: Image that installed the Stock tensorflow.
cpus: The cpu you limit the docker to use.
CMD: The model and corresponding parameters you want to run.
ENV: The environment variables you want to export to the docker container
Run acc_auc_benchmark.sh
