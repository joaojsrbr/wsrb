cls
call flutter build apk --flavor Production --release --split-per-abi
call adb install build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk
cls