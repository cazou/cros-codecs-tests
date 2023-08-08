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
    vp8 \
    vp9 \
    h.264 \
    h.265 \
"

TEST_SUITES_vp8="VP8-TEST-VECTORS"
TEST_SUITES_vp9="VP9-TEST-VECTORS VP9-TEST-VECTORS-HIGH"
TEST_SUITES_h264="JVT-AVC_V1 JVT-FR-EXT"
TEST_SUITES_h265="JCT-VC-HEVC_V1"

mkdir /opt/cros-codecs
cd /opt/cros-codecs

wget $CCDEC_URL
chmod a+x ccdec

export PATH=$PATH:/opt/cros-codecs

for codec in ${SUPPORTED_CODECS}; do
	${FLUSTER_DIR}/fluster.py run -d "ccdec-${codec}" -f junitxml -so results.xml 

	suite_var_name="TEST_SUITES_${codec/./}"
	eval "suites=\$$suite_var_name"
	for ts in ${suites}; do
		echo Running /usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec}
		/usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec}
	done
done

