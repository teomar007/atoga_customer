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
