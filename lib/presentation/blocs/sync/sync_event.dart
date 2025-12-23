import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class SyncRequested extends SyncEvent {
  final String userId;
  final bool force;

  const SyncRequested({required this.userId, this.force = false});

  @override
  List<Object> get props => [userId, force];
}

class SyncStatusChecked extends SyncEvent {}

class PendingOperationsProcessed extends SyncEvent {}

class AutoSyncEnabled extends SyncEvent {
  final bool enabled;

  const AutoSyncEnabled(this.enabled);

  @override
  List<Object> get props => [enabled];
}
