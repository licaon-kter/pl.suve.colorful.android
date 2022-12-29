#!/bin/bash

set -eu -o pipefail

# -- cd to script dir so we're in a known location

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

# -- parse args

CLEAN=0
DEBUG=0

while [[ "$#" -gt 0 ]]; do
	if [[ "$1" == "--clean" ]]; then
		CLEAN=1
	elif [[ "$1" == "--debug" ]]; then
		DEBUG=1
	else
		echo "Unknown option \"${1}\"" >&2
		exit 1
	fi
	shift 1
done

# -- check env vars

if [[ -z "${ANDROID_SDK_ROOT+isset}" ]]; then
	echo "Error: The \$ANDROID_SDK_ROOT variable is not set!" >&2
	exit 1
fi

# -- clean, if requested

if [[ "${CLEAN}" -eq 1 ]]; then
	rm -rf "${SCRIPT_DIR}/android/build"
	rm -rf "${SCRIPT_DIR}/android/app/build"
fi

# -- trigger a Gradle build

cd "${SCRIPT_DIR}/android"
./gradlew
./gradlew build

# -- copy the resulting .apk to current dir

APK_DIR="${SCRIPT_DIR}/android/app/build/outputs/apk/"
if [[ "${DEBUG}" -eq 1 ]]; then
	cp -a "${APK_DIR}/debug/app-debug.apk" "${SCRIPT_DIR}/colorful.apk"
else
	cp -a "${APK_DIR}/release/app-release-unsigned.apk" "${SCRIPT_DIR}/colorful.apk"
fi
