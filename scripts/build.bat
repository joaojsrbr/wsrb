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

echo.
echo ===== Build concluído com sucesso =====

:: Define caminho original do APK gerado (mais comum: arm64-v8a)
set ORIGINAL_APK=build\app\outputs\flutter-apk\app-arm64-v8a-production-release.apk

:: Pergunta onde salvar o APK
set /p DEST_FOLDER=Digite o caminho absoluto da pasta onde deseja salvar o APK (sem aspas): 

:: Cria pasta se não existir
if not exist "%DEST_FOLDER%" (
    mkdir "%DEST_FOLDER%"
)

:: Copia o APK para a pasta escolhida
copy /Y "%ORIGINAL_APK%" "%DEST_FOLDER%\app-production-release.apk"
IF ERRORLEVEL 1 (
    echo [ERRO] Falha ao copiar o APK para a pasta destino.
    pause
    exit /b 1
)

:: Instala o APK copiado
echo Instalando APK: %DEST_FOLDER%\app-production-release.apk
call adb install -r "%DEST_FOLDER%\app-production-release.apk"
IF ERRORLEVEL 1 (
    echo [ERRO] Falha ao instalar o APK.
    pause
    exit /b 1
) ELSE (
    echo [SUCESSO] APK instalado com sucesso!
)

echo.
echo ===== Processo concluído =====
pause
cls
