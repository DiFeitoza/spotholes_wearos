import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../controllers/main_page_controller.dart';
import '../../widgets/main_page_buttons.dart';

class MainScreen extends StatefulWidget {
  final MainPageController mainPageController;
  const MainScreen({super.key, required this.mainPageController});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final _mainPageController = widget.mainPageController;

  // Spotholes related
  late final _isDeephole = _mainPageController.isDeephole;
  late final _spotholeFormattedDistance =
      _mainPageController.spotholeFormattedDistance;
  late final _countSpotholesInRoute = _mainPageController.countSpotholesInRoute;

  // Colors
  late final _mainScreenBackgroundColor =
      _mainPageController.mainScreenBackgroundColor;
  late final _mainScreenBackgroundContrastColor =
      _mainPageController.mainScreenBackgroundContrastColor;

  @override
  Watch build(BuildContext context) {
    return Watch(
      (_) => Scaffold(
        backgroundColor: _mainScreenBackgroundColor.value,
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
                            color: _mainScreenBackgroundContrastColor.value,
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
                          color: _mainScreenBackgroundContrastColor.value,
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
}
