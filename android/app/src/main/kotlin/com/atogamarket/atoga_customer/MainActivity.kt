package com.atogamarket.atoga_customer

import android.os.Bundle
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        scheduleStoreIconSync()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // قناة تبديل أيقونة المتجر (مفتوح/مغلق) من طبقة Dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app_icon").setMethodCallHandler { call, result ->
            when (call.method) {
                "setStoreOpen" -> {
                    AppIconController.setStoreOpen(this, call.argument<Boolean>("open") ?: true)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        // تشخيص: هل فئات OneSignal/Firebase موجودة فعلاً بعد R8؟
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app_native_probe").setMethodCallHandler { call, result ->
            when (call.method) {
                "probe" -> {
                    val onesignal = runCatching { Class.forName("com.onesignal.OneSignal"); "ok" }
                        .getOrElse { "missing:${it.javaClass.simpleName}" }
                    val firebase = runCatching { Class.forName("com.google.firebase.messaging.FirebaseMessaging"); "ok" }
                        .getOrElse { "missing:${it.javaClass.simpleName}" }
                    // جلب رمز FCM فعلياً وإظهار خطأ الفشل الحقيقي.
                    try {
                        com.google.firebase.messaging.FirebaseMessaging.getInstance().token
                            .addOnCompleteListener { task ->
                                val fcm = if (task.isSuccessful) {
                                    val t = task.result ?: ""
                                    "ok(${t.take(20)}…)"
                                } else {
                                    "error:${task.exception?.javaClass?.simpleName}:${task.exception?.message}"
                                }
                                result.success("onesignalClass=$onesignal; firebase=$firebase; fcm=$fcm")
                            }
                    } catch (e: Exception) {
                        result.success("onesignalClass=$onesignal; firebase=$firebase; fcm=exception:${e.message}")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** مهمة دورية (≈15 دقيقة، الحد الأدنى في أندرويد) لتحديث الأيقونة خلفياً. */
    private fun scheduleStoreIconSync() {
        val request = PeriodicWorkRequestBuilder<StoreIconWorker>(15, TimeUnit.MINUTES)
            .setInitialDelay(1, TimeUnit.MINUTES)
            .build()
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "store_icon_sync",
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }
}
