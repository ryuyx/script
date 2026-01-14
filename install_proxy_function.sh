#!/bin/bash

PROXY_FUNCTION='# Proxy control 
function proxy() {
    if [ "$1" = "on" ]; then
        export http_proxy="http://127.0.0.1:7890"
        export https_proxy="http://127.0.0.1:7890"
        export HTTP_PROXY="http://127.0.0.1:7890"
        export HTTPS_PROXY="http://127.0.0.1:7890"
        echo "[proxy] Proxy is ON"
    elif [ "$1" = "off" ]; then
        unset http_proxy
        unset https_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        echo "[proxy] Proxy is OFF"
    else
        if [ -n "$http_proxy" ]; then
            echo "[proxy] Status: ON ($http_proxy)"
        else
            echo "[proxy] Status: OFF"
        fi
        echo "Usage: proxy on / proxy off"
    fi
}'

if grep -q "^proxy()" ~/.bashrc; then
    echo "proxy function already exists in ~/.bashrc"
else
    echo "$PROXY_FUNCTION" >> ~/.bashrc
    echo "proxy function added to ~/.bashrc"
    echo "Please run 'source ~/.bashrc' to activate it"
fi
