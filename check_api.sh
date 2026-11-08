#!/bin/bash

set -u
url="$1"

http_code=$(curl -s -o /dev/null -w '%{http_code}' -m 15 "$url")

if [ "$http_code" -eq 200 ]; then
    echo "API доступен"
    exit 0
else
    echo "API недоступен, код ответа: $http_code"
    exit 1
fi