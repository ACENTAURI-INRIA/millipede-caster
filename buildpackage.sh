#! /usr/bin/bash
set -x
PACKAGE="millipede-caster"
VERSION=`dpkg-parsechangelog --show-field Version`
ARCH=`dpkg-architecture -qDEB_TARGET_ARCH`
dpkg-buildpackage -us -uc -b \
    --buildinfo-file=package/${PACKAGE}_${VERSION}_$ARCH.buildinfo \
    --buildinfo-option="-upackage" \
    --changes-file=package/${PACKAGE}_${VERSION}_$ARCH.changes \
    --changes-option="-upackage"
