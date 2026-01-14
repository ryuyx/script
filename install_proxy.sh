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
            if [ -n "$http_proxy" ] || [ -n "$HTTP_PROXY" ]; then
                apply_on
            else
                echo "[proxy] Saved. Use: proxy on"
            fi
            ;;
        edit)
            "${EDITOR:-vi}" "$CONFIG_FILE"
            if [ -f "$CONFIG_FILE" ]; then . "$CONFIG_FILE"; fi
            ;;
        *)
            if [ -n "$http_proxy" ] || [ -n "$HTTP_PROXY" ]; then
                echo "[proxy] Status: ON ($http_proxy)"
            else
                echo "[proxy] Status: OFF"
            fi
            echo "Usage:"
            echo "  proxy on | off | list"
            echo "  proxy set <url>"
            echo "  proxy set http <url> [https <url>] [no_proxy <list>]"
            echo "  proxy edit"
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
