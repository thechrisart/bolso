#!/bin/bash
# Gera dist/Bolso-sem-assinatura.ipa e, se TEAM_ID estiver definido, também dist/Bolso.ipa assinado.
#   ios/scripts/build-ipa.sh
#   TEAM_ID=XXXXXXXXXX EXPORT_METHOD=debugging ios/scripts/build-ipa.sh
set -euo pipefail
ios="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ios"
"$ios/scripts/sync-web.sh"
xcodegen generate --quiet
rm -rf build/ipa dist
mkdir -p build/ipa dist

xcodebuild -project Bolso.xcodeproj -scheme Bolso -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath build/dd-device CODE_SIGNING_ALLOWED=NO build -quiet
mkdir -p build/ipa/unsigned/Payload
cp -R build/dd-device/Build/Products/Release-iphoneos/Bolso.app build/ipa/unsigned/Payload/
(cd build/ipa/unsigned && zip -qry "$ios/dist/Bolso-sem-assinatura.ipa" Payload)
echo "OK dist/Bolso-sem-assinatura.ipa"

if [ -n "${TEAM_ID:-}" ]; then
  xcodebuild -project Bolso.xcodeproj -scheme Bolso -configuration Release -destination 'generic/platform=iOS' \
    -archivePath build/ipa/Bolso.xcarchive -allowProvisioningUpdates DEVELOPMENT_TEAM="$TEAM_ID" archive -quiet
  cat > build/ipa/export.plist <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>${EXPORT_METHOD:-debugging}</string>
<key>teamID</key><string>$TEAM_ID</string>
<key>signingStyle</key><string>automatic</string>
</dict></plist>
P
  xcodebuild -exportArchive -archivePath build/ipa/Bolso.xcarchive -exportOptionsPlist build/ipa/export.plist \
    -exportPath build/ipa/export -allowProvisioningUpdates -quiet
  cp build/ipa/export/Bolso.ipa dist/Bolso.ipa
  echo "OK dist/Bolso.ipa"
fi
