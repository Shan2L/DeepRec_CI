## Instruction  
The directory named "auto_benchmark" has  four modules ,they are:
- `build`: this module is used to build whl package from git code and install the package in a specified image to build a new image , and push this new image to the remote docker hub.  It has been put in the directory named "acc_auc_benchmark".  
<br>

- `acc_auc_benchmark`：this module is used to benchmark the ACC and AUC of specified deepRec package, which should has been installed in a docker image using the build module already. 
<br>

- `gstep_benchmark`: this module is used to benchmark the Global steps/ second of specified deepRec package in a standalone environment, which should has ben installed in a docker image using the build module already.
<br>

- `distrib_benchmark`：this module is used to benchmark the Global steps/seconds of specified deepRec package in a distributed environment ,the deepRec package should has ben installed in a docker image using the build module already.

## How to use

First of all you should clone the code to the host which you want  to run you code at.
```
	git clone https://github.com/GosTraight2020/DeepRec_CI.git
```

### How to build a docker image by specifying  the git branch name and commit id
1. modify the items you need in ./auto_benchmark/acc_auc_benchmark/config.properties, such as branch name, commit id ,ase image et al.
2. cd to the directory : ./auto_benchmark/acc_auc_benchmark/build/
```bash
	cd ./DeepRec_CI/acc_auc_benchmark/build/
```
3. run the script `image_build.sh` with an optional parameter "- l", which tells the program whether you want to tag the image as the latest after the image has been built.
```bash
	bash image_build.sh [-l]
```


### How to benchmark ACC and AUC using an image with installed deepRec environment
1. cd to the directory "./DeepRec_CI/acc_auc_benchmark/"
```bash
	cd ./DeepRec_CI/acc_auc_benchmark/
```
3. modify the items you need in ./config.properties, change the value of the key **"deeprec_test_image"** and **"tf_test_image"** to be the image you want to use to benchmark.
4. modify the command rows that start with **"CMD"**, they are commands which will be implemented in the image.
5. run the " ./acc_benchmark.sh"
```bash
	bash acc_benchmark.sh
```
5. check the log files in the directory "./DeepRec_CI/acc_auc_benchmark/benchmark_result/log/$currentTime"

### How to benchmark Global steps/s  using an image with installed deepRec environment in  standalone env
1. cd to the directory "./DeepRec_CI/gstep_benchmark/"
```bash
	cd ./DeepRec_CI/gstep_benchmark/
```
3. modify the items you need in ./config.properties, change the value of the key **"deeprec_test_image"** and **"tf_test_image"** to be the image you want to use to benchmark.
4. modify the command rows that start with **"CMD"**, they are commands which will be implemented in the image.
5. run the  script " ./acc_benchmark.sh"
```bash
	bash gstep_benchmark.sh
```
5. check the log files in the directory "./DeepRec_CI/gstep_benchmark/benchmark_result/logs/$currentTime"


### How to benchmark Global steps/s  using an image with installed deepRec environment in distributed env
1. cd to the directory "./DeepRec_CI/distrib_benchmark/"
```bash
	cd ./DeepRec_CI/acc_auc_benchmark/
```
3. you can modify the yaml files which are used to create an k8s tasks  by only modifying the template files in directory **:".\templates\"** , and then implement the python script "**gen_template.py**"
```bash
	python gen_template.py
```
5. run the script " **./distributed_test.sh**"
```bash
	bash gstep_benchmark.sh
```
4. check the log files in the directory "./DeepRec_CI/distrib_benchmark/logs/$currentTime"
