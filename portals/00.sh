# shellcheck disable=SC2148,SC2154

case "$1" in
  "predict")
    @match "$http_code" 204 || (
      @match "$origin_url" -P '^(http://|(?!.*://))' &&
      @match "$redirect_url" "^https://${origin_url#http://}" &&
      @match "$redirect_method" -i 'http_redirect_url' &&
      true  # just keep in the same style
    )
  ;;
  "login")
    # has been logged in
    # do nothing
  ;;
esac
