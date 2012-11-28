#!/bin/bash
# setup a FxOS device for dogfooding by assigning a unique ID
set -e

if [[ ! -n "$1" ]]; then
  echo "Error: This script requires a unique dogfood ID to assign to the device"
  echo "Usage: $0 <dogfood-id>"
  exit 1
fi

DOGFOOD_ID=$1
ADB=${ADB:-adb}
$ADB wait-for-device

# Store a property too, just in case this needs to be recovered later
$ADB shell setprop persist.moz.dogfood.id $DOGFOOD_ID

B2G_PREF_DIR=/system/b2g/defaults/pref
TMP_DIR=/tmp/dogfood-prefs
rm -rf $TMP_DIR
mkdir $TMP_DIR

cat >$TMP_DIR/dogfood_id.js <<DOGFOOD_ID
pref("distribution.id", "$DOGFOOD_ID");
pref("prerelease.dogfood.id", "$DOGFOOD_ID");
DOGFOOD_ID

cat >$TMP_DIR/dogfood_updates.js <<DOGFOOD_UPDATES
pref("app.update.channel", "stable");
# Uncomment next line if flashing a build pre-FOTA (11/14/2012)
# pref("app.update.url", "http://update.boot2gecko.org/%CHANNEL%/update.xml?build_id=%BUILD_ID%&version=%VERSION%&dogfood_id=%DISTRIBUTION%");
# Otherwise use update url below
pref("app.update.url", "http://update.boot2gecko.org/%CHANNEL%/%PRODUCT_MODEL%/%VERSION%/%BUILD_ID%/update.xml?build_id=%BUILD_ID%&version=%VERSION%&dogfood_id=%DISTRIBUTION%");
DOGFOOD_UPDATES

echo "$DOGFOOD_ID" >$TMP_DIR/dogfoodid

$ADB remount
$ADB push $TMP_DIR/dogfood_id.js $B2G_PREF_DIR/dogfood_id.js
$ADB push $TMP_DIR/dogfood_updates.js $B2G_PREF_DIR/dogfood_updates.js
$ADB push $TMP_DIR/dogfoodid /data/local/dogfoodid

$ADB shell "stop b2g; start b2g"
