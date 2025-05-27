# Keep Jackson databind and core classes
-keep class com.fasterxml.jackson.databind.** { *; }
-dontwarn com.fasterxml.jackson.databind.**

# Keep JavaBeans annotations if used
-dontwarn java.beans.**

# Keep DOM-related classes
-dontwarn org.w3c.dom.bootstrap.**

# Avoid R8 removing unused classes/methods
-keep class org.w3c.dom.bootstrap.DOMImplementationRegistry { *; }

# General keep for Jackson fallback
-keepclassmembers class * {
    @com.fasterxml.jackson.annotation.* <fields>;
    @com.fasterxml.jackson.annotation.* <methods>;
}
