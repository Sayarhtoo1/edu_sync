@echo off
echo ========================================
echo EduSync v3.2.0 - Release Build Script
echo ========================================
echo.

:menu
echo Select build target:
echo 1. Android APK
echo 2. Android App Bundle (AAB)
echo 3. Windows
echo 4. Web
echo 5. All platforms
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto android_apk
if "%choice%"=="2" goto android_aab
if "%choice%"=="3" goto windows
if "%choice%"=="4" goto web
if "%choice%"=="5" goto all
if "%choice%"=="6" goto end
goto menu

:android_apk
echo.
echo Building Android APK...
call flutter clean
call flutter pub get
call flutter build apk --release
echo.
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
pause
goto menu

:android_aab
echo.
echo Building Android App Bundle...
call flutter clean
call flutter pub get
call flutter build appbundle --release
echo.
echo AAB built successfully!
echo Location: build\app\outputs\bundle\release\app-release.aab
pause
goto menu

:windows
echo.
echo Building Windows Release...
call flutter clean
call flutter pub get
call flutter build windows --release
echo.
echo Windows build completed!
echo Location: build\windows\runner\Release\
pause
goto menu

:web
echo.
echo Building Web Release...
call flutter clean
call flutter pub get
call flutter build web --release
echo.
echo Web build completed!
echo Location: build\web\
pause
goto menu

:all
echo.
echo Building all platforms...
echo.
echo [1/4] Building Android APK...
call flutter clean
call flutter pub get
call flutter build apk --release
echo.
echo [2/4] Building Android App Bundle...
call flutter build appbundle --release
echo.
echo [3/4] Building Windows...
call flutter build windows --release
echo.
echo [4/4] Building Web...
call flutter build web --release
echo.
echo All builds completed successfully!
pause
goto menu

:end
echo.
echo Exiting build script...
exit
