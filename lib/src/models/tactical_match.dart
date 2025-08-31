import 'enhanced_match.dart';

/// Enhanced tactical system models for advanced match simulation

enum Formation {
  f442,
  f433,
  f352,
  f4231,
  f541,
  f3421,
  f4141,
  invalid,
}

enum PlayerRole {
  goalkeeper,
  centreback,
  fullback,
  wingback,
  defensiveMidfielder,
  centralMidfielder,
  attackingMidfielder,
  winger,
  striker,
  targetMan,
  poacher,
  falseNine,
  ballWinner,
  playmaker,
}

enum PlayerMentality {
  defensive,
  balanced,
  attacking,
  aggressive,
}

enum TacticalAILevel {
  disabled,
  basic,
  advanced,
  learning,
  predictive,
}

enum MatchIntensity {
  low,
  medium,
  high,
  veryHigh,
}

enum WeatherType {
  sunny,
  cloudy,
  rain,
  snow,
  fog,
}

enum WeatherIntensity {
  light,
  moderate,
  heavy,
  extreme,
}


/// Additional match event types for tactical system
enum TacticalEventType {
  formationChange,
  playerInstructionChange,
  automaticTacticalChange,
  tacticalAnalysis,
  tacticalPrediction,
  weatherTacticalAdjustment,
}

/// Player instructions for individual tactical control
class PlayerInstructions {
  final String playerId;
  final PlayerRole role;
  final PlayerMentality mentality;
  final List<String> instructions;

  const PlayerInstructions({
    required this.playerId,
    required this.role,
    required this.mentality,
    required this.instructions,
  });

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'role': role.name,
    'mentality': mentality.name,
    'instructions': instructions,
  };

  factory PlayerInstructions.fromJson(Map<String, dynamic> json) {
    return PlayerInstructions(
      playerId: json['playerId'],
      role: PlayerRole.values.byName(json['role']),
      mentality: PlayerMentality.values.byName(json['mentality']),
      instructions: List<String>.from(json['instructions']),
    );
  }
}

/// Weather conditions affecting gameplay
class WeatherConditions {
  final WeatherType type;
  final WeatherIntensity intensity;
  final int windSpeed;
  final int temperature;
  final int humidity;

  const WeatherConditions({
    required this.type,
    required this.intensity,
    this.windSpeed = 0,
    this.temperature = 20,
    this.humidity = 50,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'intensity': intensity.name,
    'windSpeed': windSpeed,
    'temperature': temperature,
    'humidity': humidity,
  };

  factory WeatherConditions.fromJson(Map<String, dynamic> json) {
    return WeatherConditions(
      type: WeatherType.values.byName(json['type']),
      intensity: WeatherIntensity.values.byName(json['intensity']),
      windSpeed: json['windSpeed'] ?? 0,
      temperature: json['temperature'] ?? 20,
      humidity: json['humidity'] ?? 50,
    );
  }
}

/// Enhanced team tactics with formation support
class EnhancedTeamTactics extends TeamTactics {
  final Formation? formation;
  final Map<String, String> customInstructions;

  const EnhancedTeamTactics({
    required super.mentality,
    required super.pressing,
    required super.tempo,
    required super.width,
    required super.directness,
    this.formation,
    this.customInstructions = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'formation': formation?.name,
    'customInstructions': customInstructions,
  };

  factory EnhancedTeamTactics.fromJson(Map<String, dynamic> json) {
    return EnhancedTeamTactics(
      mentality: TeamMentality.values.byName(json['mentality']),
      pressing: json['pressing'],
      tempo: json['tempo'],
      width: json['width'],
      directness: json['directness'],
      formation: json['formation'] != null 
          ? Formation.values.byName(json['formation'])
          : null,
      customInstructions: Map<String, String>.from(json['customInstructions'] ?? {}),
    );
  }

  EnhancedTeamTactics copyWith({
    TeamMentality? mentality,
    int? pressing,
    int? tempo,
    int? width,
    int? directness,
    Formation? formation,
    Map<String, String>? customInstructions,
  }) {
    return EnhancedTeamTactics(
      mentality: mentality ?? this.mentality,
      pressing: pressing ?? this.pressing,
      tempo: tempo ?? this.tempo,
      width: width ?? this.width,
      directness: directness ?? this.directness,
      formation: formation ?? this.formation,
      customInstructions: customInstructions ?? this.customInstructions,
    );
  }
}

/// Tactical history tracking
class TacticalHistory {
  final List<FormationChange> formationChanges;
  final List<TacticalChange> tacticalChanges;
  final List<AutomaticChange> automaticChanges;
  final List<PlayerInstructionChange> playerInstructionChanges;

