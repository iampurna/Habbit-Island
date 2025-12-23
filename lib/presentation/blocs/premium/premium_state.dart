import 'package:equatable/equatable.dart';
import 'package:habbit_island/data/models/premium_entitlement_model.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumActive extends PremiumState {
  final PremiumEntitlementModel entitlement;

  const PremiumActive(this.entitlement);

  @override
  List<Object> get props => [entitlement];
}

class PremiumInactive extends PremiumState {}

class PremiumPurchaseSuccess extends PremiumState {
  final PremiumEntitlementModel entitlement;

  const PremiumPurchaseSuccess(this.entitlement);

  @override
  List<Object> get props => [entitlement];
}

class PremiumRestoreSuccess extends PremiumState {
  final PremiumEntitlementModel? entitlement;

  const PremiumRestoreSuccess(this.entitlement);

  @override
  List<Object?> get props => [entitlement];
}

class StreakShieldsLoaded extends PremiumState {
  final int remaining;

  const StreakShieldsLoaded(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class VacationDaysLoaded extends PremiumState {
  final int remaining;

  const VacationDaysLoaded(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);

  @override
  List<Object> get props => [message];
}
