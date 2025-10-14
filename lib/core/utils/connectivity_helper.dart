import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityHelper {
  /// Check if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Check if the device can reach Firebase servers
  static Future<bool> canReachFirebase() async {
    try {
      final result = await InternetAddress.lookup('firebase.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Firebase connectivity: $e');
      }
      return false;
    }
  }

  /// Get a user-friendly connectivity status message
  static Future<String> getConnectivityStatus() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return 'No internet connection. Please check your network settings.';
    }

    final canReachFirebase = await ConnectivityHelper.canReachFirebase();
    if (!canReachFirebase) {
      return 'Cannot reach Firebase servers. Please try again later.';
    }

    return 'Connection is good';
  }
}
