#!/usr/bin/env bash
# Genera el keystore de firma para CaracT Móvil y crea key.properties.
# Ejecutar UNA sola vez desde la raíz del proyecto; guarda la contraseña en un lugar seguro.

set -euo pipefail

KEYSTORE="android/app/upload-keystore.jks"
KEY_PROPS="android/key.properties"

if [[ -f "$KEYSTORE" ]]; then
  echo "⚠️  $KEYSTORE ya existe. NO lo borres ni lo sobrescribas:"
  echo "    es la llave con la que se firman las actualizaciones. Con una llave"
  echo "    nueva, Android rechaza la actualización y hay que desinstalar la app"
  echo "    (se pierden las encuestas pendientes en cada teléfono)."
  echo "    Respaldo: backup:firma/ (rclone, cifrado) y ~/CENS-APK/firma-*/"
  exit 1
fi

echo "════════════════════════════════════════════"
echo "  Generando keystore para com.cens.caracterizacion"
echo "════════════════════════════════════════════"
echo ""
echo "  La contraseña debe tener MÍNIMO 6 caracteres."
echo ""

# Pedir contraseña una sola vez — se usa en el keystore Y en key.properties
while true; do
  read -rsp "  Contraseña (storePassword y keyPassword): " PASS; echo
  if [[ ${#PASS} -ge 6 ]]; then break; fi
  echo "  ✗ Demasiado corta. Mínimo 6 caracteres."
done
read -rsp "  Repite la contraseña:                      " PASS2; echo
if [[ "$PASS" != "$PASS2" ]]; then
  echo "  ✗ Las contraseñas no coinciden. Vuelve a ejecutar el script."
  exit 1
fi

echo ""
echo "  Completa los datos del certificado:"

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -storepass "$PASS" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10950 \
  -alias upload \
  -keypass "$PASS"

cat > "$KEY_PROPS" <<EOF
storeFile=../app/upload-keystore.jks
storePassword=${PASS}
keyAlias=upload
keyPassword=${PASS}
EOF

echo ""
echo "✅ Keystore: $KEYSTORE"
echo "✅ key.properties creado."
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Guarda la contraseña '$PASS' en un lugar seguro."
echo "   - Nunca subas $KEYSTORE ni $KEY_PROPS a git (ya están en .gitignore)."
