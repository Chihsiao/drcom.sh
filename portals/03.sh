# shellcheck disable=SC2148,SC2154

case "$1" in
  "predict")
    @match "$redirect_method" -i 'html_meta_refresh_url' &&
    ! @match "$(_url_sp arubalp)" "$(_url_sp arubalp "$origin_url")" &&
    @match "$(_url_sp cmd)" "redirect" &&
    true # just keep in the same style
  ;;
  "login")
    _detect_redirect "$redirect_url"
    _predict_captive_portal

    # shellcheck disable=SC1090
    source "$portal" login || return $?
  ;;
esac
