# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Add any custom rules for your dependencies here
-keep class com.ubuncare.ubuncare_app.** { *; }

# General Android rules
-keep class androidx.lifecycle.DefaultLifecycleObserver

# For Google Play services (if you use any)
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.**

# For http and network
-keep class com.android.volley.** { *; }
-keep class org.apache.http.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*

# Keep line numbers for stack traces
-keepattributes SourceFile,LineNumberTable

# Recommended rules for release builds
-optimizations !code/simplification/cast,!field/*,!class/merging/*
-keepattributes InnerClasses
-keepclasseswithmembers class * {
    public static void main(java.lang.String[]);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}