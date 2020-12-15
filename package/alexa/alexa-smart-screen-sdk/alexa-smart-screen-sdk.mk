################################################################################
#
# ALEXA SMART SCREEN SDK - https://github.com/alexa/alexa-smart-screen-sdk
#
################################################################################

# Sync from git server

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK),y)
ALEXA_SMART_SCREEN_SDK_VERSION = $(call qstrip,$(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_VERSION))
ALEXA_SMART_SCREEN_SDK_SITE = https://github.com/alexa/alexa-smart-screen-sdk
ALEXA_SMART_SCREEN_SDK_SITE_METHOD = git

ALEXA_SMART_SCREEN_SDK_INSTALL_STAGING = YES
ALEXA_SMART_SCREEN_SDK_INSTALL_TARGET = YES
ALEXA_SMART_SCREEN_SDK_SUPPORTS_IN_SOURCE_BUILD = NO

define ALEXA_SMART_SCREEN_SDK_PRE_PATCH
    @if [ $(ALEXA_SMART_SCREEN_SDK_VERSION) == "master" ]; then \
        rm -rf $(TOPDIR)/package/mediatek/alexa/alexa-smart-screen-sdk/*.patch; \
    fi
endef

ALEXA_SMART_SCREEN_SDK_PRE_PATCH_HOOKS += ALEXA_SMART_SCREEN_SDK_PRE_PATCH

define ALEXA_SMART_SCREEN_SDK_BUILD_CMDS
    # wget https://github.com/zaphoyd/websocketpp/archive/0.8.1.tar.gz -O websocketpp-0.8.1.tar.gz
    tar xf $(TOPDIR)/dl/websocketpp-0.8.1.tar.gz -C $(STAGING_DIR)/usr/include/
    # https://sourceforge.net/projects/asio/files/asio/1.12.2%20%28Stable%29/asio-1.12.2.tar.gz/download
    tar xf $(TOPDIR)/dl/asio-1.12.2.tar.gz -C $(STAGING_DIR)/usr/include/
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/buildroot-build/ SampleApp
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/buildroot-build/ install
endef 

define ALEXA_SMART_SCREEN_SDK_INSTALL_STAGING_CMDS
    $(INSTALL) -D -m 0755 $(@D)/install/lib/*.so $(STAGING_DIR)/usr/lib
endef

define ALEXA_SMART_SCREEN_SDK_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/install/lib/*.so $(TARGET_DIR)/usr/lib
    $(INSTALL) -D -m 0755 $(@D)/buildroot-build/modules/Alexa/SampleApp/src/SampleApp $(TARGET_DIR)/usr/bin/SampleApp_SSCLNT
    mkdir -p $(TARGET_DIR)/etc/alexa/certificates/
    cp -rfp $(@D)/alexa-smart-screen-sdk-master/modules/GUI/config/certificates/ca.cert $(TARGET_DIR)/etc/alexa/certificates/
    cp -rfp $(@D)/alexa-smart-screen-sdk-master/modules/GUI/config/certificates/server.chain $(TARGET_DIR)/etc/alexa/certificates/
    cp -rfp $(@D)/alexa-smart-screen-sdk-master/modules/GUI/config/certificates/server.key $(TARGET_DIR)/etc/alexa/certificates/
    mkdir -p $(TARGET_DIR)/etc/alexa/webui
    @if [ $(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_DONGLE_EVENT_SUPPORT) == "y" ]; then \
        cp -rfp $(@D)/buildroot-build/modules/GUI_Dongle/output/* $(TARGET_DIR)/etc/alexa/webui/; \
    else \
        cp -rfp $(@D)/buildroot-build/modules/GUI/* $(TARGET_DIR)/etc/alexa/webui/ ;\
        cp -rf $(@D)/alexa-smart-screen-sdk-master/modules/GUI/avs-voicechrome/assets/* $(TARGET_DIR)/etc/alexa/webui/ ;\
        rm -rf $(TARGET_DIR)/etc/alexa/webui/CMakeFiles/ ;\
        rm -rf $(TARGET_DIR)/etc/alexa/webui/Makefile ;\
        rm -rf $(TARGET_DIR)/etc/alexa/webui/cmake_install.cmake ;\
    fi
endef

ALEXA_SMART_SCREEN_SDK_MAKE_ENV += \
    PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
    PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"

ifeq ($(BR2_PACKAGE_WWE_PRYONLITE),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += \
    -DAMAZONLITE_KEY_WORD_DETECTOR=ON \
    -DAMAZONLITE_KEY_WORD_DETECTOR_LIB_PATH="$(STAGING_DIR)/usr/lib/libpryon_lite-PRL2000.so" \
    -DAMAZONLITE_KEY_WORD_DETECTOR_INCLUDE_DIR="$(STAGING_DIR)/include/pryonlite"
endif

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_CAPTIONS),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += \
    -DCAPTIONS=ON \
    -DLIBWEBVTT_LIB_PATH="$(STAGING_DIR)/usr/lib/libwebvtt.a" \
    -DLIBWEBVTT_INCLUDE_DIR="$(STAGING_DIR)/usr/include/webvtt"
ALEXA_SMART_SCREEN_SDK_DEPENDENCIES += alexa-webvtt
endif

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_OPUS),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DOPUS=ON
ALEXA_SMART_SCREEN_SDK_DEPENDENCIES += opus
endif

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_CMAKE_BUILD_TYPE_DEBUG),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=DEBUG -DDISABLE_WEBSOCKET_SSL=ON
endif

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_CMAKE_BUILD_TYPE_RELEASE),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=RELEASE -DDISABLE_WEBSOCKET_SSL=OFF
endif

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_DONGLE_EVENT_SUPPORT),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DDONGLE_EVENT_SUPPORT=1
endif

ALEXA_SMART_SCREEN_SDK_CONF_OPTS += \
    -DCMAKE_INSTALL_PREFIX=$(@D)/install \
    -DAPL_CORE=ON \
    -DAPLCORE_INCLUDE_DIR="$(STAGING_DIR)/usr/include/" \
    -DAPLCORE_LIB_DIR="$(STAGING_DIR)/usr/lib/" \
    -DAPLCORE_RAPIDJSON_INCLUDE_DIR="$(STAGING_DIR)/usr/include/" \
    -DYOGA_INCLUDE_DIR="$(STAGING_DIR)/usr/include/" \
    -DYOGA_LIB_DIR="$(STAGING_DIR)/usr/lib/" \
    -DASIO_INCLUDE_DIR=$(STAGING_DIR)/usr/include/asio-1.12.2/include/ \
    -DWEBSOCKETPP_INCLUDE_DIR=$(STAGING_DIR)/usr/include/websocketpp-0.8.1/ \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH="$(STAGING_DIR)/usr/lib/libportaudio.so" \
    -DPORTAUDIO_INCLUDE_DIR=$(STAGING_DIR)/include \
    -DMTK_EC_SUPPORT=1 \
    -DALSA_LIB_PATH=$(STAGING_DIR)/usr/lib/ \
    -DALSA_INC_PATH=$(STAGING_DIR)/usr/include/ \
    $(@D)/alexa-smart-screen-sdk-master

#Debug
#-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \

ALEXA_SMART_SCREEN_SDK_DEPENDENCIES = avs-device-sdk apl-core-library

$(eval $(cmake-package))
endif
