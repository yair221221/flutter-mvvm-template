import 'package:flutter/foundation.dart';
import '../../core/config/firebase_config.dart';
import '../../data/services/wellness_cloud_sync_service.dart';
import '../../domain/entities/wellness_score.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../../domain/usecases/get_wellness_score_usecase.dart';

enum DashboardState { initial, loading, success, permissionRequired, error }

class DashboardViewModel extends ChangeNotifier {
  final GetWellnessScoreUseCase _getWellnessScore;
  final WellnessRepository _repository;

  DashboardViewModel({
    required GetWellnessScoreUseCase getWellnessScore,
    required WellnessRepository repository,
  })  : _getWellnessScore = getWellnessScore,
        _repository = repository;

  DashboardState _state = DashboardState.initial;
  WellnessScore? _score;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  DashboardState get state => _state;
  WellnessScore? get score => _score;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  Future<void> load({DateTime? date}) async {
    _selectedDate = date ?? DateTime.now();
    _state = DashboardState.loading;
    notifyListeners();

    final hasPermission = await _repository.hasUsagePermission();
    if (!hasPermission) {
      _state = DashboardState.permissionRequired;
      notifyListeners();
      return;
    }

    final result = await _getWellnessScore(
      GetWellnessScoreParams(date: _selectedDate),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = DashboardState.error;
      },
      (score) {
        _score = score;
        _state = DashboardState.success;
        // Sync to Firestore so friends can see this score in real time
        if (kFirebaseEnabled) {
          WellnessCloudSyncService.syncScore(score);
        }
      },
    );
    notifyListeners();
  }

  Future<void> grantPermission() async {
    await _repository.requestUsagePermission();
    await load();
  }

  void goToPreviousDay() => load(date: _selectedDate.subtract(const Duration(days: 1)));
  void goToNextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (tomorrow.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      load(date: tomorrow);
    }
  }
}