  const TacticalHistory({
    this.formationChanges = const [],
    this.tacticalChanges = const [],
    this.automaticChanges = const [],
    this.playerInstructionChanges = const [],
  });

  Map<String, dynamic> toJson() => {
    'formationChanges': formationChanges.map((e) => e.toJson()).toList(),
    'tacticalChanges': tacticalChanges.map((e) => e.toJson()).toList(),
    'automaticChanges': automaticChanges.map((e) => e.toJson()).toList(),
    'playerInstructionChanges': playerInstructionChanges.map((e) => e.toJson()).toList(),
  };

  factory TacticalHistory.fromJson(Map<String, dynamic> json) {
    return TacticalHistory(
      formationChanges: (json['formationChanges'] as List?)
          ?.map((e) => FormationChange.fromJson(e))
          .toList() ?? [],
      tacticalChanges: (json['tacticalChanges'] as List?)
          ?.map((e) => TacticalChange.fromJson(e))
          .toList() ?? [],
      automaticChanges: (json['automaticChanges'] as List?)
          ?.map((e) => AutomaticChange.fromJson(e))
          .toList() ?? [],
      playerInstructionChanges: (json['playerInstructionChanges'] as List?)
          ?.map((e) => PlayerInstructionChange.fromJson(e))
          .toList() ?? [],
    );
  }

  TacticalHistory copyWith({
    List<FormationChange>? formationChanges,
    List<TacticalChange>? tacticalChanges,
    List<AutomaticChange>? automaticChanges,
    List<PlayerInstructionChange>? playerInstructionChanges,
  }) {
    return TacticalHistory(
      formationChanges: formationChanges ?? this.formationChanges,
      tacticalChanges: tacticalChanges ?? this.tacticalChanges,
      automaticChanges: automaticChanges ?? this.automaticChanges,
      playerInstructionChanges: playerInstructionChanges ?? this.playerInstructionChanges,
    );
  }
}

class FormationChange {
  final int minute;
  final Formation fromFormation;
  final Formation toFormation;
  final String reason;

  const FormationChange({
    required this.minute,
    required this.fromFormation,
    required this.toFormation,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'minute': minute,
    'fromFormation': fromFormation.name,
    'toFormation': toFormation.name,
    'reason': reason,
  };

  factory FormationChange.fromJson(Map<String, dynamic> json) {
    return FormationChange(
      minute: json['minute'],
      fromFormation: Formation.values.byName(json['fromFormation']),
      toFormation: Formation.values.byName(json['toFormation']),
      reason: json['reason'],
    );
  }
}

class TacticalChange {
  final int minute;
  final EnhancedTeamTactics fromTactics;
  final EnhancedTeamTactics toTactics;
  final String reason;

  const TacticalChange({
    required this.minute,
    required this.fromTactics,
    required this.toTactics,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'minute': minute,
    'fromTactics': fromTactics.toJson(),
    'toTactics': toTactics.toJson(),
    'reason': reason,
  };

  factory TacticalChange.fromJson(Map<String, dynamic> json) {
    return TacticalChange(
      minute: json['minute'],
      fromTactics: EnhancedTeamTactics.fromJson(json['fromTactics']),
      toTactics: EnhancedTeamTactics.fromJson(json['toTactics']),
      reason: json['reason'],
    );
  }
}

class AutomaticChange {
  final int minute;
  final String trigger;
  final String change;
  final String reason;

  const AutomaticChange({
    required this.minute,
    required this.trigger,
    required this.change,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'minute': minute,
    'trigger': trigger,
    'change': change,
    'reason': reason,
  };

  factory AutomaticChange.fromJson(Map<String, dynamic> json) {
    return AutomaticChange(
      minute: json['minute'],
      trigger: json['trigger'],
      change: json['change'],
      reason: json['reason'],
    );
  }
}

class PlayerInstructionChange {
  final int minute;
  final String playerId;
  final PlayerInstructions instructions;
  final String reason;

