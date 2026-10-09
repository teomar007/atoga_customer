package com.atogamarket.atoga_customer

/**
 * هل التطبيق في المقدمة الآن؟
 *
 * تبديل أيقونة المشغّل (تعطيل النشاط المستعار الحالي) أثناء الاستخدام
 * يُنهي مهمة التطبيق — поэтому نمنعه في المقدمة ونتولّاه في الخلفية فقط.
 */
object AppForegroundTracker {
    @Volatile
    var isForeground: Boolean = false
}
