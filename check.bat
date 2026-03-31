@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Flutter / Android Version Check

REM ---- Move to directory where BAT file exists (project root) ----
cd /d "%~dp0"

echo ==================================================
echo   FLUTTER / ANDROID ENVIRONMENT VERSION CHECK
echo ==================================================
echo.
echo Project root:
cd
echo.

REM -------- FLUTTER --------
echo [Flutter]
call flutter --version
echo.

REM -------- DART --------
echo [Dart]
call dart --version
echo.

REM -------- JAVA --------
echo [Java]
call java -version
echo.

REM -------- GRADLE (WRAPPER) --------
echo [Gradle - Wrapper]
if exist "android\gradlew.bat" (
    pushd android
    call gradlew --version
    popd
) else (
    echo ❌ gradlew.bat not found
)
echo.

REM -------- ANDROID GRADLE PLUGIN --------
echo [Android Gradle Plugin]
if exist "android\build.gradle.kts" (
    findstr /R "com.android.tools.build:gradle" android\build.gradle.kts
)
if exist "android\build.gradle" (
    findstr /R "com.android.tools.build:gradle" android\build.gradle
)
echo.

REM -------- FLUTTER PLUGINS --------
echo [Flutter Plugins (from pubspec.lock)]
if exist pubspec.lock (
    findstr "dependency:" pubspec.lock
) else (
    echo ❌ pubspec.lock not found
)
echo.

echo ==================================================
echo   CHECK COMPLETE - PRESS ANY KEY TO EXIT
echo ==================================================
pause
