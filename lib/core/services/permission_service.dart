import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _cameraPermissionKey = 'camera_permission_granted';
  static const String _micPermissionKey = 'mic_permission_granted';

  Future<void> requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final cameraGranted = prefs.getBool(_cameraPermissionKey) ?? false;
    final micGranted = prefs.getBool(_micPermissionKey) ?? false;

    if (cameraGranted && micGranted) {
      debugPrint('Permissions already granted according to prefs, skipping.');
      return;
    }

    final cameraStatus = await Permission.camera.status;
    debugPrint('Camera permission status: $cameraStatus');
    if (!cameraStatus.isGranted) {
      final newCameraStatus = await Permission.camera.request();
      debugPrint('Camera request result: $newCameraStatus');
      if (newCameraStatus.isPermanentlyDenied) {
        debugPrint(
            'Camera permanently denied, prompting user to open settings');
        _showPermissionDialog(context: null, permission: 'camera');
        return;
      } else if (newCameraStatus.isGranted) {
        await prefs.setBool(_cameraPermissionKey, true);
      } else {
        debugPrint('Camera permission denied but not permanently');
        return;
      }
    } else {
      await prefs.setBool(_cameraPermissionKey, true);
    }

    final micStatus = await Permission.microphone.status;
    debugPrint('Microphone permission status: $micStatus');
    if (!micStatus.isGranted) {
      final newMicStatus = await Permission.microphone.request();
      debugPrint('Microphone request result: $newMicStatus');
      if (newMicStatus.isPermanentlyDenied) {
        debugPrint(
            'Microphone permanently denied, prompting user to open settings');
        _showPermissionDialog(context: null, permission: 'microphone');
        return;
      } else if (newMicStatus.isGranted) {
        await prefs.setBool(_micPermissionKey, true);
      } else {
        debugPrint('Microphone permission denied but not permanently');
        return;
      }
    } else {
      await prefs.setBool(_micPermissionKey, true);
    }

    debugPrint('Camera and microphone permissions granted.');
  }

  void _showPermissionDialog(
      {required BuildContext? context, required String permission}) {
    // Since this is called from main.dart, context might not be available
    // Use a post-frame callback or handle in a widget if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$permission Permission Denied'),
            content: Text(
                'Please enable $permission permission in settings to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      } else {
        debugPrint('No context available, opening settings directly');
        openAppSettings();
      }
    });
  }
}
