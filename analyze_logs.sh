#!/bin/bash

set -u

log_file="access.log"

generate_log() {
    local ips=("192.168.1.10" "8.8.8.8" "0.0.0.0" "192.168.1.20" "127.0.0.1")
    local methods=("GET" "POST" "PUT" "DELETE")
    local uris=("/api/users" "/api/login" "/api/orders" "/api/products" "/api/clients" "/agreements")
    local codes=(200 200 200 200 200 401 403 404 500 502 503)
    local count=350

    > "$log_file" #очищаем файл

    for ((i = 0; i < count; i++)); do
        local ip=${ips[$((RANDOM % ${#ips[@]}))]}
        local method=${methods[$((RANDOM % ${#methods[@]}))]}
        local uri=${uris[$((RANDOM % ${#uris[@]}))]}
        local code=${codes[$((RANDOM % ${#codes[@]}))]}

        # Случайная дата в пределах августа 2026
        local day=$((RANDOM % 28 + 1))
        local hour=$((RANDOM % 24))
        local min=$((RANDOM % 60))
        local sec=$((RANDOM % 60))
        printf -v ts "%02d/Nov/2026:%02d:%02d:%02d" "$day" "$hour" "$min" "$sec"

        echo "$ip - - [$ts] \"$method $uri HTTP/1.1\" $code" >> "$log_file"
    done
}

analyze_log() {
    local total
    total=$(wc -l < "$log_file")
    echo "Общее количество запросов: $total"

    echo "Топ-3 IP-адреса по числу запросов:"
    grep -oE '^([0-9]{1,3}\.){3}[0-9]{1,3}' "$log_file" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -n 3 \
        | awk '{printf "  %-15s %s запросов\n", $2, $1}'
    echo

    local code4 code5
    code4=$(grep -cE '" [4][0-9]{2}$' "$log_file")
    code5=$(grep -cE '" [5][0-9]{2}$' "$log_file")

    echo "Запросы с кодами 4xx: $code4"
    echo "Запросы с кодами 5xx: $code5"
}

generate_log
analyze_log