#!/bin/bash
# Creates a local self-signed codesigning identity if none exists.
# The private key stays in a dedicated keychain — never commit it.
set -euo pipefail

IDENTITY="Exif Stamp Self-Signed"
KEYCHAIN="$HOME/Library/Keychains/exif-stamp-codesign.keychain-db"
KC_PASS="exif-stamp-codesign"

unlock() {
  security unlock-keychain -p "$KC_PASS" "$KEYCHAIN"
}

hash_of_identity() {
  security find-identity -p codesigning "$KEYCHAIN" 2>/dev/null \
    | awk -v name="$IDENTITY" '$0 ~ name { print $2; exit }'
}

if [[ -f "$KEYCHAIN" ]]; then
  unlock
  existing=$(hash_of_identity)
  if [[ -n "$existing" ]]; then
    echo "$existing"
    exit 0
  fi
fi

if [[ ! -f "$KEYCHAIN" ]]; then
  security create-keychain -p "$KC_PASS" "$KEYCHAIN"
fi
security set-keychain-settings -lut 21600 "$KEYCHAIN"
unlock

existing_list=$(security list-keychains -d user | sed 's/"//g')
# shellcheck disable=SC2086
security list-keychains -d user -s "$KEYCHAIN" $existing_list

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
  -keyout "$tmp/key.pem" -out "$tmp/cert.pem" \
  -subj "/CN=${IDENTITY}/O=laboef1900" \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "keyUsage=critical,digitalSignature" \
  -addext "extendedKeyUsage=critical,codeSigning"

openssl pkcs12 -export -legacy \
  -inkey "$tmp/key.pem" -in "$tmp/cert.pem" \
  -out "$tmp/cert.p12" -name "$IDENTITY" \
  -passout pass:"$KC_PASS"

security import "$tmp/cert.p12" -k "$KEYCHAIN" -P "$KC_PASS" \
  -T /usr/bin/codesign -T /usr/bin/security >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: -s \
  -k "$KC_PASS" "$KEYCHAIN" >/dev/null
security add-trusted-cert -d -r unspecified -p codeSign \
  -k "$KEYCHAIN" "$tmp/cert.pem" >/dev/null || true

hash=$(hash_of_identity)
if [[ -z "$hash" ]]; then
  echo "failed to create codesigning identity" >&2
  exit 1
fi
echo "$hash"
