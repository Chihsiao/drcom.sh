# shellcheck disable=SC2148,SC2154

case "$1" in
  "predict")
    printf 1>&2 '[!] Unknown portal: %d;%s;%s\n' \
        "$http_code" "$redirect_method" "$redirect_url"
  ;;
  "login")
    return 1;
  ;;
esac
