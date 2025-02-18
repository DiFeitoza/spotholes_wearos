import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:spotholes_wearos/utilities/constants.dart';
import 'package:vibration/vibration.dart';

import '../controllers/main_page_controller.dart';
import '../utilities/vibration_manager.dart';

class MainPageButtons extends StatefulWidget {
  final MainPageController mainPageController;

  const MainPageButtons({super.key, required this.mainPageController});

  @override
  State<MainPageButtons> createState() => _MainPageButtonsState();
}

class _MainPageButtonsState extends State<MainPageButtons> {
  late final _mainPageController = widget.mainPageController;

  late final _isWakeLockActive = _mainPageController.isWakeLockActive;
  late final _isDaytimeColorsActive = _mainPageController.isDaytimeColorsActive;
  late final _mainButtonsColor = _mainPageController.mainButtonsColor;

  _toggleWakeLock() {
    _mainPageController.toggleWakeLock();
  }

  Watch _wakeLockToggleButton() {
    return Watch(
      (_) => Tooltip(
        message: _isWakeLockActive.value
            ? 'Desativar tela sempre ativa'
            : 'Ativar tela sempre ativa',
        child: ElevatedButton(
          onPressed: () => _toggleWakeLock(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(4, 4),
            shape: RoundedRectangleBorder(
              // side: const BorderSide(width: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: !_isWakeLockActive.value
              ? Icon(Icons.screen_lock_portrait, color: _mainButtonsColor.value)
              : Stack(
                  // alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.screen_lock_portrait,
                      color: _mainButtonsColor.value,
                    ),
                    Icon(
                      Icons.close,
                      color: _mainButtonsColor.value,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Watch _vibrationToggleButton() {
    return Watch(
      (_) => Tooltip(
        message: VibrationManager.isVibrationActive.value
            ? 'Desativar alerta por vibração'
            : 'Ativar alerta por vibração',
        child: ElevatedButton(
          onPressed: () => VibrationManager.toggleVibrationAlert(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(4, 4),
            shape: RoundedRectangleBorder(
              // side: const BorderSide(width: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: VibrationManager.isVibrationActive.value
              ? Icon(Icons.vibration, color: _mainButtonsColor.value)
              : Stack(
                  // alignment: Alignment.center,
                  children: [
                    Icon(Icons.vibration, color: _mainButtonsColor.value),
                    Icon(Icons.close, color: _mainButtonsColor.value),
                  ],
                ),
        ),
      ),
    );
  }

  Watch _vibrationTestButton() {
    // TODO: [test dev] botão para testar a vibração
    return Watch(
      (_) => ElevatedButton(
        onPressed: () async {
          await Vibration.vibrate(
            amplitude: 255,
            pattern: vibratePatternLongShortShort,
          );
          await Future.delayed(const Duration(seconds: 3));
          await Vibration.vibrate(
            amplitude: 255,
            pattern: vibratePatternTocTocToc,
          );
          await Future.delayed(const Duration(seconds: 3));
          await Vibration.vibrate(
            amplitude: 255,
            pattern: vibratePatternBonkBonkBonk,
          );
          await Future.delayed(const Duration(seconds: 3));
          await Vibration.vibrate(
            amplitude: 255,
            pattern: vibratePatternIntenseBonkBonkBonk,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(4, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Watch(
          (_) => Icon(
            Icons.text_snippet_outlined,
            color: _mainButtonsColor.value,
          ),
        ),
      ),
    );
  }

  Watch _contrastColorToggleButton() {
    return Watch(
      (_) => Tooltip(
        message: _isDaytimeColorsActive.value
            ? 'Ativar contraste noturno'
            : 'Ativar contraste diurno',
        child: ElevatedButton(
          onPressed: () => _mainPageController.toggleDaytimeColors(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(4, 4),
            shape: RoundedRectangleBorder(
              // side: const BorderSide(width: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isDaytimeColorsActive.value
              ? Icon(Icons.light_mode, color: _mainButtonsColor.value)
              : Stack(
                  children: [
                    Icon(Icons.dark_mode, color: _mainButtonsColor.value),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Watch build(BuildContext context) {
    return Watch(
      (_) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wakeLockToggleButton(),
          _vibrationToggleButton(),
          _contrastColorToggleButton(),
          _vibrationTestButton(),
        ],
      ),
    );
  }
}
