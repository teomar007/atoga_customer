package com.atogamarket.atoga_customer

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager

/** تبديل أيقونة المشغّل بين حالتَي المتجر (مفتوح/مغلق) عبر activity-alias. */
object AppIconController {
    fun setStoreOpen(context: Context, open: Boolean) {
        val pkg = context.packageName
        val openAlias = ComponentName(pkg, "$pkg.MainActivityOpen")
        val closedAlias = ComponentName(pkg, "$pkg.MainActivityClosed")
        val pm = context.packageManager
        val enable = PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        val disable = PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        val flag = PackageManager.DONT_KILL_APP
        try {
            pm.setComponentEnabledSetting(if (open) openAlias else closedAlias, enable, flag)
            pm.setComponentEnabledSetting(if (open) closedAlias else openAlias, disable, flag)
        } catch (_: Exception) {
            // بعض المشغّلات/القيود قد ترفض — لا نُسقط التطبيق لأجل الأيقونة.
        }
    }
}
