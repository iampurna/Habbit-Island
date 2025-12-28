import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/iap_service.dart';
import 'premium_event.dart';
import 'premium_state.dart';
import '../../../data/repositories/premium_repository.dart';
import '../../../core/utils/app_logger.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final IAPService _iapService;
  final PremiumRepository _repository;

  PremiumBloc({
    required IAPService iapService,
    required PremiumRepository premiumRepository,
    required PremiumRepository repository,
  }) : _iapService = iapService,
       _repository = premiumRepository,
       super(PremiumInitial()) {
    on<PremiumStatusChecked>(_onPremiumStatusChecked);
    on<PremiumPurchaseRequested>(_onPremiumPurchaseRequested);
    on<PremiumRestoreRequested>(_onPremiumRestoreRequested);
    on<StreakShieldsChecked>(_onStreakShieldsChecked);
    on<VacationDaysChecked>(_onVacationDaysChecked);
  }

  Future<void> _onPremiumStatusChecked(
    PremiumStatusChecked event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      emit(PremiumLoading());

      final isActive = await _iapService.isPremiumActive();

      if (isActive) {
        final entitlement = await _iapService.getPremiumEntitlement();
        if (entitlement != null) {
          AppLogger.debug('PremiumBloc: Premium active');
          emit(PremiumActive(entitlement));
        } else {
          emit(PremiumInactive());
        }
      } else {
        AppLogger.debug('PremiumBloc: Premium inactive');
        emit(PremiumInactive());
      }
    } catch (e, stackTrace) {
      AppLogger.error('PremiumBloc: Status check error', e, stackTrace);
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onPremiumPurchaseRequested(
    PremiumPurchaseRequested event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      emit(PremiumLoading());

      final package = await _iapService.getPackage(event.productId);
      if (package == null) {
        emit(const PremiumError('Product not found'));
        return;
      }

      final entitlement = await _iapService.purchasePremium(package: package);

      if (entitlement != null) {
        AppLogger.info('PremiumBloc: Purchase successful');
        emit(PremiumPurchaseSuccess(entitlement));
      } else {
        emit(const PremiumError('Purchase failed'));
      }
    } catch (e, stackTrace) {
      AppLogger.error('PremiumBloc: Purchase error', e, stackTrace);
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onPremiumRestoreRequested(
    PremiumRestoreRequested event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      emit(PremiumLoading());

      final entitlement = await _iapService.restorePurchases();

      AppLogger.info('PremiumBloc: Restore completed');
      emit(PremiumRestoreSuccess(entitlement));
    } catch (e, stackTrace) {
      AppLogger.error('PremiumBloc: Restore error', e, stackTrace);
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onStreakShieldsChecked(
    StreakShieldsChecked event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final result = await _repository.getStreakShieldsRemaining(event.userId);

      result.fold((failure) => emit(PremiumError(failure.message)), (
        remaining,
      ) {
        AppLogger.debug('PremiumBloc: $remaining shields remaining');
        emit(StreakShieldsLoaded(remaining));
      });
    } catch (e, stackTrace) {
      AppLogger.error('PremiumBloc: Shields check error', e, stackTrace);
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onVacationDaysChecked(
    VacationDaysChecked event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final result = await _repository.getVacationDaysRemaining(event.userId);

      result.fold((failure) => emit(PremiumError(failure.message)), (
        remaining,
      ) {
        AppLogger.debug('PremiumBloc: $remaining vacation days remaining');
        emit(VacationDaysLoaded(remaining));
      });
    } catch (e, stackTrace) {
      AppLogger.error('PremiumBloc: Vacation days check error', e, stackTrace);
      emit(PremiumError(e.toString()));
    }
  }
}
