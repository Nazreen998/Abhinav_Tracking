import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebLocationHelper {
  /// Check if browser has BLOCKED geolocation
  static Future<bool> isLocationBlocked() async {
    try {
      final permissions = html.window.navigator.permissions;
      if (permissions == null) return false;

      final status = await permissions.query({"name": "geolocation"});
      return status.state == "denied";
    } catch (e) {
      print("Web permission check error: $e");
      return false;
    }
  }

  /// Open Chrome location settings tab
  static void openLocationSettings() {
    html.window.open("chrome://settings/content/location", "_blank");
  }

  /// Dialog to tell user what to do
  static void showLocationBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Blocked"),
        content: const Text(
          "Your browser has blocked location access for this site.\n\n"
          "Please enable location in Chrome settings and then reload the page.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              openLocationSettings();
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
