#!/usr/bin/env bash

set -euo pipefail

if [[ "$_BUILD_BRANCH" == "refs/heads/main" || "$_BUILD_BRANCH" == "refs/tags/canary" ]]; then
  export _IS_BUILD_CANARY="true"
  export _IS_GITHUB_RELEASE="true"
elif [[ "$_BUILD_BRANCH" == refs/tags/* ]]; then
  _BUILD_VERSION="${_BUILD_VERSION%-*}-0"
  export _BUILD_VERSION
  export _IS_GITHUB_RELEASE="true"
fi
export _RELEASE_VERSION="v${_BUILD_VERSION}"

echo "--------------------------------------------------"
echo "RELEASE VERSION: $_RELEASE_VERSION"
echo "--------------------------------------------------"

echo "_BUILD_VERSION=${_BUILD_VERSION}" >> "${GITHUB_ENV}"
echo "_RELEASE_VERSION=${_RELEASE_VERSION}" >> "${GITHUB_ENV}"
echo "_IS_BUILD_CANARY=${_IS_BUILD_CANARY}" >> "${GITHUB_ENV}"
echo "_IS_GITHUB_RELEASE=${_IS_GITHUB_RELEASE}" >> "${GITHUB_ENV}"

cmake -S . -B build \
  -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw32.cmake \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --target d3d9 --parallel

cpack --config build/CPackConfig.cmake \
  -G ZIP \
  -B "$PWD/dist" \
  -D "CPACK_PACKAGE_NAME=${_RELEASE_NAME}" \
  -D "CPACK_PACKAGE_VERSION=${_BUILD_VERSION}" \
  -D "CPACK_PACKAGE_FILE_NAME=${_RELEASE_NAME}-${_RELEASE_VERSION}-win32"
