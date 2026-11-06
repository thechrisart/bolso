#!/bin/bash
# Copia o site para ios/Bolso/www e troca as bibliotecas de CDN por cópias locais,
# nas mesmas versões, para o app abrir sem depender desses servidores.
set -euo pipefail
ios="$(cd "$(dirname "$0")/.." && pwd)"
repo="$(dirname "$ios")"
www="$ios/Bolso/www"
cache="$ios/.cache"

rm -rf "$www"
mkdir -p "$www/vendor" "$cache"
cp "$repo/index.html" "$repo/config.js" "$repo/i18n.js" "$repo/icon.svg" "$repo/manifest.json" \
   "$repo/icon-192.png" "$repo/icon-512.png" "$repo/apple-touch-icon.png" "$www/"

urls="$(grep -oE 'https://(cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com)/[^"'"'"' ]+\.js' "$repo/index.html" | sort -u)"
[ -n "$urls" ] || { echo "Nenhuma biblioteca de CDN encontrada em index.html" >&2; exit 1; }
for url in $urls; do
  name="$(basename "$url")"
  cached="$cache/$(printf '%s' "$url" | shasum -a 256 | cut -c1-16)-$name"
  [ -s "$cached" ] || curl -fsSL "$url" -o "$cached"
  cp "$cached" "$www/vendor/$name"
  URL="$url" NAME="vendor/$name" perl -i -pe 's/\Q$ENV{URL}\E/$ENV{NAME}/g' "$www/index.html"
done

if grep -qE 'cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com' "$www/index.html"; then
  echo "Ainda há referências a CDN em www/index.html" >&2
  exit 1
fi
