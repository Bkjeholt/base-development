#!/bin/bash -f

BUILD_NO=$(cat .build-counter)
BUILD_NO_NEXT=$((${BUILD_NO}+1))
echo "${BUILD_NO_NEXT}" > .build-counter

GITHUB_REPO_NAME=Bkjeholt/${1}
GITHUB_BRANCH=${2}

DOCKER_HUB_NAME=bkjeholt

BUILD_ARCHITECTURE=rpi

DOCKER_IMAGE_NAME=${1}
DOCKER_IMAGE_BASE_TAG=${GITHUB_BRANCH}-${BUILD_NO}
DOCKER_IMAGE_FULL_NAME=${DOCKER_HUB_NAME}/${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_FULL_TAG=${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_REV_TAG=${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_LATEST_TAG=latest-${BUILD_ARCHITECTURE}

DEVELOPMENT_DIRECTORY=${DOCKER_IMAGE_NAME}-${GITHUB_BRANCH}

yes | rm -r ${DEVELOPMENT_DIRECTORY}

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

DOCKERFILE_PATH=${DEVELOPMENT_DIRECTORY}/Dockerfile-${BUILD_ARCHITECTURE}

# Start the build

docker build -f ${DOCKERFILE_PATH} \
             --build-arg APPLICATION_REVISION=${GITHUB_BRANCH}-${BUILD_NO} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_FULL_TAG} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_REV_TAG} \
             -t ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_LATEST_TAG} .

echo "-------------------------------------------------------------------------------"
echo "Export to docker hub "
echo " Repository:     ${DOCKER_IMAGE_FULL_NAME} "
echo " Tag:            ${DOCKER_IMAGE_LATEST_TAG} "
echo "                 ${DOCKER_IMAGE_REV_TAG} "
echo "                 ${DOCKER_IMAGE_FULL_TAG} "
echo "-------------------------------------------------------------------------------"

docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_FULL_TAG}
docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_REV_TAG}
docker push ${DOCKER_IMAGE_FULL_NAME}:${DOCKER_IMAGE_LATEST_TAG}
