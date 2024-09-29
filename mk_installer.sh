#!/usr/bin/env bash
set -euo pipefail
set -x

OUT="${PWD}"
SRC="$(dirname -- "${BASH_SOURCE[0]}")"

pushd -- "$SRC" > /dev/null
  FILES=(
    LICENSE
    README*.md
    drcom.sh
    portals/
  )

  {
  cat << EOF
#!/usr/bin/env bash
set -euo pipefail \\
    \${DEBUG:+-x}

_extract_archive() {
  base64 -d - << END
EOF

  # Embed the archive of the files to install
  tar -cz --no-same-owner -- "${FILES[@]}" | base64 -

  cat << EOF
END
}

case "\${1-}" in
  "extract_archive")
    _extract_archive
  ;;
  "install")
    rm -rf -- "\$INSTALL_DIR"
    mkdir -p -- "\$INSTALL_DIR"
    pushd -- "\$INSTALL_DIR"
      _extract_archive \
        | tar -xzo
    popd
  ;;
  *)
    printf 'Usage: %s %s\n' "\${BASH_SOURCE[0]}" \\
      "<install|extract_archive>"
  ;;
esac
exit 0
EOF
  } > "$OUT/installer.sh"
  chmod +x "$OUT/installer.sh"
popd > /dev/null
