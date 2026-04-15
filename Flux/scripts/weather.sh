#!/bin/bash
# weather.sh — Written for WeatherAPI.com (Flux Pro v1.0.0)

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config.user"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

city_query="${CITY_QUERY:-Kathmandu}"
api_key="${API_KEY:-}"
cache_dir="${HOME}/.cache"
cache_file="${cache_dir}/weather.json"
icon_file="${cache_dir}/weather_icon.png"

mkdir -p "$cache_dir"

get_data() {
    # Cleaned URL (removed AQI parameter)
    local url="http://api.weatherapi.com/v1/forecast.json?key=${api_key}&q=${city_query}&days=1"
    
    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command "(Invoke-WebRequest -Uri '$url' -UseBasicParsing).Content" > "$cache_file" 2>/dev/null || true
    else
        curl -fsSL "$url" -o "$cache_file" 2>/dev/null || true
    fi

    if [[ -s "$cache_file" ]]; then
        local icon_url=$(python3 -c "import json; d=json.load(open('$cache_file')); print('https:' + d['current']['condition']['icon'])")
        curl -fsSL "$icon_url" -o "$icon_file" 2>/dev/null || true
    fi
}

parse_json() {
    if [[ ! -s "$cache_file" ]]; then echo "N/A"; return; fi
    python3 -c "
import json
try:
    with open('$cache_file', 'r') as f: d = json.load(f)
    $1
except Exception: print('N/A')
" 2>/dev/null
}

case "${1:-}" in
    -g)   get_data ;;
    -c)   parse_json "print(d['location']['name'])" ;;
    -t)   parse_json "print(int(d['current']['temp_c']))" ;;
    -f)   parse_json "print(int(d['current']['feelslike_c']))" ;;
    -h)   parse_json "print(d['current']['humidity'])" ;;
    -d)   parse_json "print(d['current']['condition']['text'])" ;;
    -uv)  parse_json "print(int(d['current']['uv']))" ;;
    -tx)  parse_json "print(int(d['forecast']['forecastday'][0]['day']['maxtemp_c']))" ;;
    -tn)  parse_json "print(int(d['forecast']['forecastday'][0]['day']['mintemp_c']))" ;;
    *) echo "Usage: $0 {-g|-c|-t|-f|-h|-d|-uv|-tx|-tn}" ; exit 1 ;;
esac