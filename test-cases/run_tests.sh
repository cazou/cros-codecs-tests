#!/bin/bash

# Run tests for cros-codecs using ccdec and flsuter.

# Arguments:
# $1: Fluster folder
# $2: cros-codecs github action run id
# $3: cros-codecs github token

FLUSTER_DIR="${1}"
CCDEC_URL="${2}"
SINGLE_RUN="${3:-no}"

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

if [ ! -e /opt/cros-codecs/ccdec ]; then
	mkdir /opt/cros-codecs
	cd /opt/cros-codecs

	wget $CCDEC_URL
	chmod a+x ccdec

	export PATH=$PATH:/opt/cros-codecs
fi

if [ "${SINGLE_RUN}" == "yes" ]; then
	FLUSTER_ARGS="-j 1"
fi

for codec in ${SUPPORTED_CODECS}; do
	suite_var_name="TEST_SUITES_${codec/./}"
	eval "suites=\$$suite_var_name"
	for ts in ${suites}; do
		echo Running /usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec} ${FLUSTER_ARGS}
		/usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec}
	done
done

