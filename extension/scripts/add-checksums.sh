#!/bin/sh
# Copyright 2022 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: Apache-2.0

set -e

VERSION=$1

echo "# $VERSION"

for locale in en de fr es pt vi
do
    docker run -e OFFEN_APP_LOCALE=${locale} -d -p 9999:9999 --rm --name offen_checksum offen/offen:$VERSION demo -users 0 -port 9999 > /dev/null 2>&1
    while [ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9999/script.js)" != "200" ]; do
      sleep 2
    done
    ./scripts/get-checksums.js http://localhost:9999 | ./scripts/merge.js ./checksums.json "$VERSION"
    docker stop offen_checksum > /dev/null 2>&1
done
