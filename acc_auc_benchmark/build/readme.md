
### use /home/shanlin/auto_benchmark/build/image_build.sh to automatically build and push the Image with **DeepRec** environment.

**How to use**?
1. Modify the configuration file at the directory of `/home/shanlin/auto_benchmark/config.properties`

- Check about the item: **about code**

    `commit_id`： specify the commit id of the git code you want to build to a whl package
    
    `branch_name`： sepcify the branch name of the git code you want to build to a whl package
- Check about the item: **about image**

    `build_image_repo` ：is the image repo used to build DeepRec whl

    `base_image_modelzoo`： the base image with both model code and DeepRec environment

    `base_image_deeprec`：the base image with only the deepRec environment

- Check about the item: **about directory**

    `ali_repo_dir`：directory used to reserve the git code of ali-deepRec

    `whl_dir`：directory used to reserve the whl which has been built

    **Notice**：all the cofiguration items are splitted by spacebar

2. execute the bash command as follows:

	```bash
    bash image_build.sh [-l]
    ```
	
	you can use -l to specify that once the images finished building they will be tag as the "latest" and push to the remote dockerhub