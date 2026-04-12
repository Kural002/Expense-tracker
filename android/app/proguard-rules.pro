# Flutter - Google ML Kit ProGuard Rules
# These rules suppress warnings for missing language models that are not used in this app.

-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.android.gms.internal.ml.**

# Keep ML Kit for Latin (the one we use)
-keep class com.google.mlkit.vision.text.latin.** { *; }

# General ML Kit keeps to prevent over-shrinking of the core engine
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.ml.** { *; }
