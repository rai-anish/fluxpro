#!/bin/bash
# weather.sh — reads city and API key from Flux/config.user

# ── Locate config.user relative to this script ─────────────────────────────
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config.user"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# ── Settings (fall back to environment variables if config.user is missing) ─
city_query="${CITY_QUERY:-Kathmandu,np}"
api_key="${API_KEY:-}"
unit="metric"
lang="en"
cache_file="${HOME}/.cache/weather.json"

if [[ -z "$api_key" ]]; then
    echo "N/A"
    exit 1
fi

mkdir -p "${HOME}/.cache"

get_data() {
    url="https://api.openweathermap.org/data/2.5/weather?q=${city_query}&appid=${api_key}&units=${unit}&lang=${lang}"

    # Try powershell first (best for WSL networking)
    if command -v powershell.exe &> /dev/null; then
        powershell.exe -c "Invoke-RestMethod -Uri '$url' -UseBasicParsing | ConvertTo-Json -Depth 10" > "$cache_file" 2>/dev/null
    fi

    # Fallback to curl if powershell failed or produced empty file
    if [ ! -s "$cache_file" ]; then
        curl -s "$url" -o "$cache_file"
    fi
}

parse_json() {
    if [ ! -s "$cache_file" ]; then
        echo "Updating..."
        return
    fi

    # Python parser with utf-8-sig to handle PowerShell's potential BOMs
    # and explicit error reporting for API limit/key issues
    /usr/bin/python3 -c "
import sys, json
try:
    with open('$cache_file', 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    if isinstance(data, dict):
        if 'main' in data:
            $1
        elif 'message' in data:
            # Report the API error message (e.g. 'Invalid API key')
            print(data['message'].title())
        else:
            print('N/A')
    else:
        print('N/A')
except Exception:
    print('N/A')
" 2>/dev/null
}

case $1 in
    -g) get_data ;;
    -c) parse_json "print(data['name'])" ;;
    -t) parse_json "print(int(data['main']['temp'] + 0.5))" ;;
    -h) parse_json "print(data['main']['humidity'])" ;;
    -d) parse_json "print(data['weather'][0]['description'].title())" ;;
    -tx) parse_json "print(int(data['main']['temp_max'] + 0.5))" ;;
    -tn) parse_json "print(int(data['main']['temp_min'] + 0.5))" ;;
    *) echo "Usage: $0 {-g|-t|-h|-d|-tx|-tn}"; exit 1 ;;
esac