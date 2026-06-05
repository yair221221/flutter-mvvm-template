import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/wellness_score.dart';
import '../repositories/wellness_repository.dart';

class GetWellnessScoreParams {
  final DateTime date;
  const GetWellnessScoreParams({required this.date});
}

class GetWellnessScoreUseCase
    implements UseCase<WellnessScore, GetWellnessScoreParams> {
  final WellnessRepository repository;
  GetWellnessScoreUseCase(this.repository);

  @override
  Future<Either<Failure, WellnessScore>> call(
      GetWellnessScoreParams params) {
    return repository.getWellnessScore(params.date);
  }
}
