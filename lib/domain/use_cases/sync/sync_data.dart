import 'package:dartz/dartz.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Sync Data Use Case
/// Orchestrates full data synchronization between local and remote

class SyncData {
  final SyncRepository repository;

  SyncData(this.repository);

  Future<Either<Failure, SyncResult>> execute({
    required String userId,
    bool force = false,
  }) async {
    try {
      AppLogger.info('SyncData: Starting sync for user $userId');

      // Check sync status
      if (!force) {
        final statusResult = await repository.getSyncStatus();
        if (statusResult.isRight()) {
          final status = (statusResult as Right).value;
          if (status == 'synced') {
            AppLogger.debug('SyncData: Already synced, skipping');
            return Right(SyncResult(synced: 0, pending: 0, failed: 0));
          }
        }
      }

      // Get pending operations count
      final pendingResult = await repository.getPendingCount();
      final pendingCount = pendingResult.fold((_) => 0, (count) => count);

      // Perform full sync
      final syncResult = await repository.fullSync(userId);

      return syncResult.fold(
        (failure) {
          AppLogger.error('SyncData: Sync failed', failure);
          return Left(failure);
        },
        (_) {
          AppLogger.info(
            'SyncData: Sync completed - $pendingCount items synced',
          );
          return Right(SyncResult(synced: pendingCount, pending: 0, failed: 0));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('SyncData: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Process sync queue explicitly
  Future<Either<Failure, int>> processPendingOperations() async {
    try {
      AppLogger.debug('SyncData: Processing pending operations');

      final result = await repository.processSyncQueue();

      return result.fold((failure) => Left(failure), (count) {
        AppLogger.info('SyncData: Processed $count operations');
        return Right(count);
      });
    } catch (e, stackTrace) {
      AppLogger.error('SyncData: Error processing queue', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class SyncResult {
  final int synced;
  final int pending;
  final int failed;

  SyncResult({
    required this.synced,
    required this.pending,
    required this.failed,
  });
}
