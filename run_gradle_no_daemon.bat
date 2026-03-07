@echo off
set FLUTTER_ROOT=C:\flutter
set JAVA_HOME=C:\"Program Files\"\Android\"Android Studio\"\jbr
cd android
call gradlew.bat assembleDebug --no-daemon --info
