# OneSignal SDK — تهيئة عبر Reflection/Callbacks
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# WorkManager: العامل يُنشأ بالاسم عبر Reflection
-keep class * extends androidx.work.ListenableWorker { <init>(...); }
-keep class com.atogamarket.atoga_customer.StoreIconWorker { *; }

# Flutter embedding
-keep class io.flutter.** { *; }
-keepattributes Signature,*Annotation*,EnclosingMethod,InnerClasses

# Play Core (اختياري لـ Flutter SplashScreen API) — فئات غير موجودة وقت R8
-dontwarn com.google.android.play.core.**
