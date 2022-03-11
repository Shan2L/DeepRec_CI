#!/usr/bin/env python
import click
import os
from jinja2 import Environment, FileSystemLoader


def write_data(data, file):
    """
    Write data to file
    """
    with open(file, 'w', encoding="utf-8") as f:
        f.write(data)


@click.command()
@click.option('-tempdir', default='./templates', help='The location of the  templates dir')
@click.option('-tf_temp', default='tf_template.yaml', help='The location of the tf template file')
@click.option('-deeprec_temp', default='deeprec_template.yaml', help='The location of the deeprec template file')
@click.option('-outdir', default='./yaml_file', help='The location of the output file')
def run(tempdir, tf_temp, deeprec_temp, outdir):
    file_loader = FileSystemLoader(tempdir)
    env = Environment(loader=file_loader)
    env.trim_blocks = True
    env.lstrip_blocks = True
    env.rstrip_blocks = True
    deeprec_template = env.get_template(deeprec_temp)

    model_list = ["wdl", "dssm", "deepfm", "dlrm", "dien", "din"]
    model_name_list = ["WDL", "DSSM", "DeepFM", "DLRM", "DIEN", "DIN"]
    package_list = ["deeprec_bf16", "deeprec_fp32", "tf_fp32"]
    for package in package_list:          
        for (model, model_name) in zip(model_list, model_name_list):
            if package == "tf_fp32":
                template = env.get_template(tf_temp)  
                output = template.render(MEM_USAGE_STRATEGY="closed", MODEL_NAME=model_name, IMAGE="test_image")
            elif package == "deeprec_bf16":
                template = env.get_template(deeprec_temp)  
                output = template.render(MEM_USAGE_STRATEGY="251", MODEL_NAME=model_name, IMAGE="test_image", BF16="--bf16")
            elif package == "deeprec_fp32":
                template = env.get_template(deeprec_temp)  
                output = template.render(MEM_USAGE_STRATEGY="251", MODEL_NAME=model_name, IMAGE="test_image")
            outfile = package + "_" + model + ".yaml"
            out = os.path.join(outdir, outfile)
            write_data(output, out)
            print(output)
            print(f"Configuration file has been generated:---->{out}")


run()

