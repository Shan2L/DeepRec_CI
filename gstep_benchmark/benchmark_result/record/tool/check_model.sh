# modify the shell command line to comments, by given column id or regexp
function modify_text()
{       
        col_id=$(cat $src_file | grep -n $regex | awk -F ':' '{print$1}')
        content=$(cat $src_file | grep -n $regex | awk -F ':' '{print$2}')
        sed -i '${col_id}c # $content' $scr_file
}


catg=$1
currentTime=$2
test_list=$3

exist_list=$(ls -F /root/modelzoo | grep '/'|sed 's/\///g')
src_file=/bechmark_result/record/script/$currentTime/${catg}.sh

for model in $test_list
do
        if [[ -z $(echo $exist_list | grep $model) ]];then
                echo "[ERROR] Modle $model does not exists"
                modify_text regex 'testing $model'
                modify_text regex 'cd /root/modelzoo/'
                modify_text regex '${model,,}_$catg'
        fi
done

