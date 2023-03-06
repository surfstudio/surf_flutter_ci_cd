#!/usr/bin/env bash
FLUTTER_REQUIRED_VERSION=3.0.1
#todo: maybe use version from fvm instead of hardcoding here

fvm use $FLUTTER_REQUIRED_VERSION
fvm install
fvm flutter doctor
fvm flutter clean
# fvm flutter pub upgrade
fvm flutter pub get
