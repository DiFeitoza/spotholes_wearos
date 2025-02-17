import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../controllers/main_page_controller.dart';

class VisualAlertScreen extends StatefulWidget {
  final MainPageController mainPageController;
  const VisualAlertScreen({super.key, required this.mainPageController});

  @override
  State<VisualAlertScreen> createState() => _VisualAlertScreenState();
}

class _VisualAlertScreenState extends State<VisualAlertScreen> {
  late final _mainPageController = widget.mainPageController;

  late final _showVisualAlert = _mainPageController.showVisualAlert;
  late final _flashBackgroundColor = _mainPageController.flashBackgroundColor;
  late final _isDeephole = _mainPageController.isDeephole;
  late final _alertColor = _mainPageController.alertColor;

  Timer? _timer;

  @override
  void initState() {
    startColorFlashing();
    super.initState();
  }

  void startColorFlashing() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) {
        _flashBackgroundColor.value =
            _flashBackgroundColor.value == _alertColor.value
                ? Colors.black
                : _alertColor.value;
      },
    );
  }

  void stopColorFlashing() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopColorFlashing();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Scaffold(
        backgroundColor: _flashBackgroundColor.value,
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
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showVisualAlert.value = false,
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(4, 4),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