  const PlayerInstructionChange({
    required this.minute,
    required this.playerId,
    required this.instructions,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'minute': minute,
    'playerId': playerId,
    'instructions': instructions.toJson(),
    'reason': reason,
  };

  factory PlayerInstructionChange.fromJson(Map<String, dynamic> json) {
    return PlayerInstructionChange(
      minute: json['minute'],
      playerId: json['playerId'],
      instructions: PlayerInstructions.fromJson(json['instructions']),
      reason: json['reason'],
    );
  }
}

/// Team chemistry tracking
class TeamChemistry {
  final double overallChemistry;
  final double defenseChemistry;
  final double midfieldChemistry;
  final double attackChemistry;
  final double tacticalFamiliarity;

  const TeamChemistry({
    required this.overallChemistry,
    required this.defenseChemistry,
    required this.midfieldChemistry,
    required this.attackChemistry,
    required this.tacticalFamiliarity,
  });

  Map<String, dynamic> toJson() => {
    'overallChemistry': overallChemistry,
    'defenseChemistry': defenseChemistry,
    'midfieldChemistry': midfieldChemistry,
    'attackChemistry': attackChemistry,
    'tacticalFamiliarity': tacticalFamiliarity,
  };

  factory TeamChemistry.fromJson(Map<String, dynamic> json) {
    return TeamChemistry(
      overallChemistry: json['overallChemistry'].toDouble(),
      defenseChemistry: json['defenseChemistry'].toDouble(),
      midfieldChemistry: json['midfieldChemistry'].toDouble(),
      attackChemistry: json['attackChemistry'].toDouble(),
      tacticalFamiliarity: json['tacticalFamiliarity'].toDouble(),
    );
  }
}

/// Tactical AI learning system
class TacticalAILearning {
  final List<SuccessfulTactic> successfulTactics;
  final List<FailedTactic> failedTactics;
  final Map<String, double> opponentAnalysis;

  const TacticalAILearning({
    this.successfulTactics = const [],
    this.failedTactics = const [],
    this.opponentAnalysis = const {},
  });

  Map<String, dynamic> toJson() => {
    'successfulTactics': successfulTactics.map((e) => e.toJson()).toList(),
    'failedTactics': failedTactics.map((e) => e.toJson()).toList(),
    'opponentAnalysis': opponentAnalysis,
  };

  factory TacticalAILearning.fromJson(Map<String, dynamic> json) {
    return TacticalAILearning(
      successfulTactics: (json['successfulTactics'] as List?)
          ?.map((e) => SuccessfulTactic.fromJson(e))
          .toList() ?? [],
      failedTactics: (json['failedTactics'] as List?)
          ?.map((e) => FailedTactic.fromJson(e))
          .toList() ?? [],
      opponentAnalysis: Map<String, double>.from(json['opponentAnalysis'] ?? {}),
    );
  }
}

class SuccessfulTactic {
  final EnhancedTeamTactics tactics;
  final String situation;
  final double successRate;

  const SuccessfulTactic({
    required this.tactics,
    required this.situation,
    required this.successRate,
  });

  Map<String, dynamic> toJson() => {
    'tactics': tactics.toJson(),
    'situation': situation,
    'successRate': successRate,
  };

  factory SuccessfulTactic.fromJson(Map<String, dynamic> json) {
    return SuccessfulTactic(
      tactics: EnhancedTeamTactics.fromJson(json['tactics']),
      situation: json['situation'],
      successRate: json['successRate'].toDouble(),
    );
  }
}

class FailedTactic {
  final EnhancedTeamTactics tactics;
  final String situation;
  final double failureRate;

  const FailedTactic({
    required this.tactics,
    required this.situation,
    required this.failureRate,
  });

  Map<String, dynamic> toJson() => {
    'tactics': tactics.toJson(),
    'situation': situation,
    'failureRate': failureRate,
  };

