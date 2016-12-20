#!/bin/bash -f

BUILD_NO=$(cat .build-counter)
BUILD_NO_NEXT=$((${BUILD_NO}+1))
echo "${BUILD_NO_NEXT}" > .build-counter

GITHUB_REPO_NAME=Bkjeholt/${1}
GITHUB_BRANCH=${2}

DOCKER_HUB_NAME=bkjeholt

BUILD_ARCHITECTURE=rpi

DOCKER_IMAGE_NAME=${1}
DOCKER_IMAGE_BASE_TAG=${GITHUB_BRANCH}
DOCKER_IMAGE_FULL_NAME=${DOCKER_HUB_NAME}/${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_TAG=${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_BUILD_NO_TAG=${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_LATEST_TAG=latest-${BUILD_ARCHITECTURE}

DEVELOPMENT_DIRECTORY=${DOCKER_IMAGE_NAME}-${DOCKER_IMAGE_BASE_TAG}

yes | rm -r ${DEVELOPMENT_DIRECTORY}

echo "-------------------------------------------------------------------------------"
echo "Build and release images for docker hub "
echo " Clean up development build directories "
echo "-------------------------------------------------------------------------------"

yes | rm -r ${DOCKER_IMAGE_NAME}-${GITHUB_BRANCH}-*-${BUILD_ARCHITECTURE}

echo "-------------------------------------------------------------------------------"
echo "Clone project from Github "
echo " Repository:      ${GITHUB_REPO_NAME} "
echo " Branch:          ${GITHUB_BRANCH} "
echo " Build counter:   ${BUILD_NO} "
echo " Docker image:    ${DOCKER_IMAGE_NAME} "
echo " Docker base tag: ${DOCKER_IMAGE_BASE_TAG} "
echo " Architecture:    ${BUILD_ARCHITECTURE} "
echo "-------------------------------------------------------------------------------"

git clone -b ${GITHUB_BRANCH} --single-branch https://github.com/${GITHUB_REPO_NAME}.git ${DEVELOPMENT_DIRECTORY}

echo "-------------------------------------------------------------------------------"
echo "Build the project "
echo " Directory:       ${DEVELOPMENT_DIRECTORY} "
echo "-------------------------------------------------------------------------------"

cd ${DEVELOPMENT_DIRECTORY}

DOCKERFILE_PATH=Dockerfile-${BUILD_ARCHITECTURE}

# Start the build

docker build -f ${DOCKERFILE_PATH} \
             --build-arg APPLICATION_REVISION=${GITHUB_BRANCH}-${BUILD_NO} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_TAG} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_LATEST_TAG} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_BUILD_NO_TAG} \
             .

docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_TAG}
docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_LATEST_TAG}
docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_BUILD_NO_TAG}
