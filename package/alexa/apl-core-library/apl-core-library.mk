################################################################################
#
# APL CORE library - https://github.com/alexa/apl-core-library
#
################################################################################

# Sync from git server

ifeq ($(BR2_PACKAGE_APL_CORE_LIBRARY),y)
APL_CORE_LIBRARY_VERSION = $(call qstrip,$(BR2_PACKAGE_APL_CORE_LIBRARY_VERSION))
APL_CORE_LIBRARY_SITE = https://github.com/alexa/apl-core-library
APL_CORE_LIBRARY_SITE_METHOD = git

APL_CORE_LIBRARY_INSTALL_STAGING = YES
APL_CORE_LIBRARY_INSTALL_TARGET = NO
APL_CORE_LIBRARY_SUPPORTS_IN_SOURCE_BUILD = NO

define APL_CORE_LIBRARY_INSTALL_STAGING_CMDS
    $(INSTALL) -D -m 0755 $(@D)/buildroot-build/aplcore/libapl.a $(STAGING_DIR)/usr/lib/
    $(INSTALL) -D -m 0755 $(@D)/buildroot-build/lib/libyogacore.a $(STAGING_DIR)/usr/lib/
    cp -rf $(@D)/apl-core-library/aplcore/include/* $(STAGING_DIR)/usr/include/
    cp -rf $(@D)/buildroot-build/yoga-prefix/src/yoga/* $(STAGING_DIR)/usr/include/
    cp -rf $(@D)/buildroot-build/rapidjson-prefix $(STAGING_DIR)/usr/include/
endef

#define APL_CORE_LIBRARY_INSTALL_TARGET_CMDS
#    cd ${BUILD_DIR}/apl-core-library-master/buildroot-build; \
#    make install DESTDIR=$(TARGET_DIR)/usr/
#endef

APL_CORE_LIBRARY_CONF_OPTS += \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DBUILD_TESTS=ON \
    -DCOVERAGE=OFF \
    -DBUILD_STATIC_LIBS=ON \
    $(@D)/apl-core-library

$(eval $(cmake-package))
endif
