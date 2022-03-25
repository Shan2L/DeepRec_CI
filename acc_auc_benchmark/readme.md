![6cf6a71ba1e756d774c92d85220bab78.png](https://github.com/GosTraight2020/DeepRec_CI/blob/master/.asset/acc_auc.png)
## How to Benchmark ACC/AUC of DeepRec?
**The process of ACC/AUC benchmark of DeepRec**
1. Modify necessary parameters to the config file(config.properties)
2. Run acc_auc_benchmark.sh, it will read parameters from config file
3. The acc_auc_benchmark.sh will make three script: deeprec_bf16.sh, deepre_fp23.sh and tf_fp32.sh accroding  to the config file.
4. The acc_auc_benchmark.sh will run three contrainers named deeprec_bf16, deeprec_fp32, tf_fp32 simultaneously
5. In each contrainer, a scipt will be implemented automatically.
6. The script implemented in container will produce serveral log files.
7. The acc_auc_benchmark.sh will analyze the log files to produce the final acc.csv and auc.csv 

tips: You can also use the Github Action UI interface to Benchmark.
      https://github.com/GosTraight2020/DeepRec_CI/actions/workflows/acc_auc.yml
      
**How to Use**
1. Modify the important parameters in the config.properties
`deeprec_test_image`: Image that has already installed the DeepRec environment you want to benchmark<br/>
`tf_test_image`: Image that installed the Stock tensorflow.<br/>
`cpus`: The cpu you limit the docker to use.<br/>
`CMD`: The model and corresponding parameters you want to run.<br/>
`ENV`: The environment variables you want to export to the docker container<br/>
2. Run acc_auc_benchmark.sh
