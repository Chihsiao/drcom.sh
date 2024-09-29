#!/usr/bin/env bash
# shellcheck disable=SC2034

set -euo pipefail \
    ${DEBUG:+-x}

_reversed() {
  sed '1!G;h;$!d'
}

@match() {
  printf '%s\n' "${1:?str}" \
    | grep -q "${@:2}" || return $?
}

_url_sp() {
  printf '%s\n' "${2-$redirect_url}" \
    | sed -E "s|.*[\?&]${1:?search param}\s*=\s*([^&]+)\b.*|\1|"
}

_response_meta() {
  printf '%s\n' "${2-$__drcom_response}" | _reversed | awk "
    /^=>response_body$/ { exit };

    /^${1:?key}=/ {
      sub(\"^$1=\", \"\");
      print;
      exit;
    };

    /^$1<=$/ { e=1 } 
    /^=>$1$/ { s=1 } {
      if (e) exit;
      if (s) {
        if (m) print;
          else m = 1;
      }
    }
  " | _reversed
}

_request() {
  : "${DRCOM_COOKIE:=$HOME/.drcom_cookie}"
  curl -s -b "$DRCOM_COOKIE" -c "$DRCOM_COOKIE" ${DEBUG:+-v} "$@"
}

_detect_redirect() {
  origin_url="${1:-1.1.1.1}"

  __drcom_response=$(_request -w '\n=>response_body
http_headers<=\n%{header_json}\n=>http_headers
http_redirect_url=%{redirect_url}
http_code=%{http_code}
json=%{json}
' \
-- "$origin_url" || true)

  response_body=$(printf '%s\n' "$__drcom_response" \
    | _reversed | sed -n '/^=>response_body$/,$p' | sed '1d' | _reversed)

  redirect_method='UNSET'
  redirect_url='UNSET'

  local url_srcs=(
    http_redirect_url
    html_meta_refresh_url
    html_script_location_href
  )

  http_code=$(_response_meta http_code)
  http_headers=$(_response_meta http_headers)
  http_redirect_url=$(_response_meta http_redirect_url)

  html_meta_refresh_url=$(printf '%s\n' "$response_body" \
    | (grep -E '<meta\b' || true) | (grep -E "\bhttp-equiv=(['\"])refresh\1" || true) \
    | (sed -nE -e "s|.*?\bcontent=(['\"])(.*?)\1.*|\2|g" -e 's|^\s*[0-9]+\s*;\s*url=(.*)|\1|g;p'))

  html_script_location_href=$(printf '%s\n' "$response_body" \
    | (sed -nE " /.*\blocation\.href\s*=/ { s|.*\blocation\.href\s*=\s*(['\"])(.*?)\1.*|\2|; p; q }"))

  local UNKNOWN=
  for redirect_method in "${url_srcs[@]}" UNKNOWN; do
    [ -n "${!redirect_method}" ] || continue
    redirect_url="${!redirect_method}"
    break
  done
}

_predict_captive_portal() {
  # shellcheck disable=SC1090,SC2015
  for portal in "$DRCOM_PORTALS_FOLDER"/*.sh; do
    (source "$portal" predict) && break || true
  done
}

: "${DRCOM_PORTALS_FOLDER:=$(dirname "$0")/portals}"
: "${DRCOM_TEST_ENDPOINT:=1.1.1.1}"

# shellcheck disable=SC1090
. "${1:?config}"

case "${2:-}" in
  "try_to_login")
    : "${DRCOM_USER:?user}"
    : "${DRCOM_PASS:?password}"

    _detect_redirect "$DRCOM_TEST_ENDPOINT"
    _predict_captive_portal

    # shellcheck disable=SC1090
    (source "$portal" login) || exit $?
  ;;

  "status")
    _detect_redirect "$DRCOM_TEST_ENDPOINT"
    _predict_captive_portal

    printf 'Endpoint: %s (http_code=%d)\n' "$origin_url" "$http_code"
    printf 'Redirect method: %s\n' "$redirect_method"
    printf 'Redirect url: %s\n' "$redirect_url"

    printf 'Portal type: %s\n' "$(basename "$portal" '.sh')"
  ;;

  *)
    printf 1>&2 'Usage: %s %s %s\n' \
        "$0" "$1" '<try_to_login|status>'
    exit 1
  ;;
esac
