import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:dio/dio.dart' as dio_lib; // Add prefix for dio
import 'dart:io'; // Import for Platform
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // Keep for now, might remove later if not needed
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static const platform = MethodChannel('com.example.edusync/installer'); // Define MethodChannel

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await _supabaseClient
          .from('app_versions')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final latestVersionName = response['version_name'] as String;
      final latestVersionCode = response['version_code'] as int;
      final releaseNotes = response['release_notes'] as String;
      final apkUrl = response['apk_url'] as String;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.parse(packageInfo.buildNumber);

      if (latestVersionCode > currentVersionCode) {
        _showUpdateDialog(context, latestVersionName, releaseNotes, apkUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App is up to date')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check for update: $error')),
      );
    }
  }

  void _showUpdateDialog(BuildContext context, String versionName, String releaseNotes, String apkUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) { // Use dialogContext to ensure it's a descendant of Navigator
        return AlertDialog(
          title: Text('Update Available: $versionName'),
          content: SingleChildScrollView(
            child: Text(releaseNotes),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                final filePath = await _downloadUpdate(context, apkUrl); // Pass the original context
                if (filePath != null) {
                  _installUpdate(context, filePath); // Pass the original context
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _downloadUpdate(BuildContext context, String apkUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/app-release.apk';
      print('Attempting to download APK to: $filePath');

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Downloading update...')),
      );

      // Extract bucket name and file path from the apkUrl
      final uri = Uri.parse(apkUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 4 || pathSegments[0] != 'storage' || pathSegments[1] != 'v1' || pathSegments[2] != 'object' || pathSegments[3] != 'public') {
        throw Exception('Invalid APK URL format for Supabase Storage: $apkUrl');
      }
      final bucketName = pathSegments[4];
      final fileStoragePath = pathSegments.sublist(5).join('/');

      print('Supabase Storage Bucket Name: $bucketName');
      print('Supabase Storage File Path: $fileStoragePath');

      // Use Supabase storage download
      final response = await _supabaseClient.storage.from(bucketName).download(fileStoragePath);

      if (response.isEmpty) {
        throw Exception('Downloaded content is empty.');
      }

      final file = File(filePath);
      await file.writeAsBytes(response);

      print('APK downloaded successfully to: $filePath');

      // Verify downloaded file size
      final actualContentLength = await file.length();
      print('Actual downloaded APK size: $actualContentLength bytes');

      // For Supabase Storage, the download method directly returns bytes,
      // so we can trust the actualContentLength. No need for a separate HEAD request.

      scaffoldMessenger.hideCurrentSnackBar();
      return filePath;
    } catch (error) {
      print('Error downloading update from Supabase Storage: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download update: $error')),
      );
      return null;
    }
  }

  Future<void> _installUpdate(BuildContext context, String filePath) async {
    print('Attempting to install update from: $filePath');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Download complete. Starting installation...')),
    );

    if (Platform.isAndroid) {
      var status = await Permission.requestInstallPackages.status;
      print('Initial REQUEST_INSTALL_PACKAGES permission status: ${status.toString()}');

      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.requestInstallPackages.request();
        print('After request, REQUEST_INSTALL_PACKAGES permission status: ${status.toString()}');
      }

      if (status.isGranted) {
        // Verify file existence and readability just before opening
        final fileToInstall = File(filePath);
        if (!await fileToInstall.exists()) {
          print('Error: File to install does not exist at $filePath');
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Error: Downloaded update file not found.')),
          );
          return;
        }
        if (!await fileToInstall.readAsBytes().then((_) => true).catchError((e) {
          print('Error reading file $filePath: $e');
          return false;
        })) {
          print('Error: Downloaded file is not readable at $filePath');
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Error: Downloaded update file is not readable.')),
          );
          return;
        }
        print('File exists and is readable: $filePath');

        print('Permission granted, attempting to install via MethodChannel.');
        try {
          final String? installResult = await platform.invokeMethod('installApk', {'filePath': filePath});
          print('Native install result: $installResult');
          if (installResult == 'success') {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Installation initiated. Please follow system prompts.')),
            );
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to initiate installation: $installResult')),
            );
          }
        } on PlatformException catch (e) {
          print('PlatformException during APK installation: ${e.message}');
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error initiating installation: ${e.message}')),
          );
        }
      } else {
        print('Permission not granted, informing user to grant manually.');
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Permission to install unknown apps denied. Please enable it in app settings to install updates.')),
        );
        await Future.delayed(const Duration(seconds: 2));
        openAppSettings();
      }
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Update downloaded, but automatic installation is only supported on Android.')),
      );
    }
    print('Installation process completed from app\'s perspective.');
  }
}
