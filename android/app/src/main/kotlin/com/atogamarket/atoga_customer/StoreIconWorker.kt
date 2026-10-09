package com.atogamarket.atoga_customer

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL

/**
 * مهمة دورية (خلفية): تسأل الخادم «هل المتجر مفتوح الآن؟» عبر RPC
 * `store_is_open_now()` وتضبط أيقونة المشغّل — تعمل حتى والتطبيق مغلق.
 */
class StoreIconWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val base = applicationContext.getString(R.string.supabase_url)
            val key = applicationContext.getString(R.string.supabase_anon_key)
            val conn = (URL("$base/rest/v1/rpc/store_is_open_now").openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                connectTimeout = 15000
                readTimeout = 15000
                doOutput = true
                setRequestProperty("apikey", key)
                setRequestProperty("Authorization", "Bearer $key")
                setRequestProperty("Content-Type", "application/json")
            }
            conn.outputStream.use { it.write("{}".toByteArray()) }
            val code = conn.responseCode
            if (code !in 200..299) {
                conn.disconnect()
                return@withContext Result.retry()
            }
            val open = conn.inputStream.bufferedReader().use { it.readText() }.trim().equals("true", ignoreCase = true)
            conn.disconnect()
            AppIconController.setStoreOpen(applicationContext, open)
            Result.success()
        } catch (_: Exception) {
            // شبكة غير متاحة الآن — تُعاد المحاولة في الدورة القادمة.
            Result.retry()
        }
    }
}
