import 'package:flutter_bloc/flutter_bloc.dart';
import 'sync_event.dart';
import 'sync_state.dart';
import '../../../domain/use_cases/sync/sync_data.dart';
import '../../../core/utils/app_logger.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncData _syncData;

  SyncBloc({required SyncData syncData})
    : _syncData = syncData,
      super(SyncInitial()) {
    on<SyncRequested>(_onSyncRequested);
    on<SyncStatusChecked>(_onSyncStatusChecked);
    on<PendingOperationsProcessed>(_onPendingOperationsProcessed);
  }

  Future<void> _onSyncRequested(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    try {
      emit(const SyncInProgress());

      final result = await _syncData.execute(
        userId: event.userId,
        force: event.force,
      );

      result.fold(
        (failure) {
          AppLogger.error('SyncBloc: Sync failed', failure);
          emit(SyncError(failure.message));
        },
        (syncResult) {
          AppLogger.info('SyncBloc: Synced ${syncResult.synced} items');
          emit(
            SyncSuccess(
              itemsSynced: syncResult.synced,
              syncedAt: DateTime.now(),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('SyncBloc: Sync error', e, stackTrace);
      emit(SyncError(e.toString()));
    }
  }

  Future<void> _onSyncStatusChecked(
    SyncStatusChecked event,
    Emitter<SyncState> emit,
  ) async {
    // Check pending operations count
    AppLogger.debug('SyncBloc: Checking sync status');
  }

  Future<void> _onPendingOperationsProcessed(
    PendingOperationsProcessed event,
    Emitter<SyncState> emit,
  ) async {
    try {
      emit(const SyncInProgress());

      final result = await _syncData.processPendingOperations();

      result.fold((failure) => emit(SyncError(failure.message)), (count) {
        AppLogger.info('SyncBloc: Processed $count operations');
        emit(SyncSuccess(itemsSynced: count, syncedAt: DateTime.now()));
      });
    } catch (e, stackTrace) {
      AppLogger.error('SyncBloc: Process pending error', e, stackTrace);
      emit(SyncError(e.toString()));
    }
  }
}
