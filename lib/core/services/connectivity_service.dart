import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamController<bool> _connectionStatusController =
      StreamController.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    _connectionStatusController.add(_isOnline);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      _isOnline = result != ConnectivityResult.none;
      _connectionStatusController.add(_isOnline);
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
