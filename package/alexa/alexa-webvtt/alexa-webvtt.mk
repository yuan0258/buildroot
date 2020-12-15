################################################################################
#
# ALEXA_WEBVTT - https://github.com/alexa/webvtt.git
#
################################################################################

# Sync from git server

ifeq ($(BR2_PACKAGE_ALEXA_WEBVTT),y)
ALEXA_WEBVTT_VERSION = $(call qstrip,$(BR2_PACKAGE_ALEXA_WEBVTT_VERSION))
ALEXA_WEBVTT_VERSION = master
ALEXA_WEBVTT_SITE = https://github.com/alexa/webvtt
ALEXA_WEBVTT_SITE_METHOD = git


ALEXA_WEBVTT_INSTALL_STAGING = YES
ALEXA_WEBVTT_INSTALL_TARGET = NO
ALEXA_WEBVTT_SUPPORTS_IN_SOURCE_BUILD = NO


define ALEXA_WEBVTT_INSTALL_STAGING_CMDS
    mkdir -p $(STAGING_DIR)/usr/lib/
    cp $(@D)/buildroot-build/src/webvttxx/libwebvttxx.a $(STAGING_DIR)/usr/lib/
    cp $(@D)/buildroot-build/src/webvtt/libwebvtt.a $(STAGING_DIR)/usr/lib/
    mkdir -p $(STAGING_DIR)/usr/include/webvtt
    cp -rf $(@D)/include/* $(STAGING_DIR)/usr/include/webvtt
endef


ALEXA_WEBVTT_CONF_OPTS += \
    ${BUILD_DIR}/alexa-webvtt-$(ALEXA_WEBVTT_VERSION)


$(eval $(cmake-package))
endif
