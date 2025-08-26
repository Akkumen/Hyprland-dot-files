#!/bin/bash

# Weather condition script for Umeå, Sweden
# Uses Open-Meteo API to get weather data

#!/bin/bash

# Wait for network connectivity
max_attempts=5
attempt=1

while [ $attempt -le $max_attempts ]; do
    if ping -c 1 -W 1 api.open-meteo.com >/dev/null 2>&1; then
        break
    fi
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo "No network"
    exit 1
fi

# ... rest of your script


# Coordinates for Umeå
LATITUDE="63.8258"
LONGITUDE="20.2630"

# Fetch weather data from Open-Meteo API
WEATHER_DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&current=weather_code,temperature_2m" 2>/dev/null)

# Check if we got a valid response
if [ -z "$WEATHER_DATA" ]; then
    echo '{"text": "🌡 Weather API Error", "tooltip": "Failed to fetch weather data"}'
    exit 1
fi

# Extract weather code and temperature using jq
WEATHER_CODE=$(echo "$WEATHER_DATA" | jq -r '.current.weather_code')
TEMPERATURE=$(echo "$WEATHER_DATA" | jq -r '.current.temperature_2m')

# Map weather codes to descriptions and icons
case $WEATHER_CODE in
    0) CONDITION="Clear"; ICON="☀" ;;
    1) CONDITION="Mainly Clear"; ICON="🌤" ;;
    2) CONDITION="Partly Cloudy"; ICON="⛅" ;;
    3) CONDITION="Overcast"; ICON="☁" ;;
    45|48) CONDITION="Fog"; ICON="🌫" ;;
    51|53|55) CONDITION="Drizzle"; ICON="🌧" ;;
    56|57) CONDITION="Freezing Drizzle"; ICON="🌧❄" ;;
    61|63|65) CONDITION="Rain"; ICON="🌧" ;;
    66|67) CONDITION="Freezing Rain"; ICON="🌧❄" ;;
    71|73|75) CONDITION="Snow"; ICON="❄" ;;
    77) CONDITION="Snow Grains"; ICON="❄" ;;
    80|81|82) CONDITION="Rain Showers"; ICON="🌦" ;;
    85|86) CONDITION="Snow Showers"; ICON="🌨" ;;
    95) CONDITION="Thunderstorm"; ICON="⛈" ;;
    96|99) CONDITION="Thunderstorm with Hail"; ICON="⛈🧊" ;;
    *) CONDITION="Unknown"; ICON="🌡" ;;
esac

# Output in JSON format for Waybar
echo "${CONDITION} ${TEMPERATURE}°"
