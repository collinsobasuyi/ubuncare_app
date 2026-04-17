import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepTrackerService {
  late Stream<StepCount> _stepCountStream;
  int _baseStepCount = 0;
  int stepsToday = 0;
  DateTime? _lastReset;
  Function(int)? _onStepsChanged;
  bool _isInitialized = false;

  /// Initialize the step stream and listen for updates.
  Future<void> initialize(Function(int) onStepsChanged) async {
    _onStepsChanged = onStepsChanged;

    try {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        debugPrint('Activity recognition permission denied');
        _onStepsChanged?.call(-1);
        return;
      }

      _stepCountStream = Pedometer.stepCountStream;

      _stepCountStream.listen((StepCount event) {
        final now = DateTime.now();

        if (_lastReset == null || now.day != _lastReset!.day) {
          _baseStepCount = event.steps;
          _lastReset = now;
          debugPrint('Step counter reset for new day. Base: $_baseStepCount');
        }

        final newSteps = (event.steps - _baseStepCount).clamp(0, 999999);

        if (newSteps != stepsToday) {
          stepsToday = newSteps;
          _onStepsChanged?.call(stepsToday);
        }

        _isInitialized = true;
      }, onError: (error) {
        debugPrint('Pedometer stream error: $error');
        _onStepsChanged?.call(-2);
      }, onDone: () {
        debugPrint('Pedometer stream closed');
      });
    } catch (e) {
      debugPrint('Failed to initialize pedometer: $e');
      _onStepsChanged?.call(-3);
    }
  }

  int get currentSteps => stepsToday;
  bool get isReady => _isInitialized;

  Future<void> refresh() async {
    _onStepsChanged?.call(stepsToday);
  }
}
