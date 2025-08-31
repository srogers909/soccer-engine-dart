import 'package:json_annotation/json_annotation.dart';
import 'match.dart';
import 'enhanced_match.dart';

part 'match_state.g.dart';

/// Represents the current state of a match simulation
@JsonSerializable(explicitToJson: true)
class MatchState {
  final String id;
  final Match match;
  final DateTime timestamp;
  final bool isPaused;
  final double speed;
  final int currentMinute;
  final Map<String, TeamTactics> teamTactics;
  final List<String> eventLog;
  final Map<String, dynamic> metadata;

  const MatchState({
    required this.id,
    required this.match,
    required this.timestamp,
    this.isPaused = false,
    this.speed = 1.0,
    required this.currentMinute,
    this.teamTactics = const {},
    this.eventLog = const [],
    this.metadata = const {},
  });

  /// Creates a new match state from a match
  factory MatchState.fromMatch(Match match, {
    Map<String, TeamTactics>? tactics,
    bool isPaused = false,
    double speed = 1.0,
    List<String>? eventLog,
    Map<String, dynamic>? metadata,
  }) {
    return MatchState(
      id: 'state_${match.id}_${DateTime.now().millisecondsSinceEpoch}',
      match: match,
      timestamp: DateTime.now(),
      isPaused: isPaused,
      speed: speed,
      currentMinute: match.currentMinute,
      teamTactics: tactics ?? {},
      eventLog: eventLog ?? [],
      metadata: metadata ?? {},
    );
  }

