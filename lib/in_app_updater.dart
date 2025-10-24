// in_app_updater.dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

class InAppUpdater {
  final String manifestUrl;
  final Dio _dio = Dio();

  InAppUpdater({required this.manifestUrl});

  Future<Map<String, dynamic>?> _fetchManifest() async {
    try {
      final r = await http.get(Uri.parse(manifestUrl));
      if (r.statusCode == 200) {
        return json.decode(r.body) as Map<String, dynamic>;
      } else {
        debugPrint('Manifest fetch failed: ${r.statusCode}');
      }
    } catch (e) {
      debugPrint('Manifest fetch error: $e');
    }
    return null;
  }

  Future<int> _currentVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }

  Future<bool> isUpdateAvailableFromManifest(Map<String, dynamic> manifest) async {
    final remote = (manifest['versionCode'] is int)
        ? manifest['versionCode'] as int
        : int.tryParse(manifest['versionCode'].toString()) ?? 0;
    final local = await _currentVersionCode();
    return remote > local;
  }

  Future<String> _sha256File(String path) async {
    final bytes = await File(path).readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _downloadApk(String url, void Function(int, int)? onProgress) async {
    final dir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
    final filePath = '${dir!.path}/instruo_update.apk';
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  await _dio.download(url, filePath,
    onReceiveProgress: onProgress,
    options: Options(receiveTimeout: Duration.zero, followRedirects: true));
    return filePath;
  }

  Future<void> _openUnknownAppsSettings(BuildContext context) async {
    final intent = AndroidIntent(
      action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
      data: 'package:${Platform.isAndroid ? await _getPackageName() : ""}',
    );
    try {
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open Install Unknown Apps settings manually')),
      );
    }
  }

  Future<String> _getPackageName() async {
    final info = await PackageInfo.fromPlatform();
    return info.packageName;
  }

  /// Main public method: checks manifest, prompts user, downloads, verifies and launches installer.
  Future<void> checkAndPerformUpdate(BuildContext context, {bool forceCheck = false}) async {
    final manifest = await _fetchManifest();
    if (manifest == null) {
      if (forceCheck) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch update manifest')));
      }
      return;
    }

    final apkUrl = manifest['apk_url']?.toString();
    final expectedSha = manifest['sha256']?.toString()?.toLowerCase();
    final remoteVersionCode = (manifest['versionCode'] is int)
        ? manifest['versionCode'] as int
        : int.tryParse(manifest['versionCode'].toString()) ?? 0;
    final versionName = manifest['versionName']?.toString() ?? '';

    if (apkUrl == null || expectedSha == null) {
      debugPrint('Manifest missing apk_url or sha256');
      return;
    }

    final localVersion = await _currentVersionCode();
    if (remoteVersionCode <= localVersion) {
      if (forceCheck) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('App is already up to date')));
      }
      return;
    }

    // Show update dialog
    final shouldDownload = await showDialog<bool>(
      context: context,
      builder: (_) => _UpdateDialog(versionName: versionName),
    );

    if (shouldDownload != true) return;

    // Request storage permission (older devices)
    if (Platform.isAndroid) {
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }
    }

    // Download with progress UI
    String? apkPath;
    final progressNotifier = ValueNotifier<double>(0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DownloadProgressDialog(progress: progressNotifier),
    );

    try {
      apkPath = await _downloadApk(apkUrl, (received, total) {
        if (total > 0) {
          progressNotifier.value = received / total;
        }
      });
    } catch (e) {
      Navigator.of(context).pop(); // close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      return;
    }

    // Verify sha256
    final actualSha = await _sha256File(apkPath);
    if (actualSha.toLowerCase() != expectedSha.toLowerCase()) {
      Navigator.of(context).pop(); // close progress dialog
      await File(apkPath).delete().catchError((_) {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checksum mismatch — aborting update')));
      return;
    }

    // Close progress dialog
    Navigator.of(context).pop();

    // On Android 8+ ensure user has allowed install from unknown sources for this app
    bool needsUnknownSourceFlow = false;
    if (Platform.isAndroid) {
      // Can't call PackageManager.canRequestPackageInstalls() directly from Dart (no plugin here).
      // We'll attempt to launch the APK; if install fails user will be guided.
      // Offer the user to open settings proactively:
      needsUnknownSourceFlow = true;
    }

    if (needsUnknownSourceFlow) {
      final allow = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Install permission required'),
          content: Text('You may need to enable "Install unknown apps" for this app before installing the update. Open settings now?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Open Settings')),
          ],
        ),
      );
      if (allow == true) {
        await _openUnknownAppsSettings(context);
        // Wait for user to come back — we can't detect when they return reliably, so ask them to press Install after enabling.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('After enabling, tap the Update button again to install.')));
      }
    }

    // Launch installer (this will prompt user to confirm install)
    final result = await OpenFile.open(apkPath);
    debugPrint('OpenFile result: $result');
  }
}

// Small dialog classes used above
class _UpdateDialog extends StatelessWidget {
  final String versionName;
  const _UpdateDialog({Key? key, required this.versionName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update available'),
      content: Text('A new version ($versionName) is available. Do you want to download and install it?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Later')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Update')),
      ],
    );
  }
}

class _DownloadProgressDialog extends StatelessWidget {
  final ValueNotifier<double> progress;
  const _DownloadProgressDialog({Key? key, required this.progress}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, value, __) {
            final percent = (value * 100).toStringAsFixed(0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Downloading update... $percent%'),
                SizedBox(height: 12),
                LinearProgressIndicator(value: value),
                SizedBox(height: 12),
                Text('Do not close the app while downloading'),
                SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    // No cancel implemented (Dio cancel token would be required for cancel)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel not implemented')));
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