  factory FailedTactic.fromJson(Map<String, dynamic> json) {
    return FailedTactic(
      tactics: EnhancedTeamTactics.fromJson(json['tactics']),
      situation: json['situation'],
      failureRate: json['failureRate'].toDouble(),
    );
  }
}

/// Tactical effectiveness metrics
class TacticalEffectiveness {
  final double defensiveSolidity;
  final double attackingThreat;
  final double pressingEffectiveness;
  final double ballRecoveryRate;
  final double possessionEffectiveness;
  final double creativePlaymaking;

  const TacticalEffectiveness({
    required this.defensiveSolidity,
    required this.attackingThreat,
    required this.pressingEffectiveness,
    required this.ballRecoveryRate,
    required this.possessionEffectiveness,
    required this.creativePlaymaking,
  });

  Map<String, dynamic> toJson() => {
    'defensiveSolidity': defensiveSolidity,
    'attackingThreat': attackingThreat,
    'pressingEffectiveness': pressingEffectiveness,
    'ballRecoveryRate': ballRecoveryRate,
    'possessionEffectiveness': possessionEffectiveness,
    'creativePlaymaking': creativePlaymaking,
  };

  factory TacticalEffectiveness.fromJson(Map<String, dynamic> json) {
    return TacticalEffectiveness(
      defensiveSolidity: json['defensiveSolidity'].toDouble(),
      attackingThreat: json['attackingThreat'].toDouble(),
      pressingEffectiveness: json['pressingEffectiveness'].toDouble(),
      ballRecoveryRate: json['ballRecoveryRate'].toDouble(),
      possessionEffectiveness: json['possessionEffectiveness'].toDouble(),
      creativePlaymaking: json['creativePlaymaking'].toDouble(),
    );
  }
}

/// Enhanced player performance with tactical metrics
class EnhancedPlayerPerformance extends PlayerPerformance {
  final double stamina;
  final int tacklesAttempted;
  final int pressureEvents;

  const EnhancedPlayerPerformance({
    required super.playerId,
    required super.playerName,
    required super.rating,
    required super.goals,
    required super.assists,
    required super.shots,
    required super.shotsOnTarget,
    required super.passes,
    required super.passAccuracy,
    required super.tackles,
    required super.fouls,
    required super.yellowCards,
    required super.redCards,
    required super.minutesPlayed,
    required this.stamina,
    required this.tacklesAttempted,
    required this.pressureEvents,
  });

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'stamina': stamina,
    'tacklesAttempted': tacklesAttempted,
    'pressureEvents': pressureEvents,
  };

  factory EnhancedPlayerPerformance.fromJson(Map<String, dynamic> json) {
    return EnhancedPlayerPerformance(
      playerId: json['playerId'],
      playerName: json['playerName'],
      rating: json['rating'].toDouble(),
      goals: json['goals'],
      assists: json['assists'],
      shots: json['shots'],
      shotsOnTarget: json['shotsOnTarget'],
      passes: json['passes'],
      passAccuracy: json['passAccuracy'].toDouble(),
      tackles: json['tackles'],
      fouls: json['fouls'],
      yellowCards: json['yellowCards'],
      redCards: json['redCards'],
      minutesPlayed: json['minutesPlayed'],
      stamina: json['stamina']?.toDouble() ?? 100.0,
      tacklesAttempted: json['tacklesAttempted'] ?? 0,
      pressureEvents: json['pressureEvents'] ?? 0,
    );
  }

  EnhancedPlayerPerformance copyWith({
    String? playerId,
    String? playerName,
    double? rating,
    int? goals,
    int? assists,
    int? shots,
    int? shotsOnTarget,
    int? passes,
    double? passAccuracy,
    int? tackles,
    int? fouls,
    int? yellowCards,
    int? redCards,
    int? minutesPlayed,
    double? stamina,
    int? tacklesAttempted,
    int? pressureEvents,
  }) {
    return EnhancedPlayerPerformance(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      rating: rating ?? this.rating,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      shots: shots ?? this.shots,
      shotsOnTarget: shotsOnTarget ?? this.shotsOnTarget,
      passes: passes ?? this.passes,
      passAccuracy: passAccuracy ?? this.passAccuracy,
      tackles: tackles ?? this.tackles,
      fouls: fouls ?? this.fouls,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      stamina: stamina ?? this.stamina,
      tacklesAttempted: tacklesAttempted ?? this.tacklesAttempted,
      pressureEvents: pressureEvents ?? this.pressureEvents,
    );
  }
}