  /// Creates a copy of this state with updated values
  MatchState copyWith({
    Match? match,
    DateTime? timestamp,
    bool? isPaused,
    double? speed,
    int? currentMinute,
    Map<String, TeamTactics>? teamTactics,
    List<String>? eventLog,
    Map<String, dynamic>? metadata,
  }) {
    return MatchState(
      id: id,
      match: match ?? this.match,
      timestamp: timestamp ?? this.timestamp,
      isPaused: isPaused ?? this.isPaused,
      speed: speed ?? this.speed,
      currentMinute: currentMinute ?? this.currentMinute,
      teamTactics: teamTactics ?? this.teamTactics,
      eventLog: eventLog ?? this.eventLog,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Adds an event to the event log
  MatchState addToEventLog(String event) {
    return copyWith(
      eventLog: [...eventLog, '${DateTime.now().toIso8601String()}: $event'],
    );
  }

  /// Updates team tactics
  MatchState updateTactics(String teamId, TeamTactics tactics) {
    final updatedTactics = Map<String, TeamTactics>.from(teamTactics);
    updatedTactics[teamId] = tactics;
    return copyWith(teamTactics: updatedTactics);
  }

  /// Checks if the match is live (not completed and not paused)
  bool get isLive => !match.isCompleted && !isPaused;

  /// Gets the total elapsed time since state creation
  Duration get elapsedTime => DateTime.now().difference(timestamp);

  factory MatchState.fromJson(Map<String, dynamic> json) => _$MatchStateFromJson(json);
  Map<String, dynamic> toJson() => _$MatchStateToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchState &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MatchState(id: $id, match: ${match.id}, minute: $currentMinute, '
      'isPaused: $isPaused, speed: ${speed}x)';
}

/// Represents a saved checkpoint during match simulation
@JsonSerializable(explicitToJson: true)
class MatchCheckpoint {
  final String id;
  final String matchId;
  final String name;
  final DateTime timestamp;
  final MatchState state;
  final String description;
  final Map<String, dynamic> metadata;

  const MatchCheckpoint({
    required this.id,
    required this.matchId,
    required this.name,
    required this.timestamp,
    required this.state,
    this.description = '',
    this.metadata = const {},
  });

  /// Creates a checkpoint from current match state
  factory MatchCheckpoint.fromState(
    MatchState state, {
    required String name,
    String description = '',
    Map<String, dynamic>? metadata,
  }) {
    return MatchCheckpoint(
      id: 'checkpoint_${state.match.id}_${DateTime.now().millisecondsSinceEpoch}',
      matchId: state.match.id,
      name: name,
      timestamp: DateTime.now(),
      state: state,
      description: description,
      metadata: metadata ?? {},
    );
  }

  /// Creates an automatic checkpoint based on match events
  factory MatchCheckpoint.auto(MatchState state, String eventType) {
    final minute = state.currentMinute;
    final name = _getAutoCheckpointName(eventType, minute);
    final description = _getAutoCheckpointDescription(state, eventType);

    return MatchCheckpoint(
      id: 'auto_${state.match.id}_${eventType}_$minute',
      matchId: state.match.id,
      name: name,
      timestamp: DateTime.now(),
      state: state,
      description: description,
      metadata: {
        'auto': true,
        'eventType': eventType,
        'minute': minute,
      },
    );
  }

  /// Gets automatic checkpoint name based on event type
  static String _getAutoCheckpointName(String eventType, int minute) {
    switch (eventType) {
      case 'goal':
        return 'Goal - ${minute}\'';
      case 'halfTime':
        return 'Half Time';
      case 'fullTime':
        return 'Full Time';
      case 'redCard':
        return 'Red Card - ${minute}\'';
      case 'tacticalChange':
        return 'Tactical Change - ${minute}\'';
      default:
        return 'Minute $minute';
    }
  }

  /// Gets automatic checkpoint description
  static String _getAutoCheckpointDescription(MatchState state, String eventType) {
    final score = '${state.match.homeGoals}-${state.match.awayGoals}';
    final teams = '${state.match.homeTeam.name} vs ${state.match.awayTeam.name}';
    
    switch (eventType) {
      case 'goal':
        return 'Goal scored! $teams ($score) at ${state.currentMinute}\'';
      case 'halfTime':
        return 'Half time reached. $teams ($score)';
      case 'fullTime':
        return 'Match completed. $teams ($score)';
      case 'redCard':
        return 'Red card shown at ${state.currentMinute}\'. $teams ($score)';
      case 'tacticalChange':
        return 'Tactical change made at ${state.currentMinute}\'. $teams ($score)';
      default:
        return '$teams ($score) at ${state.currentMinute}\'';
    }
  }

  factory MatchCheckpoint.fromJson(Map<String, dynamic> json) => _$MatchCheckpointFromJson(json);
  Map<String, dynamic> toJson() => _$MatchCheckpointToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchCheckpoint &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MatchCheckpoint(id: $id, name: $name, minute: ${state.currentMinute})';
}

/// Configuration for automatic checkpoint creation
@JsonSerializable()
class CheckpointConfig {
  final bool enabled;
  final bool onGoals;
  final bool onCards;
  final bool onHalfTime;
  final bool onFullTime;
  final bool onTacticalChanges;
  final int maxCheckpoints;
  final Duration retentionPeriod;

  const CheckpointConfig({
    this.enabled = true,
    this.onGoals = true,
    this.onCards = true,
    this.onHalfTime = true,
    this.onFullTime = true,
    this.onTacticalChanges = false,
    this.maxCheckpoints = 20,
    this.retentionPeriod = const Duration(days: 7),
  });

  /// Default configuration for automatic checkpoints
  static const CheckpointConfig defaultConfig = CheckpointConfig();

  /// Configuration with minimal checkpoints (goals and key events only)
  static const CheckpointConfig minimal = CheckpointConfig(
    onGoals: true,
    onCards: false,
    onHalfTime: true,
    onFullTime: true,
    onTacticalChanges: false,
    maxCheckpoints: 10,
  );

  /// Configuration with comprehensive checkpoints
  static const CheckpointConfig comprehensive = CheckpointConfig(
    onGoals: true,
    onCards: true,
    onHalfTime: true,
    onFullTime: true,
    onTacticalChanges: true,
    maxCheckpoints: 50,
    retentionPeriod: Duration(days: 30),
  );

  /// Checks if a checkpoint should be created for an event type
  bool shouldCreateCheckpoint(String eventType) {
    if (!enabled) return false;
    
    switch (eventType) {
      case 'goal':
        return onGoals;
      case 'yellowCard':
      case 'redCard':
        return onCards;
      case 'halfTime':
        return onHalfTime;
      case 'fullTime':
        return onFullTime;
      case 'tacticalChange':
        return onTacticalChanges;
      default:
        return false;
    }
  }

  factory CheckpointConfig.fromJson(Map<String, dynamic> json) => _$CheckpointConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CheckpointConfigToJson(this);

  @override
  String toString() =>
      'CheckpointConfig(enabled: $enabled, maxCheckpoints: $maxCheckpoints)';
}
