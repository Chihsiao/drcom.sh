# shellcheck disable=SC2148,SC2154

case "$1" in
  "predict")
    @match "$(_response_header server)" -F 'DrcomServer1.0' &&
    true  # just keep in the same style
  ;;
  "login")
    _request "$redirect_url" -d '0MKKey=123' \
      -d 'DDDDD='"$DRCOM_USER" \
      -d 'upass='"$DRCOM_PASS" \
      -o /dev/null
  ;;
esac
