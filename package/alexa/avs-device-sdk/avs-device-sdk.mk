################################################################################
#
# AVS DEVICE SDK - http://github.com/alexa/avs-device-sdk.git
#
################################################################################

# Sync from git server

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK),y)
AVS_DEVICE_SDK_VERSION = $(call qstrip,$(BR2_PACKAGE_AVS_DEVICE_SDK_VERSION))
AVS_DEVICE_SDK_VERSION = master
AVS_DEVICE_SDK_SITE = http://github.com/alexa/avs-device-sdk.git
AVS_DEVICE_SDK_SITE_METHOD = git

AVS_DEVICE_SDK_INSTALL_STAGING = YES
AVS_DEVICE_SDK_INSTALL_TARGET = NO
AVS_DEVICE_SDK_SUPPORTS_IN_SOURCE_BUILD = NO

define AVS_DEVICE_SDK_INSTALL_STAGING_CMDS
    cd ${BUILD_DIR}/avs-device-sdk-$(AVS_DEVICE_SDK_VERSION)/buildroot-build; \
    make install DESTDIR=$(STAGING_DIR)/
endef

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_CAPTIONS),y)
AVS_DEVICE_SDK_CONF_OPTS += \
    -DCAPTIONS=ON \
    -DLIBWEBVTT_LIB_PATH="$(STAGING_DIR)/usr/lib/libwebvtt.a" \
    -DLIBWEBVTT_INCLUDE_DIR="$(STAGING_DIR)/usr/include/webvtt"
AVS_DEVICE_SDK_DEPENDENCIES += alexa-webvtt
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_OPUS),y)
AVS_DEVICE_SDK_CONF_OPTS += -DOPUS=ON
AVS_DEVICE_SDK_DEPENDENCIES += opus
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_CMAKE_BUILD_TYPE_DEBUG),y)
AVS_DEVICE_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=DEBUG
    ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_ENABLE_ACSDK_EMIT_SENSITIVE_LOGS),y)
    AVS_DEVICE_SDK_CONF_OPTS += -DACSDK_EMIT_SENSITIVE_LOGS=ON
    endif
    #v1.19 support it
    ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_DIAGNOSTICS),y)
    AVS_DEVICE_SDK_CONF_OPTS += -DIAGNOSTICS=ON
        ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_AUDIO_INJECTION),y)
            AVS_DEVICE_SDK_CONF_OPTS += -DAUDIO_INJECTION=ON
        endif
        ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_DEVICE_PROPERTIES),y)
            AVS_DEVICE_SDK_CONF_OPTS += -DDEVICE_PROPERTIES=ON
        endif
        ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_PROTOCOL_TRACE),y)
            AVS_DEVICE_SDK_CONF_OPTS += -DPROTOCOL_TRACE=ON
        endif
    endif
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_CMAKE_BUILD_TYPE_RELEASE),y)
AVS_DEVICE_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=RELEASE
endif

#v1.17 support it
#Endpoints - Use the following CMake parameters to enable Smart Home endpoints in your build.
ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_DENABLE_ALL_ENDPOINT_CONTROLLERS),y)
AVS_DEVICE_SDK_CONF_OPTS += -DENABLE_ALL_ENDPOINT_CONTROLLERS=ON
    ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_TOGGLE_CAPABILITY),y)
    AVS_DEVICE_SDK_CONF_OPTS += -DENDPOINT_CONTROLLERS_TOGGLE_CAPABILITY=ON
    endif
    ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_MODE_CONTROLLER),y)
    AVS_DEVICE_SDK_CONF_OPTS += -DENDPOINT_CONTROLLERS_MODE_CONTROLLER=ON
    endif
    ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_RANGE_CONTROLLER),y)
    AVS_DEVICE_SDK_CONF_OPTS += -DENDPOINT_CONTROLLERS_RANGE_CONTROLLER=ON
    endif
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_METRICS),y)
AVS_DEVICE_SDK_CONF_OPTS += -DMETRICS=ON
endif

#v1.21.0 support it
ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_DISABLE_DUCKING),y)
AVS_DEVICE_SDK_CONF_OPTS += -DDISABLE_DUCKING=ON
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_LOW_POWER_MODE),y)
AVS_DEVICE_SDK_CONF_OPTS += -DLPM=ON
endif

AVS_DEVICE_SDK_CONF_OPTS += \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DLIBRARY_OUTPUT_PATH=$(TARGET_DIR)/usr/lib \
    -DEXECUTABLE_OUTPUT_PATH=$(TARGET_DIR)/usr/bin \
    -DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH="$(STAGING_DIR)/usr/lib/libportaudio.so" \
    -DPORTAUDIO_INCLUDE_DIR=$(STAGING_DIR)/include \
    -DMTK_EC_SUPPORT=1 \
    -DRAPIDJSON_MEM_OPTIMIZATION=OFF \
    ${BUILD_DIR}/avs-device-sdk-${AVS_DEVICE_SDK_VERSION}/avs-device-sdk

AVS_DEVICE_SDK_DEPENDENCIES += libcurl nghttp2 sqlite gst1-plugins-base gst1-plugins-ugly portaudio ntp

$(eval $(cmake-package))
endif
