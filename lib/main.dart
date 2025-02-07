import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:signals/signals_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_ble_connection_plugin/watch_ble_connection_plugin.dart';
import 'package:wear_plus/wear_plus.dart';

import '../utilities/vibration_manager.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final redAlertColor = const Color(0xFFFF0000);

  final _onRoute = signal(false);
  final _isDeephole = signal(false);
  final _currentSpotholeDistance = signal(0.0);
  final _spotholeFormattedDistance = signal('...');
  final _countSpotholesInRoute = signal(0);
  late final _themeColor =
      computed(() => _isDeephole.value ? Colors.white : Colors.black);
  final _isWakeLockActive = signal(true);
  // final _screenRotationAngle = signal(35.00);

  Function? _startVibrationMonitorAlertDispose;

  @override
  initState() {
    super.initState();
    WakelockPlus.enable();
    _startVibrationMonitorAlert();
    WatchListener.listenForMessage((data) {
      if (data.containsKey("currentSpotholeDistance")) {
        double distance = data["currentSpotholeDistance"];
        onCurrentSpotholeDistanceChange(distance);
      } else if (data.containsKey("isDeephole")) {
        _isDeephole.value = data["isDeephole"];
      } else if (data.containsKey("countSpotholesInRoute")) {
        _countSpotholesInRoute.value = data["countSpotholesInRoute"];
      } else if (data.containsKey("onRoute")) {
        _onRoute.value = data["onRoute"];
      }
    });
  }

  void onCurrentSpotholeDistanceChange(double distance) {
    _currentSpotholeDistance.value = distance;
    if (distance > 1000) {
      final kilometerDistance = distance / 1000;
      _spotholeFormattedDistance.value =
          '${kilometerDistance.toStringAsFixed(1)} km';
    } else {
      _spotholeFormattedDistance.value = '${distance.truncate()} m';
    }
  }

  void _startVibrationMonitorAlert() {
    _startVibrationMonitorAlertDispose = effect(
      () {
        if (_currentSpotholeDistance.value < 100) {
          VibrationManager.alertImminentRisk();
        } else if (_currentSpotholeDistance.value < 200) {
          VibrationManager.alertProximity();
        } else {
          VibrationManager.cancelVibration();
        }
      },
    );
  }

  _toggleWakeLock() {
    if (_isWakeLockActive.value) {
      WakelockPlus.disable();
    } else {
      WakelockPlus.enable();
    }
    _isWakeLockActive.value = !_isWakeLockActive.value;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  @override
  void dispose() {
    _startVibrationMonitorAlertDispose!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => MaterialApp(
        home: AmbientMode(
          builder: (context, mode, child) {
            return Transform.rotate(
              angle: _degreesToRadians(30),
              child: Watch(
                (_) => _onRoute.value
                    ? mode == WearMode.active
                        ? Watch(
                            (_) => _countSpotholesInRoute.value == 0
                                ? Scaffold(
                                    backgroundColor: Colors.black,
                                    body: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/images/markholes_thumbs_up.png',
                                              width: 75,
                                              height: 75),
                                          Text(
                                            'Tudo OK, não há alertas na rota',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Scaffold(
                                    backgroundColor: _isDeephole.value
                                        ? redAlertColor
                                        : Colors.yellow,
                                    body: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _isDeephole.value
                                              ? Tooltip(
                                                  message:
                                                      "Buraco acentuado, atenção!",
                                                  child: Image.asset(
                                                      'assets/images/pothole_red_sign.png',
                                                      width: 40,
                                                      height: 40),
                                                )
                                              : Tooltip(
                                                  message:
                                                      "Buraco ou pista irregular",
                                                  child: Image.asset(
                                                      'assets/images/pothole_sign.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                          if (_countSpotholesInRoute.value > 0)
                                            Tooltip(
                                              message:
                                                  "Distância do próximo risco",
                                              child: Text(
                                                _spotholeFormattedDistance
                                                    .value,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                      color: _themeColor.value,
                                                    ),
                                              ),
                                            ),
                                          Tooltip(
                                            message: "Total de alertas na rota",
                                            child: Text(
                                              _countSpotholesInRoute.value == 1
                                                  ? '${_countSpotholesInRoute.value} alerta'
                                                  : '${_countSpotholesInRoute.value} alertas',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    color: _themeColor.value,
                                                  ),
                                            ),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Watch(
                                                  (_) => Tooltip(
                                                    message: _isWakeLockActive
                                                            .value
                                                        ? 'Desativar tela sempre ativa'
                                                        : 'Ativar tela sempre ativa',
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          _toggleWakeLock(),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8),
                                                        minimumSize:
                                                            const Size(4, 4),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          // side: const BorderSide(width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                      ),
                                                      child: !_isWakeLockActive
                                                              .value
                                                          ? Icon(
                                                              Icons
                                                                  .screen_lock_portrait,
                                                              color: _themeColor
                                                                  .value)
                                                          : Stack(
                                                              // alignment: Alignment.center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .screen_lock_portrait,
                                                                  color:
                                                                      _themeColor
                                                                          .value,
                                                                ),
                                                                Icon(
                                                                  Icons.close,
                                                                  color:
                                                                      _themeColor
                                                                          .value,
                                                                ),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                Watch(
                                                  (_) => Tooltip(
                                                    message: VibrationManager
                                                            .isVibrationActive
                                                            .value
                                                        ? 'Desativar alerta por vibração'
                                                        : 'Ativar alerta por vibração',
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          VibrationManager
                                                              .toggleVibrationAlert(),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8),
                                                        minimumSize:
                                                            const Size(4, 4),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          // side: const BorderSide(width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                      ),
                                                      child: VibrationManager
                                                              .isVibrationActive
                                                              .value
                                                          ? Icon(
                                                              Icons.vibration,
                                                              color: _themeColor
                                                                  .value)
                                                          : Stack(
                                                              // alignment: Alignment.center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .vibration,
                                                                    color: _themeColor
                                                                        .value),
                                                                Icon(
                                                                    Icons.close,
                                                                    color: _themeColor
                                                                        .value),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                // TODO: [test dev] botão para testar a vibração
                                                ElevatedButton(
                                                  onPressed: () {
                                                    for (int i = 0;
                                                        i < 10;
                                                        i++) {
                                                      Vibration.vibrate(
                                                        amplitude: 255,
                                                        pattern: [
                                                          0,
                                                          500,
                                                          100,
                                                          200,
                                                          100,
                                                          200
                                                        ],
                                                      );
                                                      Future.delayed(
                                                        const Duration(
                                                          seconds: 1,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                    minimumSize:
                                                        const Size(4, 4),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                      Icons
                                                          .text_snippet_outlined,
                                                      color: _themeColor.value),
                                                ),
                                              ]),
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        : Scaffold(
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Spotholes\nModo Econômico',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.blueGrey,
                                        ),
                                  ),
                                  const Icon(
                                    Icons.battery_saver,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                            ),
                          )
                    : mode == WearMode.active
                        ? Scaffold(
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.route,
                                          color: Colors.blueGrey,
                                        ),
                                        Icon(
                                          Icons.smartphone,
                                          color: Colors.blueGrey,
                                        ),
                                      ]),
                                  Text(
                                    'Inicie uma rota no app spotholes android',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.blueGrey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Scaffold(
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Spotholes\nModo Econômico',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.blueGrey,
                                        ),
                                  ),
                                  const Icon(
                                    Icons.battery_saver,
                                    color: Colors.blueGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            );
          },
        ),
      ),
    );
  }
}
