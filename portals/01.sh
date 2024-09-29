# shellcheck disable=SC2148,SC2154

case "$1" in
  "predict")
    @match "$redirect_url" -E '^http://210\.45\.240\.105/?' &&
    true  # just keep in the same style
  ;;
  "login")
    ___post_url=$(printf '%s\n' "$redirect_url" \
        | sed -E 's@^([^:]+)://([^:/]+)(:\d+)?($|/.*)@\1://\2:801/eportal/@')
    _request -G "$___post_url" -d 'c=Portal' -d 'a=login' -d 'callback=nop' -d 'login_method=1' \
        -d "wlan_user_ip=$(_url_sp wlanuserip)" -d "wlan_user_mac=$(_url_sp wlanusermac | sed 's/-//g')" -d "wlan_ac_name=$(_url_sp wlanacname)" \
        -d 'user_account='"$DRCOM_USER" -d 'user_password='"$DRCOM_PASS" \
        -o /dev/null
  ;;
esac
