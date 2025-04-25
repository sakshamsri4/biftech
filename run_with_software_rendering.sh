#!/bin/bash

# Run the app with software rendering enabled
cd "$(dirname "$0")"
flutter run --enable-software-rendering --flavor staging -t lib/main_staging.dart
