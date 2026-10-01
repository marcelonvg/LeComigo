# O Vosk chama a biblioteca nativa via JNA, que acessa campos e métodos
# Java pelo nome a partir do código nativo. Sem estas regras o R8 renomeia
# as classes e o app fecha no build release ("Can't obtain peer field ID
# for class com.sun.jna.Pointer").
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }
-keep class org.vosk.** { *; }
-dontwarn java.awt.**
