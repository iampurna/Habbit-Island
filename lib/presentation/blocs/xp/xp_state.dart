import 'package:equatable/equatable.dart';

abstract class XpState extends Equatable {
  const XpState();

  @override
  List<Object?> get props => [];
}

class XpInitial extends XpState {}

class XpLoading extends XpState {}

class XpStatsLoaded extends XpState {
  final int totalXp;
  final int currentLevel;
  final double progressToNextLevel;
  final int xpToNextLevel;

  const XpStatsLoaded({
    required this.totalXp,
    required this.currentLevel,
    required this.progressToNextLevel,
    required this.xpToNextLevel,
  });

  @override
  List<Object> get props => [
    totalXp,
    currentLevel,
    progressToNextLevel,
    xpToNextLevel,
  ];
}

class XpAwarded extends XpState {
  final int xpAmount;
  final bool hadBonus;
  final String? bonusType;

  const XpAwarded({
    required this.xpAmount,
    required this.hadBonus,
    this.bonusType,
  });

  @override
  List<Object?> get props => [xpAmount, hadBonus, bonusType];
}

class LevelUp extends XpState {
  final int newLevel;
  final int totalXp;

  const LevelUp({required this.newLevel, required this.totalXp});

  @override
  List<Object> get props => [newLevel, totalXp];
}

class XpError extends XpState {
  final String message;

  const XpError(this.message);

  @override
  List<Object> get props => [message];
}
