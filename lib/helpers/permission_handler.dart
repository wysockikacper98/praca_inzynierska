import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

Future<ph.PermissionStatus> locationPermissions() async {
  return ph.Permission.locationWhenInUse.request();
}

AlertDialog buildAlertDialogForPermissionsPermanentlyDenied(
  BuildContext context,
) {
  return AlertDialog(
    title: const Text('Uprawnienia wyłączone'),
    content: const Text(
        'Uprawnienia do lokalizacji zostały wyłączone, aby skorzytać z tej funkcjonalności musisz je włączyć.'),
    actions: [
      TextButton(
        child: const Text('Anuluj'),
        onPressed: Navigator.of(context).pop,
      ),
      TextButton(
        child: const Text('Włącz'),
        onPressed: () {
          ph.openAppSettings();
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
