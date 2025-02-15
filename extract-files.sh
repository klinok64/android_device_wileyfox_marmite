#!/bin/bash
#
# Copyright (C) 2017-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0

set -e

DEVICE=marmite
VENDOR=wileyfox

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        lib64/libwfdnative.so)
            "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
            ;;
        system_ext/etc/init/dpmd.rc)
            sed -i "s|/system/product/bin/|/system/system_ext/bin/|g" "${2}"
            ;;
        system_ext/etc/permissions/com.qti.dpmframework.xml | system_ext/etc/permissions/dpmapi.xml)
            sed -i "s|/system/product/framework/|/system/system_ext/framework/|g" "${2}"
            ;;
        system_ext/etc/permissions/qti_libpermissions.xml)
            sed -i 's|name=\"android.hidl.manager-V1.0-java|name=\"android.hidl.manager@1.0-java|g' "${2}"
            ;;
        system_ext/etc/permissions/qcrilhook.xml)
            sed -i 's|/product/framework/qcrilhook.jar|/system/system_ext/framework/qcrilhook.jar|g' "${2}"
            ;;
       system_ext/lib64/lib-imsvideocodec.so)
            "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;
        system_ext/lib64/libdpmframework.so)
            "${PATCHELF}" --add-needed "libshim_dpmframework.so" "${2}"
            ;;
        vendor/bin/mm-qcamera-daemon)
            sed -i "s|/data/vendor/camera/cam_socket%d|/data/vendor/qcam/cam_socket%d\x0\x0|g" "${2}"
            ;;
        vendor/lib/libmmcamera2_cpp_module.so)
            ;&
        vendor/lib/libmmcamera2_dcrf.so)
            ;&
        vendor/lib/libmmcamera2_iface_modules.so)
            ;&
        vendor/lib/libmmcamera2_imglib_modules.so)
            ;&
        vendor/lib/libmmcamera2_mct.so)
            ;&
        vendor/lib/libmmcamera2_pproc_modules.so)
            ;&
        vendor/lib/libmmcamera2_q3a_core.so)
            ;&
        vendor/lib/libmmcamera2_stats_algorithm.so)
            ;&
        vendor/lib/libmmcamera2_stats_modules.so)
            ;&
        vendor/lib/libmmcamera_imglib.so)
            ;&
        vendor/lib/libmmcamera_pdaf.so)
            ;&
        vendor/lib/libmmcamera_pdafcamif.so)
            ;&
        vendor/lib/libmmcamera_tintless_algo.so)
            ;&
        vendor/lib/libmmcamera_tintless_bg_pca_algo.so)
            ;&
        vendor/lib/libmmcamera_tuning.so)
            ;&
        vendor/lib64/libmmcamera2_q3a_core.so)
            ;&
        vendor/lib64/libmmcamera2_stats_algorithm.so)
            ;&
        vendor/lib64/libmmcamera_tintless_algo.so)
            ;&
        vendor/lib64/libmmcamera_tintless_bg_pca_algo.so)
            sed -i 's|/data/misc/camera|/data/vendor/qcam|g' "${2}"
            ;;
        vendor/lib/libmmcamera2_sensor_modules.so)
            sed -i 's|/system/etc/camera|/vendor/etc/camera|g' "${2}"
            sed -i 's|/data/misc/camera|/data/vendor/qcam|g' "${2}"
            ;;
        vendor/lib/libmmcamera_dbg.so)
            ;&
        vendor/lib64/libmmcamera_dbg.so)
            sed -i 's|persist.camera.debug.logfile|persist.vendor.camera.dbglog|g' "${2}"
            sed -i 's|/data/misc/camera|/data/vendor/qcam|g' "${2}"
            ;;
        vendor/lib64/libsettings.so)
            "${PATCHELF}" --replace-needed "libprotobuf-cpp-full.so" "libprotobuf-cpp-full-v29.so" "${2}"
            ;;
        vendor/lib64/libwvhidl.so)
            "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
        vendor/lib64/hw/gatekeeper.msm8937.so)
            "${PATCHELF}" --set-soname gatekeeper.msm8937.so "${2}"
            ;;
        vendor/lib64/hw/keystore.msm8937.so)
            "${PATCHELF}" --set-soname keystore.msm8937.so "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files-qc.txt" "${SRC}" "${KANG}" --section "${SECTION}"
extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

DEVICE_BLOB_ROOT="$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

for HIDL_BASE_LIB in $(grep -lr "android\.hidl\.base@1\.0\.so" $DEVICE_BLOB_ROOT); do
    "${PATCHELF}" --remove-needed android.hidl.base@1.0.so "$HIDL_BASE_LIB" || true
done

for HIDL_MANAGER_LIB in $(grep -lr "android\.hidl\.@1\.0\.so" $DEVICE_BLOB_ROOT); do
    "${PATCHELF}" --remove-needed android.hidl.manager@1.0.so "$HIDL_MANAGER_LIB" || true
done

"${MY_DIR}/setup-makefiles.sh"
