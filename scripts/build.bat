@echo off
cls
echo ===== Iniciando build APK Flutter (Production - Release - Split per ABI) =====

:: Compila o APK com flavor Production, em modo release, dividindo por ABI
call flutter build apk --flavor Production --release --split-per-abi
IF ERRORLEVEL 1 (
    echo [ERRO] Falha ao compilar o APK.
    pause
    exit /b 1
)

echo ===== Build concluído com sucesso =====
echo.

:: Define o caminho do APK gerado
set APK_PATH= ../build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk
set ALT_APK_PATH= build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk

:: Tenta instalar o APK pelo caminho alternativo primeiro
echo Tentando instalar APK pelo caminho: %ALT_APK_PATH%
call adb install %ALT_APK_PATH%
IF ERRORLEVEL 1 (
    echo [AVISO] Falha ao instalar pelo caminho alternativo. Tentando caminho padrão...

    :: Tenta o caminho padrão se o primeiro falhar
    call adb install %APK_PATH%
    IF ERRORLEVEL 1 (
        echo [ERRO] Falha ao instalar o APK com ambos os caminhos.
        pause
        exit /b 1
    ) ELSE (
        echo [SUCESSO] APK instalado com sucesso pelo caminho padrão.
    )
) ELSE (
    echo [SUCESSO] APK instalado com sucesso pelo caminho alternativo.
)

echo.
echo ===== Processo concluído =====
pause
cls
