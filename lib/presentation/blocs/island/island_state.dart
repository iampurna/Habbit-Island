import 'package:equatable/equatable.dart';

abstract class IslandState extends Equatable {
  const IslandState();

  @override
  List<Object?> get props => [];
}

class IslandInitial extends IslandState {}

class IslandLoading extends IslandState {}

class IslandLoaded extends IslandState {
  final IslandState island;

  const IslandLoaded(this.island);

  @override
  List<Object> get props => [island];
}

class IslandUpdated extends IslandState {
  final IslandState island;

  const IslandUpdated(this.island);

  @override
  List<Object> get props => [island];
}

class ZoneUnlocked extends IslandState {
  final String zoneId;

  const ZoneUnlocked(this.zoneId);

  @override
  List<Object> get props => [zoneId];
}

class AchievementUnlocked extends IslandState {
  final String achievementId;

  const AchievementUnlocked(this.achievementId);

  @override
  List<Object> get props => [achievementId];
}

class IslandError extends IslandState {
  final String message;

  const IslandError(this.message);

  @override
  List<Object> get props => [message];
}
