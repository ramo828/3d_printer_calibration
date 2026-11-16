# R8 / ProGuard kuralları (android/app/proguard-rules.pro)
# Flutter ve google_mobile_ads kendi kurallarını otomatik getirir.
# Buraya yalnızca ekstra ihtiyaç olursa kural eklenir.

# Flutter'ın isteğe bağlı Play Core referansları için uyarıları sustur
-dontwarn com.google.android.play.core.**
