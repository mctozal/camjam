import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestPermissions() async {
    // Check current camera permission status
    if (!(await Permission.camera.isGranted)) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        openAppSettings(); // Redirect the user to settings if permission is permanently denied
        return;
      }
    }

    // Check current microphone permission status
    if (!(await Permission.microphone.isGranted)) {
      final micStatus = await Permission.microphone.request();
      if (micStatus.isPermanentlyDenied) {
        openAppSettings(); // Redirect the user to settings if permission is permanently denied
        return;
      }
    }

    // Both permissions are granted or already available
    debugPrint('Camera and microphone permissions granted.');
  }
}
