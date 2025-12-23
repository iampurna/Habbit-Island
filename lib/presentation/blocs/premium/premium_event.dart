import 'package:equatable/equatable.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object?> get props => [];
}

class PremiumStatusChecked extends PremiumEvent {
  final String userId;

  const PremiumStatusChecked(this.userId);

  @override
  List<Object> get props => [userId];
}

class PremiumPurchaseRequested extends PremiumEvent {
  final String userId;
  final String productId;

  const PremiumPurchaseRequested({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object> get props => [userId, productId];
}

class PremiumRestoreRequested extends PremiumEvent {
  final String userId;

  const PremiumRestoreRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class PremiumCancellationRequested extends PremiumEvent {
  final String userId;

  const PremiumCancellationRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class StreakShieldsChecked extends PremiumEvent {
  final String userId;

  const StreakShieldsChecked(this.userId);

  @override
  List<Object> get props => [userId];
}

class VacationDaysChecked extends PremiumEvent {
  final String userId;

  const VacationDaysChecked(this.userId);

  @override
  List<Object> get props => [userId];
}
