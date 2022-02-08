#!/bin/bash
set -ex
jupyterlab_dir=$(dirname $0)
BRANCH=$(git name-rev --name-only HEAD)
BRANCH=$(basename ${BRANCH})

if [[ ${SKIP_BASE_IMAGE_BUILD} -eq 0 ]]; then
    pushd $(dirname $jupyterlab_dir)
    bash base_images/build-image.sh
    popd
    for base_image in $(cat built_images.txt); do
        IMAGE_NAME=$(basename $base_image)
        IMAGE_REF=${CI_REGISTRY_IMAGE}/jupyterlab3/${IMAGE_NAME}
        docker build -t ${IMAGE_REF} --build-arg BASE_IMAGE=${base_image} -f docker/Dockerfile .
        docker push ${IMAGE_REF}
    done

    elif [[ ${SKIP_BASE_IMAGE_BUILD} -eq 1 ]]; then
        if [[ -z ${BASE_IMAGE_NAME} ]]; then
            echo "WARNING: No value provided for BASE_IMAGE_NAME, will continue with default miniconda3 image"
            BASE_IMAGE_NAME=miniconda3:4.10.3p1
        fi
        IMAGE_REF=${CI_REGISTRY_IMAGE}/jupyterlab3/${BASE_IMAGE_NAME}
        docker build -t ${IMAGE_REF} --build-arg BASE_IMAGE=${base_image} -f docker/Dockerfile .
        docker push ${IMAGE_REF}
fi
