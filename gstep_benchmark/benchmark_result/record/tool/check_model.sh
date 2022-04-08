# modify the shell command line to comments, by given column id or regexp
function modify_text()
{
        regex1=$1
        regex2=$2
        col_id=$(cat $src_file | grep -n $regex1 | grep $regex2  |awk -F ':' '{print $1}')
        content=$(cat $src_file | grep -n $regex1 | grep $regex2 | awk -F ':' '{print $2}')
        sed -i "${col_id}c # $content" $src_file
}


catg=$1
currentTime=$2
test_list=$3

exist_list=$(ls -F /root/modelzoo | grep '/'|sed 's/\///g')
echo $exist_list
echo $test_list
src_file=/benchmark_result/record/script/$currentTime/${catg}.sh

for model in $test_list
do
        if [[ -z $(echo $exist_list | grep $model) ]];then
                echo "[ERROR] Modle $model does not exists"
                modify_text  "echo" $model
                modify_text  "cd" "/root/modelzoo/$model"
                modify_text  "timeline" "${model,,}"
        fi
done


