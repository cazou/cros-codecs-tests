#!/bin/bash

set -x

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
TEST_SUITES_vp9="VP9-TEST-VECTORS"
TEST_SUITES_h264="JVT-AVC_V1"
TEST_SUITES_h265="JCT-VC-HEVC_V1"

SKIP_VECTORS_vp8_test_vectors=""
SKIP_VECTORS_vp9_test_vectors="vp90-2-22-svc_1280x720_3.ivf vp91-2-04-yuv422.webm vp91-2-04-yuv444.webm"
SKIP_VECTORS_jvt_avc_v1="CVFC1_Sony_C FM1_BT_B FM1_FT_E FM2_SVA_C MR5_TANDBERG_C MR8_BT_B MR9_BT_B SP1_BT_A sp2_bt_b"
SKIP_VECTORS_jct_vc_hevc_v1="CONFWIN_A_Sony_1 RAP_B_Bossen_2 RPS_C_ericsson_5 RPS_E_qualcomm_5 TSUNEQBD_A_MAIN10_Technicolor_2"

PARTITION="/dev/nvme0n1p1"
# Load vectors on hard drive
if mountpoint /mnt/vectors; then
	echo "Already loaded"
fi

mkdir -p /mnt/vectors
mount ${PARTITION} /mnt/vectors
time cp -a /opt/fluster/resources/ /mnt/vectors/
rm -fr /opt/fluster/resources
ln -s /mnt/vectors/resources /opt/fluster/resources

export LIBVA_DRIVERS_PATH=/mnt/vectors/
cp -a /usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so /mnt/vectors/

#  Download ccdec binary
if [ ! -e /opt/cros-codecs/ccdec ]; then
	mkdir /opt/cros-codecs
	cd /opt/cros-codecs

	wget $CCDEC_URL
	chmod a+x ccdec
fi

export PATH=$PATH:/opt/cros-codecs

time ccdec /opt/fluster/resources/VP9-TEST-VECTORS/vp90-2-14-resize-10frames-fp-tiles-8-1.webm/vp90-2-14-resize-10frames-fp-tiles-8-1.webm --output /dev/null --input-format vp9 --output-format i420

if [ "${SINGLE_RUN}" == "yes" ]; then
	FLUSTER_ARGS="-j 1"
fi

for codec in ${SUPPORTED_CODECS}; do
	suite_var_name="TEST_SUITES_${codec/./}"
	eval "suites=\$$suite_var_name"
	for ts in ${suites}; do
		ts_lc=${ts,,}
		skip_var_name="SKIP_VECTORS_${ts_lc//-/_}"
		eval "skip=\$$skip_var_name"
		if [ "${skip}" != "" ]; then
			SKIP_ARG="-sv ${skip}"
		fi
		echo Running /usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec} ${SKIP_ARG} ${FLUSTER_ARGS}
		/usr/bin/fluster_parser.py -ts ${ts} -d ccdec-${codec} ${SKIP_ARG} ${FLUSTER_ARGS}
		rm -f results.xml
	done
done

