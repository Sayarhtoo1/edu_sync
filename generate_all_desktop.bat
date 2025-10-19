@echo off
echo ========================================
echo EduSync Desktop Screens Generator
echo ========================================
echo.
echo This will automatically:
echo 1. Generate ALL desktop screens
echo 2. Update router.dart with adaptive routing
echo 3. Keep mobile screens unchanged
echo.
pause

echo.
echo [1/2] Generating desktop screens...
python generate_desktop_screens.py

echo.
echo [2/2] Updating router...
python update_router.py

echo.
echo ========================================
echo COMPLETE!
echo ========================================
echo.
echo Desktop screens created in: lib/screens/desktop/
echo Router updated: lib/config/router.dart
echo Mobile screens: UNCHANGED
echo.
echo Test your app:
echo - Mobile (^<900px): Shows mobile screens
echo - Desktop (^>=900px): Shows desktop screens
echo.
pause
