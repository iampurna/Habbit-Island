import 'dart:convert';
import 'package:habbit_island/core/errors/exceptions.dart';

import 'hive_database.dart';

/// Sync Queue Local Data Source
/// Manages offline operations queue for eventual sync
/// Reference: Technical Addendum §2.3 (Offline Queue Management)

class SyncQueueLocalDataSource {
  final HiveDatabase _hiveDb;

  SyncQueueLocalDataSource(this._hiveDb);

  /// Add operation to sync queue
  Future<String> addToQueue(SyncOperation operation) async {
    try {
      final box = _hiveDb.syncQueue;
      final id = operation.id;
      final jsonString = jsonEncode(operation.toJson());
      await box.put(id, jsonString);
      return id;
    } catch (e) {
      throw CacheException('Failed to add to sync queue: $e');
    }
  }

  /// Get all pending operations
  Future<List<SyncOperation>> getAllPending() async {
    try {
      final box = _hiveDb.syncQueue;
      final operations = <SyncOperation>[];

      for (final key in box.keys) {
        final jsonString = box.get(key) as String;
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final operation = SyncOperation.fromJson(json);

        if (operation.status == SyncStatus.pending) {
          operations.add(operation);
        }
      }

      // Sort by timestamp (oldest first)
      operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return operations;
    } catch (e) {
      throw CacheException('Failed to get pending operations: $e');
    }
  }

  /// Get operation by ID
  Future<SyncOperation?> getOperation(String id) async {
    try {
      final box = _hiveDb.syncQueue;
      final jsonString = box.get(id) as String?;

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncOperation.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get operation: $e');
    }
  }

  /// Update operation status
  Future<void> updateOperationStatus(
    String id,
    SyncStatus status, {
    String? error,
    int? retryCount,
  }) async {
    try {
      final operation = await getOperation(id);
      if (operation == null) {
        throw NotFoundException('Operation not found: $id');
      }

      final updatedOperation = operation.copyWith(
        status: status,
        error: error,
        retryCount: retryCount,
        lastAttemptAt: DateTime.now(),
      );

      final box = _hiveDb.syncQueue;
      final jsonString = jsonEncode(updatedOperation.toJson());
      await box.put(id, jsonString);
    } catch (e) {
      throw CacheException('Failed to update operation status: $e');
    }
  }

  /// Mark operation as synced
  Future<void> markAsSynced(String id) async {
    try {
      await updateOperationStatus(id, SyncStatus.synced);
    } catch (e) {
      throw CacheException('Failed to mark as synced: $e');
    }
  }

  /// Mark operation as failed
  Future<void> markAsFailed(String id, String error) async {
    try {
      final operation = await getOperation(id);
      if (operation == null) return;

      await updateOperationStatus(
        id,
        SyncStatus.failed,
        error: error,
        retryCount: operation.retryCount + 1,
      );
    } catch (e) {
      throw CacheException('Failed to mark as failed: $e');
    }
  }

  /// Remove operation from queue
  Future<void> removeOperation(String id) async {
    try {
      final box = _hiveDb.syncQueue;
      await box.delete(id);
    } catch (e) {
      throw CacheException('Failed to remove operation: $e');
    }
  }

  /// Clear synced operations (older than 7 days)
  Future<void> clearSynced() async {
    try {
      final box = _hiveDb.syncQueue;
      final keysToDelete = <String>[];
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

      for (final key in box.keys) {
        final jsonString = box.get(key) as String;
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final operation = SyncOperation.fromJson(json);

        if (operation.status == SyncStatus.synced &&
            operation.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(key as String);
        }
      }

      await box.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException('Failed to clear synced operations: $e');
    }
  }

  /// Clear failed operations (older than 30 days)
  Future<void> clearFailed() async {
    try {
      final box = _hiveDb.syncQueue;
      final keysToDelete = <String>[];
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      for (final key in box.keys) {
        final jsonString = box.get(key) as String;
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final operation = SyncOperation.fromJson(json);

        if (operation.status == SyncStatus.failed &&
            operation.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(key as String);
        }
      }

      await box.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException('Failed to clear failed operations: $e');
    }
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    try {
      final pending = await getAllPending();
      return pending.length;
    } catch (e) {
      throw CacheException('Failed to get queue size: $e');
    }
  }

  /// Check if queue is full (>1000 operations)
  Future<bool> isQueueFull() async {
    try {
      final size = await getQueueSize();
      return size >= 1000;
    } catch (e) {
      throw CacheException('Failed to check queue full: $e');
    }
  }

  /// Get operations by type
  Future<List<SyncOperation>> getOperationsByType(OperationType type) async {
    try {
      final pending = await getAllPending();
      return pending.where((op) => op.type == type).toList();
    } catch (e) {
      throw CacheException('Failed to get operations by type: $e');
    }
  }

  /// Get failed operations with retries left
  Future<List<SyncOperation>> getRetryableOperations() async {
    try {
      final box = _hiveDb.syncQueue;
      final operations = <SyncOperation>[];

      for (final key in box.keys) {
        final jsonString = box.get(key) as String;
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final operation = SyncOperation.fromJson(json);

        if (operation.status == SyncStatus.failed && operation.retryCount < 3) {
          operations.add(operation);
        }
      }

      return operations;
    } catch (e) {
      throw CacheException('Failed to get retryable operations: $e');
    }
  }

  /// Clear all
  Future<void> clearAll() async {
    try {
      await _hiveDb.syncQueue.clear();
    } catch (e) {
      throw CacheException('Failed to clear sync queue: $e');
    }
  }
}

// ============================================================================
// SYNC OPERATION MODEL
// ============================================================================

/// Represents an offline operation waiting to be synced
class SyncOperation {
  final String id;
  final OperationType type;
  final String entityType; // 'habit', 'completion', 'user', etc.
  final String entityId;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final DateTime timestamp;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final String? error;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    this.status = SyncStatus.pending,
    required this.timestamp,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.error,
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: OperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OperationType.create,
      ),
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      data: json['data'] as Map<String, dynamic>,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
      retryCount: json['retry_count'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'entity_type': entityType,
      'entity_id': entityId,
      'data': data,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'retry_count': retryCount,
      'error': error,
    };
  }

  SyncOperation copyWith({
    String? id,
    OperationType? type,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? timestamp,
    DateTime? lastAttemptAt,
    int? retryCount,
    String? error,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}

/// Operation type for sync queue
enum OperationType {
  create, // Create new entity
  update, // Update existing entity
  delete, // Delete entity
}

/// Sync status
enum SyncStatus {
  pending, // Waiting to be synced
  syncing, // Currently syncing
  synced, // Successfully synced
  failed, // Failed to sync
}
