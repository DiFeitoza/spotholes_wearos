import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spotholes_wearos/pages/screens/visual_alert_screen.dart';
import 'package:spotholes_wearos/widgets/main_page_buttons.dart';
import 'package:wear_plus/wear_plus.dart';

import '../controllers/main_page_controller.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _mainPageController = MainPageController();

  // Spotholes related
  late final _connectedOnNavigationPage =
      _mainPageController.connectedOnNavigationPage;
  late final _isDeephole = _mainPageController.isDeephole;
  late final _spotholeFormattedDistance =
      _mainPageController.spotholeFormattedDistance;
  late final _countSpotholesInRoute = _mainPageController.countSpotholesInRoute;
  late final _isSpotholeClose = _mainPageController.isSpotholeClose;

  // Colors
  late final _contrastAlertColor = _mainPageController.contrastAlertColor;
  late final _alertColor = _mainPageController.alertColor;

  // Flash container
  late final _showVisualAlert = _mainPageController.showVisualAlert;

  @override
  initState() {
    super.initState();
    _mainPageController.initState();
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    super.dispose();
  }

  Widget connectionScreen() {
    return Scaffold(
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
              ],
            ),
            Text(
              'Inicie uma rota no app spotholes android',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.blueGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget economicModeScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spotholes\nModo Econômico',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
    );
  }

  Widget noSpotholesOnRouteScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/markholes_thumbs_up.png',
              width: 75,
              height: 75,
            ),
            Text(
              'Tudo OK, não há alertas na rota',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Watch mainScreen() {
    return Watch(
      (_) => Scaffold(
        backgroundColor: _alertColor.value,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Watch(
                (_) => Tooltip(
                  message: _isDeephole.value
                      ? "Buraco acentuado, atenção!"
                      : "Buraco ou pista irregular",
                  child: Image.asset(
                      _isDeephole.value
                          ? 'assets/images/pothole_red_sign.png'
                          : 'assets/images/pothole_sign.png',
                      width: 40,
                      height: 40),
                ),
              ),
              Watch(
                (_) => Tooltip(
                  message: "Distância do próximo risco",
                  child: Watch(
                    (_) => Text(
                      _spotholeFormattedDistance.value,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: _contrastAlertColor.value,
                          ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: "Total de alertas na rota",
                child: Watch(
                  (_) => Text(
                    _countSpotholesInRoute.value == 1
                        ? '${_countSpotholesInRoute.value} alerta'
                        : '${_countSpotholesInRoute.value} alertas',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: _contrastAlertColor.value,
                        ),
                  ),
                ),
              ),
              MainPageButtons(mainPageController: _mainPageController),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AmbientMode(
        builder: (context, mode, child) {
          return Transform.rotate(
            angle: _mainPageController.degreesToRadians(30),
            child: Stack(
              children: [
                Watch(
                  (_) => _connectedOnNavigationPage.value
                      ? mode == WearMode.active
                          ? (_countSpotholesInRoute.value == 0)
                              ? noSpotholesOnRouteScreen()
                              : Watch(
                                  (_) => Stack(
                                    children: [
                                      if (!(_showVisualAlert.value &&
                                          _isSpotholeClose.value))
                                        mainScreen(),
                                      if (_showVisualAlert.value &&
                                          _isSpotholeClose.value)
                                        VisualAlertScreen(
                                          mainPageController:
                                              _mainPageController,
                                        )
                                    ],
                                  ),
                                )
                          : economicModeScreen()
                      : mode == WearMode.active
                          ? connectionScreen()
                          : economicModeScreen(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
