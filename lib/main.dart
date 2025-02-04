import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_ble_connection_plugin/watch_ble_connection_plugin.dart';

import 'package:wear_plus/wear_plus.dart';

import '../utilities/vibration_manager.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _onRoute = signal(false);
  final _isDeephole = signal(false);
  final _currentSpotholeDistance = signal(0.0);
  final _spotholeFormattedDistance = signal('...');
  final _countSpotholesInRoute = signal(0);
  late final _themeColor =
      computed(() => _isDeephole.value ? Colors.white : Colors.black);

  Function? _startVibrationMonitorAlertDispose;

  @override
  initState() {
    super.initState();
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
          // WakelockPlus.enable();
          VibrationManager.alertProximity();
        } else {
          // WakelockPlus.disable();
          VibrationManager.cancelVibration();
        }
      },
    );
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
            return Watch(
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
                                      ? const Color.fromARGB(255, 255, 0, 0)
                                      : Colors.yellow,
                                  body: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _isDeephole.value
                                            ? Image.asset(
                                                'assets/images/pothole_red_sign.png',
                                                width: 40,
                                                height: 40)
                                            : Image.asset(
                                                'assets/images/pothole_sign.png',
                                                width: 40,
                                                height: 40),
                                        if (_countSpotholesInRoute.value > 0)
                                          Text(
                                            _spotholeFormattedDistance.value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  color: _themeColor.value,
                                                ),
                                          ),
                                        Text(
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
                                        Watch(
                                          (_) => Tooltip(
                                            message: VibrationManager
                                                    .isVibrationActive.value
                                                ? 'Desativar alerta por vibração'
                                                : 'Ativar alerta por vibração',
                                            child: ElevatedButton(
                                              onPressed: () => VibrationManager
                                                  .toggleVibrationAlert(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                minimumSize: const Size(4, 4),
                                                shape: RoundedRectangleBorder(
                                                  // side: const BorderSide(width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: VibrationManager
                                                      .isVibrationActive.value
                                                  ? Icon(Icons.vibration,
                                                      color: _themeColor.value)
                                                  : Stack(
                                                      // alignment: Alignment.center,
                                                      children: [
                                                        Icon(
                                                            Icons.phone_android,
                                                            color: _themeColor
                                                                .value),
                                                        Icon(Icons.close,
                                                            color: _themeColor
                                                                .value),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
            );
          },
        ),
      ),
    );
  }
}
