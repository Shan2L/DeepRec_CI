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
    # 记录运行的命令脚本
    bf16_para=
    [[ ! -d $(dirname $script) ]] && mkdir -p $(dirname $script)
    [[ $catg != "tf_fp32" ]] && echo "$env_var" > $script && echo " " >> $script
    [[ $catg == "deeprec_bf16" ]] && bf16_para="--bf16"
        
    for line in $(cat $config_file | grep CMD | grep $catg )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
        paras=$(echo "$line" | awk -F ":" '{print $2}' | awk -F "|" '{print $2}')
        log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of deeprec_bf16 $paras.......'" >> $script
        echo "cd /root/modelzoo/$model_name/" >> $script
      	if [[ ! -d  $checkpoint_dir$currentTime/${model_name,,}_script$$log_tag ]];then
      		sudo mkdir -p $checkpoint_dir$currentTime/${model_name,,}_$script$log_tag
      	fi
        if [[  $weekly != 'true' ]];then
            newline="LD_PRELOAD=/root/modelzoo/libjemalloc.so.2.5.1 $command $paras --no_eval --steps 3000 $bf16_para \
                    --checkpoint $checkpoint_dir$currentTime/${model_name,,}_$script$log_tag  >$log_dir$currentTime/${model_name,,}_deeprec_bf16$log_tag.log 2>&1"
        else
            newline="LD_PRELOAD=/root/modelzoo/libjemalloc.so.2.5.1 $command --timeline 1000 --no_eval --steps 3000 $bf16_para \
                    --checkpoint $checkpoint_dir$currentTime/${model_name,,}_$script  >$log_dir$currentTime/${model_name,,}_deeprec_bf16.log 2>&1"
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


function runSingleContainer()
{ 
    image_repo=$1
    script_name=$2
    container_name=$(echo $2 | awk -F "." '{print $1}')
    [[ -z $cpus ]] && optional=""
    [[ -n $cpus ]] && optional="--cpuset-cpus $cpus"

    host_path=$(cd benchmark_result && pwd) 
    sudo docker run --name $container_name\
                    $optional  \
	            --rm \
                    -v $host_path:/benchmark_result/\
                    $image_repo /bin/bash /benchmark_result/record/script/$currentTime/$script_name  
}

function runContainers()
{  
    [[ -n $deeprec_bf16_CMD ]] && runSingleContainer $deeprec_test_image deeprec_bf16.sh        
    [[ -n $deeprec_fp32_CMD ]] && runSingleContainer $deeprec_test_image deeprec_fp32.sh       
    [[ -n $tf_fp32_CMD ]] && runSingleContainer $tf_test_image tf_fp32.sh   
}

function checkEnv()
{   
    status1=$(sudo docker ps -a | grep deeprec_bf16)
    status2=$(sudo docker ps -a | grep deeprec_fp32)
    status3=$(sudo docker ps -a | grep tf_fp32)
    [[  -n $status1 ]] && sudo docker rm -f deeprec_bf16
    [[  -n $status2 ]] && sudo docker rm -f deeprec_fp32
    [[  -n $status3 ]] && sudo docker rm -f tf_fp32
}


currentTime=`date "+%Y-%m-%d-%H-%M-%S"`
weekly=$1

config_file="./config.properties"

log_dir=$(cat $config_file |grep log_dir | awk -F " " '{print $2}')
checkpoint_dir=$(cat $config_file | grep checkpoint_dir | awk -F " " '{print $2}')

gol_dir=$(cat $config_file |grep gol_dir | awk -F " " '{print $2}')
pointcheck_dir=$(cat $config_file | grep pointcheck_dir | awk -F " " '{print $2}')

deeprec_fp32_script="./benchmark_result/record/script/$currentTime/deeprec_fp32.sh"
deeprec_bf16_script="./benchmark_result/record/script/$currentTime/deeprec_bf16.sh"
tf_fp32_script="./benchmark_result/record/script/$currentTime/tf_fp32.sh"

deeprec_test_image=$(cat $config_file |grep deeprec_test_image | awk -F " " '{print$2}' )
tf_test_image=$(cat $config_file |grep tf_test_image | awk -F " " '{print$2}' )

sudo docker pull $deeprec_test_image
sudo docker pull $tf_test_image

deeprec_bf16_CMD=$(cat $config_file | grep CMD | grep deeprec_bf16 | awk -F ":" '{print$2}')
deeprec_fp32_CMD=$(cat $config_file | grep CMD | grep deeprec_fp32 | awk -F ":" '{print$2}')
tf_fp32_CMD=$(cat $config_file | grep CMD | grep tf_fp32 | awk -F ":" '{print$2}')

cpus=$(cat $config_file | grep cpus | awk -F " " '{print $2}')
env_var=$(cat $config_file |grep export)

[[ ! -d "./benchmark_result/record/script/$currentTime/" ]] && mkdir -p ./benchmark_result/record/script/$currentTime/
[[ ! -d $gol_dir$currentTime ] && mkdir -p "$gol_dir$currentTime" 
[[ ! -d $pointcheck_dir$currentTime ]] && mkdir -p "$pointcheck_dir$currentTime"

make_script\
&& checkEnv\
&& runContainers\
&& python3 ./gstep_count.py --log_dir=$gol_dir$currentTime
