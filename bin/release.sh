#!/bin/bash -f

BUILD_NO=$(cat .build-counter)
BUILD_NO_NEXT=$((${BUILD_NO}+1))
echo "${BUILD_NO_NEXT}" > .build-counter

GITHUB_REPO_NAME=bkjeholt/${1}
GITHUB_BRANCH=${2}

DOCKER_HUB_NAME=bkjeholt

BUILD_ARCHITECTURE=$(sh bin/get-architecture.sh)
DOCKER_IMAGE_DEVELOPMENT_TAG=dev-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_BRANCH_TAG=dev-${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_RELEASE_TAG=latest-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_RELEASE_BRANCH_TAG=${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}

# Get the docker image identity for the dev-xxx tag

echo "-------------------------------------------------------------------------------"
echo "Release the following repositories "
echo " Repository:         ${GITHUB_REPO_NAME} "
echo " Branch:             ${GITHUB_BRANCH} "
echo " Dev. docker images: ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} "
echo "                     ${GITHUB}:${DOCKER_IMAGE_DEVELOPMENT_BRANCH_TAG} "
echo " Rel. docker images: ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG} "
echo "                     ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG} "
echo "-------------------------------------------------------------------------------"

DOCKER_DEVELOPMENT_IMAGE_ID=$(docker images -q $GITHUB_REPO_NAME:${DOCKER_IMAGE_DEVELOPMENT_TAG})

echo " IMAGE ID:           ${DOCKER_DEVELOPMENT_IMAGE_ID} "

DOCKER_IMAGE_TAGS=$(docker images --format "{{.Tag}} {{.ID}}" | \
                    grep $DOCKER_DEVELOPMENT_IMAGE_ID | \
                    grep -v ${DOCKER_IMAGE_DEVELOPMENT_TAG} | \
                    sed 's/-x86[^\n]*//g' )

echo " IMAGE TAGS:         ${DOCKER_IMAGE_TAGS} "

DOCKER_IMAGE_BRANCH=$(echo "${DOCKER_IMAGE_TAGS}" | sed 's/dev-//g'| sed 's/-[^\n]*//g' | head -1)
DOCKER_IMAGE_BUILD_NO=$(echo "${DOCKER_IMAGE_TAGS}" | sed 's/dev-[^-]*-//g')

echo "-------------------------------------------------------------------------------"
echo "Release the following repositories "
echo " Repository:         ${GITHUB_REPO_NAME} "
echo " Branch:             ${DOCKER_IMAGE_BRANCH} "
echo " Build number:       ${DOCKER_IMAGE_BUILD_NO} "
echo " Dev. docker images: ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} "
echo "                     ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_BRANCH_TAG} "
echo " Rel. docker images: ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG} "
echo "-------------------------------------------------------------------------------"

exit 0

docker tag ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} \
           ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG}
docker tag ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_BRANCH_TAG} \
           ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG}

echo "-------------------------------------------------------------------------------"
echo "Push the following images to http://hub.docker.com "
echo " Repository:         bkjeholt "
echo " Docker images:      ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG} "
echo "-------------------------------------------------------------------------------"

docker push ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG}
docker push ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG}

exit 0

DOCKER_IMAGE_NAME=${1}
DOCKER_IMAGE_BASE_TAG=${GITHUB_BRANCH}-${BUILD_NO}
DOCKER_IMAGE_FULL_NAME=${DOCKER_HUB_NAME}/${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_TAG=${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_CLEAN_TAG=${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_FULL_TAG=dev-${GITHUB_BRANCH}-${BUILD_NO}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_CLEAN_TAG=dev-${GITHUB_BRANCH}-${BUILD_ARCHITECTURE}
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
