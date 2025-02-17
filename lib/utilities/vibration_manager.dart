import 'package:signals/signals.dart';
import 'package:spotholes_wearos/utilities/constants.dart';
import 'package:vibration/vibration.dart';

/// A manager class for handling vibration alerts on the device.
///
/// This class provides methods to check if the device supports vibration,
/// and to trigger different vibration patterns for proximity and imminent risk alerts.
/// It also allows cancelling any active vibrations.
class VibrationManager {
  /// Indicates whether the proximity alert is currently active.
  static bool isProximityAlertActive = false;

  /// Indicates whether the imminent risk alert is currently active.
  static bool isImminentRiskAlertActive = false;

  /// Indicates whether vibration is currently active.
  static final isVibrationActive = signal(true);

  static void toggleVibrationAlert() =>
      isVibrationActive.value = !isVibrationActive.value;

  /// Checks if the device supports vibration.
  ///
  /// Returns a [Future] that completes with `true` if the device has a vibrator,
  /// otherwise `false`.
  static Future<bool> isVibrationAvailable() async {
    return await Vibration.hasVibrator();
  }

  /// Triggers a vibration pattern for proximity alert.
  static Future<void> alertProximity() async {
    if (isVibrationActive.value &&
        await isVibrationAvailable() &&
        !isProximityAlertActive) {
      if (await Vibration.hasAmplitudeControl()) {
        Vibration.vibrate(
          amplitude: 255,
          pattern: vibratePatternLongShortShort,
        );
      } else {
        Vibration.vibrate(pattern: vibratePatternLongShortShort);
      }
    }
  }

  /// Triggers a vibration pattern for imminent risk alert.
  static Future<void> alertImminentRisk() async {
    if (isVibrationActive.value &&
        await isVibrationAvailable() &&
        !isImminentRiskAlertActive) {
      if (await Vibration.hasAmplitudeControl()) {
        Vibration.vibrate(
          amplitude: 255,
          pattern: vibratePatternIntenseBonkBonkBonk,
        );
      } else {
        Vibration.vibrate(
          pattern: vibratePatternIntenseBonkBonkBonk,
        );
      }
    }
  }

  /// Cancels any active vibration.
  ///
  /// This method checks if the device supports vibration and if either the proximity
  /// alert or the imminent risk alert is active before cancelling the vibration.
  /// It also resets the alert active flags to `false`.
  static Future<void> cancelVibration() async {
    if (await isVibrationAvailable() &&
        (isProximityAlertActive || isImminentRiskAlertActive)) {
      Vibration.cancel();
      isProximityAlertActive = false;
      isImminentRiskAlertActive = false;
    }
  }
}
