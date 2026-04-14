#!/bin/bash
# weather.sh — reads city and API key from Flux/config.user

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config.user"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi

city_query="${CITY_QUERY:-Kathmandu,np}"
api_key="${API_KEY:-}"
unit="metric"
lang="en"
cache_dir="${HOME}/.cache"
cache_file="${cache_dir}/weather.json"

if [[ -z "$api_key" || "$api_key" == "your_openweathermap_api_key_here" ]]; then
    echo "N/A"
    exit 1
fi

mkdir -p "$cache_dir"

get_data() {
    local url
    url="https://api.openweathermap.org/data/2.5/weather?q=${city_query}&appid=${api_key}&units=${unit}&lang=${lang}"

    rm -f "$cache_file"

    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command "try { Invoke-RestMethod -Uri '$url' -UseBasicParsing | ConvertTo-Json -Depth 10 } catch { '' }" > "$cache_file" 2>/dev/null || true
    fi

    if [[ ! -s "$cache_file" ]]; then
        curl -fsSL "$url" -o "$cache_file" 2>/dev/null || true
    fi
}

parse_json() {
    if [[ ! -s "$cache_file" ]]; then
        echo "Updating..."
        return
    fi

    /usr/bin/python3 -c "
import json
try:
    with open('$cache_file', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    if isinstance(data, dict):
        if 'main' in data:
            $1
        elif 'message' in data:
            print(str(data['message']).title())
        else:
            print('N/A')
    else:
        print('N/A')
except Exception:
    print('N/A')
" 2>/dev/null
}

case "${1:-}" in
    -g) get_data ;;
    -c) parse_json "print(data['name'])" ;;
    -t) parse_json "print(int(data['main']['temp'] + 0.5))" ;;
    -h) parse_json "print(data['main']['humidity'])" ;;
    -d) parse_json "print(data['weather'][0]['description'].title())" ;;
    -tx) parse_json "print(int(data['main']['temp_max'] + 0.5))" ;;
    -tn) parse_json "print(int(data['main']['temp_min'] + 0.5))" ;;
    *) echo "Usage: $0 {-g|-c|-t|-h|-d|-tx|-tn}" ; exit 1 ;;
esac
