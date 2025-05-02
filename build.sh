#!/bin/bash

flutter build apk --release --target-platform android-arm64 --split-per-abi -PtargetAbi=arm64-v8a
