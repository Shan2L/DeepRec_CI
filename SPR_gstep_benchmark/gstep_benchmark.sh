# 将要在容器中执行的命令归档
function make_script()
{
    IFS_old=$IFS
    IFS=$'\n'
    make_single_script deeprec_bf16 $deeprec_bf16_script
    make_single_script deeprec_fp32 $deeprec_fp32_script
    make_single_script tf_fp32 $tf_fp32_script
    IFS=$IFS_old
}
function make_single_script()
{
    catg=$1
    script=$2
    bf16_para=

    [[ ! -d $(dirname $script) ]] && mkdir -p $(dirname $script)
    [[ $catg == "deeprec_bf16" ]] && bf16_para="--bf16"
    [[ $catg != "tf_fp32" ]] && echo "$env_var" > $script && echo " " >> $script
    for line in $(cat $config_file | grep CMD | grep $catg )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
        paras=$(echo "$line" | awk -F ":" '{print $2}' | awk -F "|" '{print $2}')
        log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of $catg $paras.......'" >> $script
        echo "cd /home/shanlin/modelzoo/$model_name/" >> $script
      	[[ ! -d  $checkpoint_dir/$currentTime/${model_name,,}_script$$log_tag ]]&& sudo mkdir -p $checkpoint_dir/$currentTime/${model_name,,}_$script$log_tag
        if [[  $weekly != 'true' ]];then
            newline="LD_PRELOAD=/home/shanlin/modelzoo/libjemalloc.so.2.5.1 numactl -C $cpus -l $command $paras --no_eval --steps 3000 $bf16_para --checkpoint $checkpoint_dir/$currentTime/${model_name,,}_$catg$log_tag  >$log_dir/$currentTime/${model_name,,}_$catg$log_tag.log 2>&1"
        else
            newline="LD_PRELOAD=/home/shanlin/modelzoo/libjemalloc.so.2.5.1 numactl -C $cpus -l $command --timeline 1000 --no_eval --steps 3000 $bf16_para --checkpoint $checkpoint_dir/$currentTime/${model_name,,}_$catg  >$log_dir/$currentTime/${model_name,,}_$catg.log 2>&1"
        fi
        echo $newline >> $script
    done
}

function echoColor() {
	case $1 in
	green)
		echo -e "\033[32;40m$2\033[0m"
		;;
	red)
		echo -e "\033[31;40m$2\033[0m"
		;;
	*)
		echo "Example: echo_color red string"
		;;
	esac
}

function push_to_git()
{
	current_path=$(pwd)
	cd $pointcheck_dir/$currentTime \
	&& zip -r ${currentTime}-deeprec-${dp_tag}-tf-${tf_tag}.zip ./* \
	&& git add $pointcheck_dir/$currentTime/${currentTime}-deeprec-${dp_tag}-tf-${tf_tag}.zip \
	&& git add $gol_dir/$currentTime/* 
	cd $current_path
	if [[ $weekly == 'true' ]];then
		git commit -m "[Regression Benchmark] Add the checkpoint and log directory of $currentTime" 
	else
		git commit -m "[Benchmark] Add the checkpoint and log directory of $currentTime" 
	fi
	git push
	while [[ $? != 0 ]]
	do
		git push
	done
}


set -x
# 获取当前时间戳
currentTime=`date "+%Y-%m-%d-%H-%M-%S"`

# 配置文件的存放位置
config_file="./config.properties"

# 读取目录配置
log_dir='./benchmark_result/log/'
log_dir=$(cd $log_dir && pwd)
checkpoint_dir='./benchmark_result/checkpoint/'
checkpoint_dir=$(cd $checkpoint_dir && pwd)

# 主机上的存放位置
gol_dir=$(cat $config_file |grep gol_dir | awk -F " " '{print $2}')
[[ ! -d $gol_dir ]] && mkdir -p $gol_dir && gol_dir=$(cd $gol_dir && pwd)

pointcheck_dir=$(cat $config_file | grep pointcheck_dir | awk -F " " '{print $2}')
[[ ! -d $pointcheck_dir ]] && mkdir -p $pointcheck_dir &&pointcheck_dir=$(cd $pointcheck_dir && pwd)

# 测试命令脚本存放的位置
deeprec_fp32_script="./benchmark_result/record/script/$currentTime/deeprec_fp32.sh"
deeprec_bf16_script="./benchmark_result/record/script/$currentTime/deeprec_bf16.sh"
tf_fp32_script="./benchmark_result/record/script/$currentTime/tf_fp32.sh"

# 从配置文件读取测试的命令
deeprec_bf16_CMD=$(cat $config_file | grep CMD | grep deeprec_bf16 | awk -F ":" '{print$2}')
deeprec_fp32_CMD=$(cat $config_file | grep CMD | grep deeprec_fp32 | awk -F ":" '{print$2}')
tf_fp32_CMD=$(cat $config_file | grep CMD | grep deeprec_fp32 | awk -F ":" '{print$2}')

# 从配置文件读取cpu限制
cpus=$(cat $config_file | grep cpus | awk -F " " '{print $2}')

# 从配置文件读取测试环境变量配置
env_var=$(cat $config_file |grep export)


# 创建目录
[[ ! -d "./benchmark_result/record/script/$currentTime/" ]] && mkdir -p ./benchmark_result/record/script/$currentTime/
[[ ! -d $gol_dir/$currentTime ]] && mkdir -p "$gol_dir/$currentTime" 
[[ ! -d $pointcheck_dir/$currentTime ]] && mkdir -p "$pointcheck_dir/$currentTime"

set -x
make_script\
&&source /home/shanlin/deeprec/bin/activate\
&&bash $deeprec_fp32_script\
&&bash $deeprec_bf16_script\
&&deactivate\
&&source /home/shanlin/stock_tf/bin/activate\
&&bash $tf_fp32_script\
&&python3 ./gstep_count.py --log_dir=$gol_dir/$currentTime\
&&push_to_git
