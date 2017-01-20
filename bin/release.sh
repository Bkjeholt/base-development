#!/bin/bash -f

BUILD_NO=$(cat .build-counter)
BUILD_NO_NEXT=$((${BUILD_NO}+1))
echo "${BUILD_NO_NEXT}" > .build-counter

GITHUB_REPO_NAME=bkjeholt/${1}
DOCKER_REPO_NAME=${GITHUB_REPO_NAME}

DOCKER_HUB_NAME=bkjeholt

BUILD_ARCHITECTURE=$(sh bin/get-architecture.sh)
DOCKER_IMAGE_DEVELOPMENT_TAG=dev-${BUILD_ARCHITECTURE}

# Get the docker image identity for the dev-xxx tag and all tags with the same image identity

DOCKER_DEVELOPMENT_IMAGE_ID=$(docker images -q $GITHUB_REPO_NAME:${DOCKER_IMAGE_DEVELOPMENT_TAG})

DOCKER_IMAGE_TAGS=$(docker images --format "{{.Tag}} {{.ID}}" | \
                    grep $DOCKER_DEVELOPMENT_IMAGE_ID | \
                    grep -v ${DOCKER_IMAGE_DEVELOPMENT_TAG} | \
                    sed 's/-${BUILD_ARCHITECTURE}[^\n]*//g' )

DOCKER_IMAGE_BRANCH=$(echo "${DOCKER_IMAGE_TAGS}" | sed 's/dev-//g'| sed 's/-[^\n]*//g' | head -1)
DOCKER_IMAGE_BUILD_NO=$(echo "${DOCKER_IMAGE_TAGS}" | sed 's/dev-[^-]*-//g' | sed 's/-[^\n]*//g' | head -1)

DOCKER_IMAGE_DEVELOPMENT_TAG=dev-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_BRANCH_TAG=$dev-{DOCKER_IMAGE_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_DEVELOPMENT_FULL_TAG=dev-${DOCKER_IMAGE_BRANCH}-${DOCKER_IMAGE_BUILD_NO}-${BUILD_ARCHITECTURE}


DOCKER_IMAGE_RELEASE_TAG=latest-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_RELEASE_BRANCH_TAG=${DOCKER_IMAGE_BRANCH}-${BUILD_ARCHITECTURE}
DOCKER_IMAGE_RELEASE_FULL_TAG=${DOCKER_IMAGE_BRANCH}-${DOCKER_IMAGE_BUILD_NO}-${BUILD_ARCHITECTURE}

echo "-------------------------------------------------------------------------------"
echo "Release the following repositories "
echo " Repository:         ${GITHUB_REPO_NAME} "
echo " Branch:             ${DOCKER_IMAGE_BRANCH} "
echo " Build number:       ${DOCKER_IMAGE_BUILD_NO} "
echo " Architecture:       ${BUILD_ARCHITECTURE} "
echo " "
echo " Dev. docker images: ${GITHUB_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} "
echo " and images with the same image id: "

docker images | grep ${DOCKER_DEVELOPMENT_IMAGE_ID}

echo " "
echo " Rel. docker images: ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_FULL_TAG} "
echo "-------------------------------------------------------------------------------"

docker tag ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG}
docker tag ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG}
docker tag ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_DEVELOPMENT_TAG} ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_FULL_TAG}

docker images | grep ${DOCKER_DEVELOPMENT_IMAGE_ID}

echo "-------------------------------------------------------------------------------"
echo "Push the following images to http://hub.docker.com "
echo " Repository:         bkjeholt "
echo " Docker images:      ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG} "
echo "                     ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_FULL_TAG} "
echo "-------------------------------------------------------------------------------"

docker push ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_TAG}
docker push ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_BRANCH_TAG}
docker push ${DOCKER_REPO_NAME}:${DOCKER_IMAGE_RELEASE_FULL_TAG}

echo "-------------------------------------------------------------------------------"
