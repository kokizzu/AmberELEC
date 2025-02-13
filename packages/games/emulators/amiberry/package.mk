# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry"
PKG_VERSION="b6a4562fe4e60c9ec5f23aa8565cdb28cfba812e"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/BlitterStudio/amiberry"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain linux glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123 libpng libmpeg2 libserialport"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_BRANCH="master"

pre_configure_target() {
  cd ${PKG_BUILD}

  if [[ "${DEVICE}" =~ RG351 ]]
  then
    AMIBERRY_PLATFORM="PLATFORM=RK3326"
  elif [[ "${DEVICE}" == RG552 ]]
  then
    AMIBERRY_PLATFORM="PLATFORM=RK3399"
  fi

  sed -i 's/\-O[23]//' Makefile
  PKG_MAKE_OPTS_TARGET+="${AMIBERRY_PLATFORM} all SDL_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"
}

makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/amiberry

  # Copy ressources
  cp -ra ${PKG_DIR}/config/* ${INSTALL}/usr/config/amiberry/
  cp -a data ${INSTALL}/usr/config/amiberry/
  cp -a savestates ${INSTALL}/usr/config/amiberry/
  cp -a screenshots ${INSTALL}/usr/config/amiberry/
  cp -a whdboot ${INSTALL}/usr/config/amiberry/
  ln -s /storage/roms/bios ${INSTALL}/usr/config/amiberry/kickstarts

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry
  cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  ln -sf /usr/lib/libcapsimage.so.5.1 ${INSTALL}/usr/config/amiberry/capsimg.so
  
  UAE="${INSTALL}/usr/config/amiberry/conf/*.uae"
  for i in ${UAE}; do echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> ${i}; done
}
