import 'package:equatable/equatable.dart';

abstract class XpEvent extends Equatable {
  const XpEvent();

  @override
  List<Object?> get props => [];
}

class XpStatsRequested extends XpEvent {
  final String userId;

  const XpStatsRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class LevelCalculationRequested extends XpEvent {
  final String userId;

  const LevelCalculationRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class XpAwardedForHabit extends XpEvent {
  final String userId;
  final String habitId;

  const XpAwardedForHabit({required this.userId, required this.habitId});

  @override
  List<Object> get props => [userId, habitId];
}

class XpAwardedForLogin extends XpEvent {
  final String userId;

  const XpAwardedForLogin(this.userId);

  @override
  List<Object> get props => [userId];
}

class XpAwardedForAd extends XpEvent {
  final String userId;
  final String adId;

  const XpAwardedForAd({required this.userId, required this.adId});

  @override
  List<Object> get props => [userId, adId];
}
