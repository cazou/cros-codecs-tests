#!/bin/bash

# Run tests for cros-codecs using ccdec and flsuter.

# Arguments:
# $1: Fluster folder
# $2: cros-codecs github action run id
# $3: cros-codecs github token

FLUSTER_DIR="${1}"
CCDEC_URL="${2}"
#CCDEC_RUN_ID="${2}"
#CCDEC_TOKEN="${3}"

SUPPORTED_CODECS="
    vp9 \
"

TEST_SUITES="
    JVT-AVC_V1 \
"

mkdir /opt/cros-codecs
cd /opt/cros-codecs

#ARTIFACTS=$(curl -L \
#  -H "Accept: application/vnd.github+json" \
#  -H "X-GitHub-Api-Version: 2022-11-28" \
#  https://api.github.com/repos/cazou/cros-codecs/actions/artifacts)


#archive_url=$(
#for idx in $(seq 0 $(echo ${ARTIFACTS} | jq .total_count)); do
#	if [ $(echo ${ARTIFACTS} | jq ".artifacts[${idx}].workflow_run.id") = ${CCDEC_RUN_ID} ]; then
#		echo ${ARTIFACTS} | jq -M ".artifacts[${idx}].archive_download_url"
#		break
#	fi
#done
#)

#curl -L -o ccdec.zip \
#  -H "Accept: application/vnd.github+json" \
#  -H "Authorization: Bearer ${CCDEC_TOKEN}" \
#  -H "X-GitHub-Api-Version: 2022-11-28" \
#  ${archive_url}

#unzip ccdec.zip

#wget https://people.collabora.com/~detlev/cros-codecs-tests/iHD_drv_video.so
#mv iHD_drv_video.so /usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so

apt-get -y install software-properties-common
apt-add-repository -y --component non-free
apt-get update
apt-get install -y intel-media-va-driver-non-free

wget $CCDEC_URL
chmod a+x ccdec

export PATH=$PATH:/opt/cros-codecs

ccdec --help

for codec in ${SUPPORTED_CODECS}; do
	${FLUSTER_DIR}/fluster.py run -d "ccdec-${codec}" -f junitxml -so results.xml 
#	for ts in ${TEST_SUITES}; do
#		/usr/bin/fluster_parser.py -ts JVT-AVC_V1 -d ccdec-${codec}
#	done
done

ccdec ../fluster/fluster/../resources/VP9-TEST-VECTORS/vp90-2-00-quantizer-01.webm/vp90-2-00-quantizer-01.webm --output ../fluster/fluster/../results/VP9-TEST-VECTORS/vp90-2-00-quantizer-01.webm.out --input-format vp9 --output-format i420

