#!/bin/bash -f

BUILD_NO=$(cat .build-counter)
BUILD_NO_NEXT=$((${BUILD_NO}+1))
echo "${BUILD_NO_NEXT}" > .build-counter

GITHUB_REPO_NAME=bkjeholt/${1}
GITHUB_BRANCH=${2}

DOCKER_HUB_NAME=bkjeholt

BUILD_ARCHITECTURE=$(sh bin/get-architecture.sh)

DOCKER_IMAGE_NAME=${1}
DOCKER_IMAGE_BASE_TAG=${GITHUB_BRANCH}-${BUILD_NO}
DOCKER_IMAGE_FULL_NAME=${DOCKER_HUB_NAME}/${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_TAG=${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_CLEAN_TAG=${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_FULL_TAG=dev-${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_CLEAN_TAG=dev-${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_TAG=dev-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_LATEST_TAG=latest-${BUILD_ARCHITECTURE}

DEVELOPMENT_DIRECTORY=${DOCKER_IMAGE_NAME}-${DOCKER_IMAGE_BASE_TAG}

yes | rm -r ${DOCKER_IMAGE_NAME}-${GITHUB_BRANCH}*

echo "-------------------------------------------------------------------------------"
echo "Clone project from Github "
echo " Repository:      ${GITHUB_REPO_NAME} "
echo " Branch:          ${GITHUB_BRANCH} "
echo " Build counter:   ${BUILD_NO} "
echo " Docker image:    ${DOCKER_IMAGE_NAME} "
echo " Docker base tag: ${DOCKER_IMAGE_BASE_TAG} "
echo " Architecture:    ${BUILD_ARCHITECTURE} "
echo "-------------------------------------------------------------------------------"
