# Reglas de ProGuard para CaracT Móvil - MODO ULTRA CONSERVADOR

# *** MÁXIMA PRIORIDAD: Mantener TODA la aplicación ***
-keep class com.example.caracterizacion_cens.** { *; }
-keepnames class com.example.caracterizacion_cens.** { *; }

# Mantener TODAS las actividades de Android sin excepción
-keep public class * extends android.app.Activity { *; }
-keep public class * extends android.app.Application { *; }
-keep public class * extends android.app.Service { *; }
-keep public class * extends android.content.BroadcastReceiver { *; }
-keep public class * extends android.content.ContentProvider { *; }

# Mantener TODO Flutter sin excepciones
-keep class io.flutter.** { *; }
-keepnames class io.flutter.** { *; }

# Mantener TODO AndroidX
-keep class androidx.** { *; }
-keepnames class androidx.** { *; }

# DESACTIVAR COMPLETAMENTE TODAS LAS OPTIMIZACIONES
-dontoptimize
-dontobfuscate
-dontshrink
-dontpreverify

# Mantener todos los atributos críticos
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# No eliminar NADA que no sea obviamente basura
-keep class * { *; }

# Warnings específicos que podemos ignorar
-dontwarn com.google.android.play.core.**
-dontwarn androidx.**
-dontwarn mailer.**
