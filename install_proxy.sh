#!/bin/bash

PROXY_FUNCTION='
# Proxy control
function proxy() {
    local CONFIG_FILE="$HOME/.proxy_config"

    # Load config if present
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi

    # Defaults
    PROXY_HTTP=${PROXY_HTTP:-"http://127.0.0.1:20170"}
    PROXY_HTTPS=${PROXY_HTTPS:-"$PROXY_HTTP"}
    NO_PROXY_LIST=${NO_PROXY_LIST:-""}

    save_config() {
        cat > "$CONFIG_FILE" <<EOF
PROXY_HTTP="$PROXY_HTTP"
PROXY_HTTPS="$PROXY_HTTPS"
NO_PROXY_LIST="$NO_PROXY_LIST"
EOF
    }

    apply_on() {
        export http_proxy="$PROXY_HTTP"
        export https_proxy="$PROXY_HTTPS"
        export HTTP_PROXY="$PROXY_HTTP"
        export HTTPS_PROXY="$PROXY_HTTPS"
        if [ -n "$NO_PROXY_LIST" ]; then
            export NO_PROXY="$NO_PROXY_LIST"
            export no_proxy="$NO_PROXY_LIST"
        else
            unset NO_PROXY no_proxy
        fi
        echo "[proxy] Proxy is ON"
    }

    apply_off() {
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY no_proxy
        echo "[proxy] Proxy is OFF"
    }

    is_on() {
        [ -n "$http_proxy" ] || [ -n "$HTTP_PROXY" ]
    }

    # NO_PROXY helpers
    _np_contains() {
        local list="$1" item="$2"
        IFS=',' read -ra _arr <<< "$list"
        for _e in "${_arr[@]}"; do
            local t="${_e//[[:space:]]/}"
            [ -z "$t" ] && continue
            [ "$t" = "$item" ] && return 0
        done
        return 1
    }

    _np_add() {
        local list="$1" item="$2"
        [ -z "$item" ] && { echo "$list"; return; }
        if [ -z "$list" ]; then
            echo "$item"; return
        fi
        _np_contains "$list" "$item" && { echo "$list"; return; }
        echo "$list,$item"
    }

    _np_remove() {
        local list="$1" item="$2" out=""
        IFS=',' read -ra _arr <<< "$list"
        for _e in "${_arr[@]}"; do
            local t="${_e//[[:space:]]/}"
            [ -z "$t" ] && continue
            [ "$t" = "$item" ] && continue
            if [ -z "$out" ] && [ -n "$t" ]; then out="$t"; elif [ -n "$t" ]; then out="$out,$t"; fi
        done
        echo "$out"
    }

    print_usage() {
        echo "Usage:"
        echo "  proxy on | off | list"
        echo "  proxy set <url>"
        echo "  proxy set http <url> [https <url>] [no_proxy <list>]"
        echo "  proxy config show"
        echo "  proxy config set http <url>"
        echo "  proxy config set https <url>"
        echo "  proxy config set both <url>"
        echo "  proxy config set no_proxy <list>"
        echo "  proxy config add no_proxy <item>"
        echo "  proxy config rm  no_proxy <item>"
        echo "  proxy config reset"
    }

    case "$1" in
        on)
            apply_on
            ;;
        off)
            apply_off
            ;;
        list|-l|status)
            echo "[proxy] Current proxy configuration:"
            echo "  PROXY_HTTP=$PROXY_HTTP"
            echo "  PROXY_HTTPS=$PROXY_HTTPS"
            echo "  NO_PROXY_LIST=${NO_PROXY_LIST:-<unset>}"
            echo "  Env:"
            echo "    http_proxy=${http_proxy:-<unset>}"
            echo "    https_proxy=${https_proxy:-<unset>}"
            echo "    HTTP_PROXY=${HTTP_PROXY:-<unset>}"
            echo "    HTTPS_PROXY=${HTTPS_PROXY:-<unset>}"
            echo "    NO_PROXY=${NO_PROXY:-<unset>}"
            ;;
        set)
            shift
            if [ $# -eq 0 ]; then
                echo "Usage:"
                echo "  proxy set <url>"
                echo "  proxy set http <url> [https <url>] [no_proxy <list>]"
                return 1
            fi
            if [ $# -eq 1 ]; then
                PROXY_HTTP="$1"
                PROXY_HTTPS="$1"
            else
                while [ $# -gt 0 ]; do
                    case "$1" in
                        http)
                            [ -n "$2" ] || { echo "missing value for http"; return 1; }
                            PROXY_HTTP="$2"; shift 2;;
                        https)
                            [ -n "$2" ] || { echo "missing value for https"; return 1; }
                            PROXY_HTTPS="$2"; shift 2;;
                        no_proxy|NO_PROXY)
                            [ -n "$2" ] || { echo "missing value for no_proxy"; return 1; }
                            NO_PROXY_LIST="$2"; shift 2;;
                        *)
                            echo "Unknown option: $1"; return 1;;
                    esac
                done
            fi
            save_config
            if is_on; then apply_on; else echo "[proxy] Saved. Use: proxy on"; fi
            ;;
        config)
            shift
            sub="$1"; [ -z "$sub" ] && { print_usage; return 1; }
            case "$sub" in
                show)
                    proxy list
                    ;;
                set)
                    case "$2" in
                        http)
                            [ -n "$3" ] || { echo "missing http url"; return 1; }
                            PROXY_HTTP="$3"
                            ;;
                        https)
                            [ -n "$3" ] || { echo "missing https url"; return 1; }
                            PROXY_HTTPS="$3"
                            ;;
                        both)
                            [ -n "$3" ] || { echo "missing url"; return 1; }
                            PROXY_HTTP="$3"; PROXY_HTTPS="$3"
                            ;;
                        no_proxy|NO_PROXY)
                            [ -n "$3" ] || { echo "missing no_proxy list"; return 1; }
                            NO_PROXY_LIST="$3"
                            ;;
                        *)
                            echo "Unknown config key: $2"; print_usage; return 1;;
                    esac
                    save_config
                    if is_on; then apply_on; fi
                    echo "[proxy] Config saved."
                    ;;
                add)
                    [ "$2" = "no_proxy" ] || { echo "Only no_proxy can be added"; return 1; }
                    [ -n "$3" ] || { echo "missing item"; return 1; }
                    NO_PROXY_LIST="$(_np_add "$NO_PROXY_LIST" "$3")"
                    save_config
                    if is_on; then apply_on; fi
                    echo "[proxy] NO_PROXY_LIST=$NO_PROXY_LIST"
                    ;;
                rm|remove|del)
                    [ "$2" = "no_proxy" ] || { echo "Only no_proxy can be removed"; return 1; }
                    [ -n "$3" ] || { echo "missing item"; return 1; }
                    NO_PROXY_LIST="$(_np_remove "$NO_PROXY_LIST" "$3")"
                    save_config
                    if is_on; then apply_on; fi
                    echo "[proxy] NO_PROXY_LIST=$NO_PROXY_LIST"
                    ;;
                reset)
                    PROXY_HTTP="http://127.0.0.1:20170"
                    PROXY_HTTPS="$PROXY_HTTP"
                    NO_PROXY_LIST=""
                    save_config
                    if is_on; then apply_on; fi
                    echo "[proxy] Config reset."
                    ;;
                *)
                    print_usage; return 1;;
            esac
            ;;
        *)
            if is_on; then
                echo "[proxy] Status: ON (${http_proxy:-$HTTP_PROXY})"
            else
                echo "[proxy] Status: OFF"
            fi
            print_usage
            ;;
    esac
}'

# Append function to ~/.bashrc if not present
if grep -qE '(^|[[:space:]])proxy\(\)' ~/.bashrc; then
    echo "proxy function already exists in ~/.bashrc"
else
    echo "$PROXY_FUNCTION" >> ~/.bashrc
    echo "proxy function added to ~/.bashrc"
    echo "Please run 'source ~/.bashrc' to activate it"
fi
