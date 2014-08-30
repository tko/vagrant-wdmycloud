#!/bin/sh
set -e

zipfile="$1"

if [ ! -e "$zipfile" ]; then
    cat << EOF
Usage: ${0#*/} gpl-source.zip

EOF
    exit 1
fi

unzip -p "${zipfile}" \
    packages/build_tools/debian/binutils/binutils-armhf-64k.tar.gz \
    | tar xvzf - -C pbuilder-hooks/
