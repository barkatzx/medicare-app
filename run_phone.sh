#!/bin/bash
# Runs the app on a phone using this Mac's Wi-Fi IP (works without USB reverse).
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
if [ -z "$IP" ]; then echo "No Wi-Fi IP found. Connect Mac to Wi-Fi."; exit 1; fi
echo "Using backend http://$IP:3000/v1"
flutter run --dart-define=API_BASE_URL=http://$IP:3000/v1 "$@"
