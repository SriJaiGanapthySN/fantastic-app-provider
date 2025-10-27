-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keepattributes Signature

# Video player and ExoPlayer rules to fix MediaCodec errors
-keep class androidx.media3.** { *; }
-keep interface androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }

# Keep video codec renderers
-keep class androidx.media3.exoplayer.video.MediaCodecVideoRenderer { *; }
-keep class androidx.media3.exoplayer.mediacodec.** { *; }

# Keep video player controller
-keep class io.flutter.plugins.videoplayer.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep attributes for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
