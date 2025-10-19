@echo off
echo ========================================
echo Building EduSync Windows Application
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
C:\Users\sayar\flutter\bin\flutter.bat clean
echo.

echo Step 2: Getting dependencies...
C:\Users\sayar\flutter\bin\flutter.bat pub get
echo.

echo Step 3: Building Windows Release...
C:\Users\sayar\flutter\bin\flutter.bat build windows --release
echo.

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Your EXE is located at:
    echo E:\edu_sync\build\windows\x64\runner\Release\edu_sync.exe
    echo.
    echo Opening build folder...
    start "" "E:\edu_sync\build\windows\x64\runner\Release"
) else (
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo Please check the error messages above.
)

pause
