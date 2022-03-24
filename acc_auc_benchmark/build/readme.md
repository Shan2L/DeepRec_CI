
## Building Whl and Making Image
![6cf6a71ba1e756d774c92d85220bab78.png](https://github.com/GosTraight2020/DeepRec_CI/blob/master/.asset/build.png)

**How does it work**?
The workflow is showed as the above pic
1. Modify the paramters of config file(config.proerties)
2. The image_build.sh will read information from the config file
3. Checkout the Code to the branch and commit specified in config file , then run container1，mount directory whl_build and cache.
4. In container1 , build_whl.sh will run to set proxy and make directories which will be used soon.
5. Run bazel_build to build the DeepRec to whl file.
6. Copy whl to whl_package directory.
7. Use ossutil to upload the whl file to OSS.
8. Run container2 and container3 which will mount directory whl_package.
9. Install whl in container2 and container3，and commit container2 container3 to image2 image3.
10. push image2 and image3 to DockerHub

**How to use**?
1. Modify the configuration file at the directory of `/home/shanlin/auto_benchmark/acc_auc_benchmark/config.properties`

- Check about the item: **about code**

    `commit_id`： specify the commit id of the git code you want to build to a whl package
    
    `branch_name`： specify the branch name of the git code you want to build to a whl package
    
    `code_repo`: specify the github repo
- Check about the item: **about image**

    `build_image_repo` ：is the image repo used to build DeepRec whl

    `base_image_modelzoo`： the base image with both model code and DeepRec environment

    `base_image_deeprec`：the base image with only the deepRec environment



    **Notice**：all the cofiguration items are splitted by spacebar

2. execute the bash command as follows:

	```bash
    bash image_build.sh [-l]
    ```
	
you can use -l to specify that once the images finished building they will be tag as the "latest" and push to the remote dockerhub

You can use Github Action to build image with UI. https://github.com/GosTraight2020/DeepRec_CI/actions/workflows/build.yml
