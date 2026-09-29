#!/bin/bash
set -e
FLUTTER="/home/anvid/flutter-sdk/bin/flutter"
DEVICE_ID="I7BINFS4YHVWIZW4"
OUTPUT_DIR="clips/video2_app"
VIDEO_FILE="v2_demo_completo.mp4"

# "Instalar" button center: [111,2397][591,2552] → (351,2474)
# "Recordar mi elección" center: [149,2304][1071,2372] → (610,2338)
INSTALL_BTN_X=351
INSTALL_BTN_Y=2474
REMEMBER_X=610
REMEMBER_Y=2338

echo "Dispositivo: $DEVICE_ID"
mkdir -p "$OUTPUT_DIR"

tap_install_dialog_if_visible() {
  local device="$1"
  adb -s "$device" shell uiautomator dump /data/local/tmp/ui.xml 2>/dev/null || true
  local found
  found=$(adb -s "$device" shell grep -c 'securitycenter:id/alertTitle' /data/local/tmp/ui.xml 2>/dev/null || echo 0)
  if [ "${found:-0}" -gt 0 ] 2>/dev/null; then
    echo "[install] Diálogo detectado — tocando Recordar + Instalar"
    adb -s "$device" shell input tap "$REMEMBER_X" "$REMEMBER_Y" 2>/dev/null || true
    sleep 0.3
    adb -s "$device" shell input tap "$INSTALL_BTN_X" "$INSTALL_BTN_Y" 2>/dev/null || true
    return 0
  fi
  return 1
}

# ── FASE 1: PRE-INSTALAR APK (watcher activo) ───────────────────────────────
adb -s "$DEVICE_ID" shell svc wifi enable
sleep 2

echo "Desinstalando versión previa..."
adb -s "$DEVICE_ID" uninstall com.cens.caracterizacion 2>/dev/null || true
sleep 1

echo "Compilando APK debug..."
"$FLUTTER" build apk --debug 2>&1
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"

echo "Instalando APK con vigilancia de diálogo..."
adb -s "$DEVICE_ID" install -r "$APK_PATH" &
INSTALL_PID=$!
DIALOG_TAPPED=0
while kill -0 $INSTALL_PID 2>/dev/null; do
  if tap_install_dialog_if_visible "$DEVICE_ID"; then
    DIALOG_TAPPED=1
  fi
done
wait $INSTALL_PID || true
echo "APK instalado (dialog_tapped=$DIALOG_TAPPED)"

sleep 2

# ── FASE 2: GRABACIÓN + TEST (sin watcher de uiautomator) ───────────────────
echo "Iniciando grabación..."
adb -s "$DEVICE_ID" shell screenrecord --time-limit 180 /sdcard/"$VIDEO_FILE" &
LOCAL_ADB_PID=$!
sleep 2

echo "Corriendo integration test (--no-build, usa APK ya instalado)..."
"$FLUTTER" test integration_test/demo_flow_test.dart \
  -d "$DEVICE_ID" \
  --timeout 300s \
  --no-pub \
  2>&1
TEST_EXIT=$?

echo "Deteniendo grabación..."
adb -s "$DEVICE_ID" shell pkill -SIGINT screenrecord 2>/dev/null || true
kill "$LOCAL_ADB_PID" 2>/dev/null || true
sleep 3

echo "Descargando video..."
adb -s "$DEVICE_ID" pull /sdcard/"$VIDEO_FILE" "$OUTPUT_DIR/$VIDEO_FILE"
echo "Listo: $OUTPUT_DIR/$VIDEO_FILE (test exit: $TEST_EXIT)"
