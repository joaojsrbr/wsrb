cls
call flutter build apk --flavor Production --release --split-per-abi
:@Try
  call adb install ../build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk
:@EndTry
:@Catch
  call adb install build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk
:@EndCatch
cls