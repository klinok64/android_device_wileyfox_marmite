# Root init scripts
PRODUCT_PACKAGES += \
    init.marmite.usb.sh \
    init.recovery.qcom.rc

# /vendor/
PRODUCT_PACKAGES += \
    ueventd.rc

# /vendor/bin
PRODUCT_PACKAGES += \
    init.class_main.sh \
    init.crda.sh \
    init.mdm.sh \
    init.qcom.class_core.sh \
    init.qcom.coex.sh \
    init.qcom.crashdata.sh \
    init.qcom.early_boot.sh \
    init.qcom.efs.sync.sh \
    init.qcom.post_boot.sh \
    init.qcom.sdio.sh \
    init.qcom.sensors.sh \
    init.qcom.sh \
    init.qcom.syspart_fixup.sh \
    init.qcom.usb.sh \
    init.qcom.wifi.sh \
    init.qti.fm.sh \
    init.qti.ims.sh

# /vendor/etc/
PRODUCT_PACKAGES += \
    fstab.qcom

# /vendor/etc/init/hw
PRODUCT_PACKAGES += \
    init.msm.usb.configfs.rc \
    init.qcom.factory.rc \
    init.qcom.rc \
    init.qcom.usb.rc \
    init.target.rc \

# Device varinats
PRODUCT_PACKAGES += \
    init.variant.mv1.rc \
    init.variant.mv2.rc \
    init.variant.mv3.rc

# OTA
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/releasetools/fixup.sh:install/bin/fixup.sh
