import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;

  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final ValueNotifier<List<ConnectivityResult>> connectionStatus = ValueNotifier<List<ConnectivityResult>>([]);

  void Function(String message)? onConnectionLost;

  /// Initialize the network manager and set up a stream to continually check the connection status.
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Update the connection status and show a toast if there's no internet.
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    connectionStatus.value = result;
    if (result.contains(ConnectivityResult.none)) {
      // TLoaders.customToast(message: 'No Internet Connection');
      onConnectionLost?.call('No Internet Connection');
    }
  }

  // networkManager.onConnectionLost = (message) {
  //     TLoaders.customToast(context: context, message: message);
  // };

  /// Check the internet connection status.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  /// Dispose the connectivity stream.
  void dispose() {
    _connectivitySubscription.cancel();
  }
}
