import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_ble_connection_plugin/watch_ble_connection_plugin.dart';

import '../utilities/constants.dart';
import '../utilities/vibration_manager.dart';

class MainPageController {
  Function? _dayTimeColorsEffect;

  // Configuration
  final _isWakeLockActive = signal(true, debugLabel: "_isWakeLockActive");

  // Spotholes related
  final _connectedOnNavigationPage =
      signal(false, debugLabel: "_connectedOnNavigationPage");
  final _isDeephole = signal(false, debugLabel: "_isDeephole");
  final _spotholeFormattedDistance =
      signal('...', debugLabel: "_spotholeFormattedDistance");
  final _countSpotholesInRoute =
      signal(0, debugLabel: "_countSpotholesInRoute");

  final _isSpotholeClose = signal(false, debugLabel: "_isSpotholeClose");

  late final _alertColor = computed(
    () => _isDeephole.value ? deepHoleAlertColor : regularHoleAlertColor,
    debugLabel: "_alertColor",
  );

  late final _alertContrastColor = computed(
    () => _isDeephole.value
        ? deepHoleAlertContrastColor
        : regularHoleAlertContrastColor,
    debugLabel: "_alertContrastColor",
  );

  final _isDaytimeColorsActive = signal(false);

  // Flash container
  final _showVisualAlert = signal(false, debugLabel: "_showVisualAlert");
  late final _visualAlertBackgroundColor =
      signal(_alertColor.value, debugLabel: "_visualAlertBackgroundColor");
  late final _visualAlertBackgroundContrastColor = signal(
      _alertContrastColor.value,
      debugLabel: "_visualAlertBackgroundContrastColor");

  late final _mainScreenBackgroundColor = signal(_alertColor.value);
  late final _mainScreenBackgroundContrastColor =
      signal(_alertContrastColor.value);

  late final _mainButtonsColor = signal(_alertContrastColor.value);

  // Getters - Spotholes related
  Signal<bool> get isWakeLockActive => _isWakeLockActive;
  Signal<bool> get connectedOnNavigationPage => _connectedOnNavigationPage;
  Signal<bool> get isDeephole => _isDeephole;
  Signal<String> get spotholeFormattedDistance => _spotholeFormattedDistance;
  Signal<int> get countSpotholesInRoute => _countSpotholesInRoute;
  // Computed<bool> get hasSpotholesOsRoute => _hasSpotholesOsRoute;
  Signal<bool> get isSpotholeClose => _isSpotholeClose;

  // Getters - Colors
  Signal<bool> get isDaytimeColorsActive => _isDaytimeColorsActive;
  Computed<Color> get alertColor => _alertColor;
  Computed<Color> get alertContrastColor => _alertContrastColor;
  Signal<Color> get mainScreenBackgroundColor => _mainScreenBackgroundColor;
  Signal<Color> get mainScreenBackgroundContrastColor =>
      _mainScreenBackgroundContrastColor;
  Signal<Color> get mainButtonsColor => _mainButtonsColor;

  // Getters - Flash container
  Signal<bool> get showVisualAlert => _showVisualAlert;
  Signal<Color> get visualAlertBackgroundColor => _visualAlertBackgroundColor;
  Signal<Color> get visualAlertBackgroundContrastColor =>
      _visualAlertBackgroundContrastColor;

  void _startDayTimeColorsEffect() {
    _dayTimeColorsEffect = effect(
      () {
        if (_isDaytimeColorsActive.value) {
          _mainScreenBackgroundColor.value = Colors.black;
          _mainScreenBackgroundContrastColor.value = Colors.white;
          _mainButtonsColor.value = Colors.white;
          _visualAlertBackgroundColor.value = Colors.white;
          _visualAlertBackgroundContrastColor.value = Colors.black;
        } else {
          _mainScreenBackgroundColor.value = _alertColor.value;
          _mainScreenBackgroundContrastColor.value = _alertContrastColor.value;
          _mainButtonsColor.value = _alertContrastColor.value;
          _visualAlertBackgroundColor.value = _alertColor.value;
          _visualAlertBackgroundContrastColor.value = Colors.black;
        }
      },
      debugLabel: "_dayTimeColorsEffect",
    );
  }

  void initState() {
    WakelockPlus.enable();
    _startDayTimeColorsEffect();
    _startBluetoothMessageListener();
  }

  bool isDayTime() {
    final now = DateTime.now();
    return now.hour >= 6 && now.hour < 18;
  }

  void _setDaytimeColors() {
    if (isDayTime()) {
      _isDaytimeColorsActive.value = true;
    }
  }

  void toggleDaytimeColors() {
    _isDaytimeColorsActive.value = !_isDaytimeColorsActive.value;
  }

  void _startBluetoothMessageListener() {
    WatchListener.listenForMessage((data) {
      if (data.containsKey("currentSpotholeDistance")) {
        double distance = data["currentSpotholeDistance"];
        onCurrentSpotholeDistanceChange(distance);
      } else if (data.containsKey("isDeephole")) {
        _isDeephole.value = data["isDeephole"];
      } else if (data.containsKey("countSpotholesInRoute")) {
        _countSpotholesInRoute.value = data["countSpotholesInRoute"];
        _countSpotholesInRoute.value == 0
            ? _stopAlerts()
            : _showVisualAlert.value = true;
      } else if (data.containsKey("connectedOnNavigationPage")) {
        bool isConnectedOnNavigationPage = data["connectedOnNavigationPage"];
        _connectedOnNavigationPage.value = isConnectedOnNavigationPage;
        if (isConnectedOnNavigationPage) {
          _setDaytimeColors();
        } else {
          _stopAlerts();
        }
      }
    });
  }

  void manageVibration(double distance) {
    if (distance < 120) {
      VibrationManager.alertImminentRisk();
    } else if (distance < 200) {
      VibrationManager.alertProximity();
    } else {
      VibrationManager.cancelVibration();
    }
  }

  void _stopAlerts() {
    _showVisualAlert.value = false;
    VibrationManager.cancelVibration();
  }

  void onCurrentSpotholeDistanceChange(double distance) {
    // Manage vibration
    manageVibration(distance);
    // If _isSpotholeClose and _showVisualAlert, starts visual alert, otherwise, close visual alert
    _isSpotholeClose.value = (distance <= 120);

    // Update formatted distance on screen
    if (distance > 1000) {
      final kilometerDistance = distance / 1000;
      _spotholeFormattedDistance.value =
          '${kilometerDistance.toStringAsFixed(1)} km';
    } else {
      _spotholeFormattedDistance.value = '${distance.truncate()} m';
    }
  }

  void toggleWakeLock() {
    if (_isWakeLockActive.value) {
      WakelockPlus.disable();
    } else {
      WakelockPlus.enable();
    }
    _isWakeLockActive.value = !_isWakeLockActive.value;
  }

  double degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  dispose() {
    _stopAlerts();
    _dayTimeColorsEffect!();
  }
}
