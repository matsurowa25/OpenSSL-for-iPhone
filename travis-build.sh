#!/bin/sh

# Log script output with prefix
log_output()
{
  while read INPUT; do
    echo "${1} ${INPUT}"
  done
}

# Shut up curl
export CURL_OPTIONS="-s"

# Prefixes for logging
LOGPREFIX_102="1.0.2/ARCHS  "
LOGPREFIX_110="1.1.0/TARGETS"

# Build 1.0.2 in current directory
./build-libssl.sh --noparallel --verbose-on-error | log_output "${LOGPREFIX_102}" &
PID_ARCHS=$!

# Build 1.1.0 in (temporary) subdirectory
mkdir targets
cd targets
cp -r ../include .
../build-libssl.sh --noparallel --verbose-on-error --ec-nistp-64-gcc-128 --version=1.1.0f | log_output "${LOGPREFIX_110}" &
PID_TARGETS=$!

echo "SCRIPT  Started jobs, waiting for jobs to finish"
wait ${PID_ARCHS}
wait ${PID_TARGETS}

# Verify/prepare 1.1.0 build dir
xcrun -sdk iphoneos lipo -info ./lib/*.a | log_output "${LOGPREFIX_110}"
../create-openssl-framework.sh | log_output "${LOGPREFIX_110}"
xcrun -sdk iphoneos lipo -info openssl.framework/openssl | log_output "${LOGPREFIX_110}"
cp -r ../OpenSSL-for-* .

# Back to main dir
cd ..
xcrun -sdk iphoneos lipo -info ./lib/*.a | log_output "${LOGPREFIX_102}"
./create-openssl-framework.sh | log_output "${LOGPREFIX_102}"
xcrun -sdk iphoneos lipo -info openssl.framework/openssl | log_output "${LOGPREFIX_102}"

