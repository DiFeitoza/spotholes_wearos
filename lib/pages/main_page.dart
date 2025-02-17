import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spotholes_wearos/pages/screens/visual_alert_screen.dart';
import 'package:wear_plus/wear_plus.dart';

import '../controllers/main_page_controller.dart';
import 'screens/connection_screen.dart';
import 'screens/economic_mode_screen.dart';
import 'screens/main_screen.dart';
import 'screens/no_spotholes_on_route_screen.dart';

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
  late final _countSpotholesInRoute = _mainPageController.countSpotholesInRoute;
  late final _isSpotholeClose = _mainPageController.isSpotholeClose;

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
                              ? const NoSpotholesOnRouteScreen()
                              : Watch(
                                  (_) => Stack(
                                    children: [
                                      if (!(_showVisualAlert.value &&
                                          _isSpotholeClose.value))
                                        MainScreen(
                                          mainPageController:
                                              _mainPageController,
                                        ),
                                      if (_showVisualAlert.value &&
                                          _isSpotholeClose.value)
                                        VisualAlertScreen(
                                          mainPageController:
                                              _mainPageController,
                                        )
                                    ],
                                  ),
                                )
                          : const EconomicModeScreen()
                      : mode == WearMode.active
                          ? const ConnectionScreen()
                          : const EconomicModeScreen(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
