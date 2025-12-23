import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Resolve Conflicts Use Case
/// Handles data conflicts between local and remote versions

enum ConflictResolutionStrategy { localWins, remoteWins, newestWins, merge }

class ResolveConflicts {
  Future<Either<Failure, ConflictResolutionResult>> execute({
    required ConflictResolutionStrategy strategy,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required String entityType,
  }) async {
    try {
      AppLogger.debug('ResolveConflicts: Resolving $entityType conflict');

      Map<String, dynamic> resolvedData;

      switch (strategy) {
        case ConflictResolutionStrategy.localWins:
          resolvedData = localData;
          AppLogger.debug('ResolveConflicts: Local data wins');
          break;

        case ConflictResolutionStrategy.remoteWins:
          resolvedData = remoteData;
          AppLogger.debug('ResolveConflicts: Remote data wins');
          break;

        case ConflictResolutionStrategy.newestWins:
          resolvedData = _resolveNewestWins(localData, remoteData);
          AppLogger.debug('ResolveConflicts: Newest data wins');
          break;

        case ConflictResolutionStrategy.merge:
          resolvedData = _mergeData(localData, remoteData);
          AppLogger.debug('ResolveConflicts: Data merged');
          break;
      }

      return Right(
        ConflictResolutionResult(
          resolvedData: resolvedData,
          strategy: strategy,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'ResolveConflicts: Error resolving conflict',
        e,
        stackTrace,
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Map<String, dynamic> _resolveNewestWins(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
  ) {
    // Compare updatedAt timestamps
    final localUpdated = DateTime.tryParse(
      localData['updatedAt']?.toString() ?? '',
    );
    final remoteUpdated = DateTime.tryParse(
      remoteData['updatedAt']?.toString() ?? '',
    );

    if (localUpdated == null && remoteUpdated == null) {
      return remoteData; // Default to remote if no timestamps
    }

    if (localUpdated == null) return remoteData;
    if (remoteUpdated == null) return localData;

    return localUpdated.isAfter(remoteUpdated) ? localData : remoteData;
  }

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
  ) {
    // Merge strategy: Take non-null values from both
    // Prefer remote for conflicts except user-modifiable fields
    final merged = Map<String, dynamic>.from(remoteData);

    // User-modifiable fields prefer local
    const localPreferredFields = [
      'name',
      'description',
      'isActive',
      'reminderTime',
    ];

    for (final field in localPreferredFields) {
      if (localData.containsKey(field) && localData[field] != null) {
        merged[field] = localData[field];
      }
    }

    // Numerical fields: take maximum
    const maxFields = ['totalCompletions', 'longestStreak', 'totalXp'];

    for (final field in maxFields) {
      final localValue = localData[field] as int?;
      final remoteValue = remoteData[field] as int?;

      if (localValue != null && remoteValue != null) {
        merged[field] = localValue > remoteValue ? localValue : remoteValue;
      } else if (localValue != null) {
        merged[field] = localValue;
      }
    }

    return merged;
  }
}

class ConflictResolutionResult {
  final Map<String, dynamic> resolvedData;
  final ConflictResolutionStrategy strategy;

  ConflictResolutionResult({
    required this.resolvedData,
    required this.strategy,
  });
}
