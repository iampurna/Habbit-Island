import 'package:dartz/dartz.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Delete Habit Use Case
/// Soft deletes a habit (marks as inactive)

class DeleteHabit {
  final HabitRepository repository;

  DeleteHabit(this.repository);

  Future<Either<Failure, void>> execute({
    required String habitId,
    bool hardDelete = false,
  }) async {
    try {
      AppLogger.debug(
        'DeleteHabit: Deleting habit $habitId (hard: $hardDelete)',
      );

      final result = hardDelete
          ? await repository.hardDeleteHabit(habitId)
          : await repository.deleteHabit(habitId);

      return result.fold(
        (failure) {
          AppLogger.warning('DeleteHabit: Failed - ${failure.message}');
          return Left(failure);
        },
        (_) {
          AppLogger.info('DeleteHabit: Success - Habit $habitId deleted');
          return const Right(null);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('DeleteHabit: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
