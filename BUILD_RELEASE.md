# EduSync v3.2.0 - Release Build Instructions

## Version Information
- **Version**: 3.2.0
- **Build Number**: 1
- **Release Date**: 2024

## Pre-Build Checklist
- [x] Version updated in `pubspec.yaml` to 3.2.0+1
- [x] Version updated in all drawer footers
- [x] App settings screen uses dynamic version loading
- [ ] Test all features on target platforms
- [ ] Update CHANGELOG.md with release notes
- [ ] Ensure `.env` file is configured with production credentials

## Build Commands

### Android Release Build

#### APK (for testing/distribution)
```bash
flutter clean
flutter pub get
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (for Google Play Store)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS Release Build
```bash
flutter clean
flutter pub get
flutter build ios --release
```
Then open Xcode to archive and upload to App Store.

### Windows Release Build
```bash
flutter clean
flutter pub get
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### Web Release Build
```bash
flutter clean
flutter pub get
flutter build web --release
```
Output: `build/web/`

### Linux Release Build
```bash
flutter clean
flutter pub get
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

## Post-Build Steps

### Android
1. Sign the APK/AAB with your keystore
2. Test on physical devices
3. Upload to Google Play Console
4. Submit for review

### iOS
1. Archive in Xcode
2. Validate the archive
3. Upload to App Store Connect
4. Submit for review

### Windows
1. Create installer using Inno Setup or similar
2. Test on clean Windows installation
3. Distribute via website or Microsoft Store

### Web
1. Deploy to hosting service (Firebase Hosting, Netlify, etc.)
2. Configure domain and SSL
3. Test on multiple browsers

## Testing Checklist
- [ ] Login/Authentication works
- [ ] All user roles (Admin, Teacher, Parent, Student, Manager, Donator) function correctly
- [ ] App Settings accessible from all drawers
- [ ] Language switching works (English/Myanmar)
- [ ] Version number displays correctly (3.2.0)
- [ ] Database operations work
- [ ] Offline mode functions properly
- [ ] Push notifications work
- [ ] File uploads/downloads work
- [ ] All navigation routes work

## Release Notes for v3.2.0
- Added App Settings to all user role navigation drawers
- Improved version management with dynamic loading
- Bug fixes and performance improvements
- Enhanced user experience across all platforms

## Distribution

### Google Play Store
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest
- Bundle format: AAB

### Apple App Store
- Minimum iOS version: Check `ios/Podfile`
- Bundle ID: Check `ios/Runner.xcodeproj`

### Microsoft Store (Windows)
- Package format: MSIX
- Minimum Windows version: Windows 10

## Rollback Plan
If issues are found after release:
1. Revert to previous version in stores
2. Fix issues in development
3. Increment build number
4. Re-release with fixes

## Support
For build issues, contact the development team or refer to Flutter documentation:
- https://docs.flutter.dev/deployment
