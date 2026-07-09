@echo off
echo 🚀 Generando APK de CaracT Móvil...
echo.

echo 📦 Obteniendo dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error en flutter pub get
    pause
    exit /b 1
)

echo 📦 Obteniendo dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error en flutter pub get
    pause
    exit /b 1
)

echo 🎨 Generando iconos...
call flutter pub run flutter_launcher_icons:main
if %errorlevel% neq 0 (
    echo ⚠️ Error generando iconos (continuando...)
)

echo 🔨 Construyendo APK firmado...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Error construyendo APK
    pause
    exit /b 1
)

echo.
echo ✅ APK generado exitosamente!
echo 📱 Ubicación: build\app\outputs\flutter-apk\app-release.apk
echo.
echo 📊 Información del archivo:
dir "build\app\outputs\flutter-apk\app-release.apk" | findstr "app-release.apk"
echo.
echo 🎉 ¡Listo para distribución!
pause
