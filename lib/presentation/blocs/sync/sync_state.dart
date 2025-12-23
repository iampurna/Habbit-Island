import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final int? progress;

  const SyncInProgress({this.progress});

  @override
  List<Object?> get props => [progress];
}

class SyncSuccess extends SyncState {
  final int itemsSynced;
  final DateTime syncedAt;

  const SyncSuccess({required this.itemsSynced, required this.syncedAt});

  @override
  List<Object> get props => [itemsSynced, syncedAt];
}

class SyncPending extends SyncState {
  final int pendingCount;

  const SyncPending(this.pendingCount);

  @override
  List<Object> get props => [pendingCount];
}

class SyncError extends SyncState {
  final String message;

  const SyncError(this.message);

  @override
  List<Object> get props => [message];
}
