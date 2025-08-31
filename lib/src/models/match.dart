import 'package:json_annotation/json_annotation.dart';
import 'team.dart';
import 'enhanced_match.dart';
import 'tactical_match.dart' as tactical;

part 'match.g.dart';

/// Weather conditions that can affect match performance
@JsonEnum()
enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  snowy,
  windy,
  foggy
}

/// Match result outcome
@JsonEnum()
enum MatchResult {
  homeWin,
  draw,
  awayWin
}

/// Represents weather conditions during a match
@JsonSerializable()
class Weather {
  final WeatherCondition condition;
  final double temperature; // Celsius
  final double humidity; // Percentage 0-100
  final double windSpeed; // km/h

  const Weather({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  /// Creates weather with validation
  factory Weather.create({
    required WeatherCondition condition,
    required double temperature,
    required double humidity,
    required double windSpeed,
  }) {
    if (temperature < -40 || temperature > 50) {
      throw ArgumentError('Temperature must be between -40 and 50 degrees Celsius');
    }
    if (humidity < 0 || humidity > 100) {
      throw ArgumentError('Humidity must be between 0 and 100 percent');
    }
    if (windSpeed < 0 || windSpeed > 200) {
      throw ArgumentError('Wind speed must be between 0 and 200 km/h');
    }

    return Weather(
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
    );
  }

  /// Gets the performance impact factor for the weather (0.8 to 1.2)
  double get performanceImpact {
    double impact = 1.0;

    // Temperature effects
    if (temperature < 0 || temperature > 35) {
      impact -= 0.1; // Extreme temperatures reduce performance
    } else if (temperature >= 15 && temperature <= 25) {
      impact += 0.05; // Ideal temperature slightly improves performance
    }

    // Weather condition effects
    switch (condition) {
      case WeatherCondition.sunny:
        impact += 0.05;
        break;
      case WeatherCondition.cloudy:
        // No change
        break;
      case WeatherCondition.rainy:
        impact -= 0.15;
        break;
      case WeatherCondition.snowy:
        impact -= 0.2;
        break;
      case WeatherCondition.windy:
        impact -= 0.1;
        break;
      case WeatherCondition.foggy:
        impact -= 0.1;
        break;
    }

    // Humidity effects
    if (humidity > 80) {
      impact -= 0.05;
    }

    // Wind speed effects
    if (windSpeed > 30) {
      impact -= 0.05;
    }

    // Clamp between 0.8 and 1.2
    return impact.clamp(0.8, 1.2);
  }

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          condition == other.condition &&
          temperature == other.temperature &&
          humidity == other.humidity &&
          windSpeed == other.windSpeed;

  @override
  int get hashCode =>
      condition.hashCode ^
      temperature.hashCode ^
      humidity.hashCode ^
      windSpeed.hashCode;

  @override
  String toString() =>
      'Weather(condition: $condition, temperature: ${temperature}°C, '
      'humidity: ${humidity}%, windSpeed: ${windSpeed}km/h)';
}

/// Represents a match between two teams
@JsonSerializable(explicitToJson: true)
class Match {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final Weather weather;
  final DateTime kickoffTime;
  final bool isNeutralVenue;
  
  // Match state
  final bool isCompleted;
  final int homeGoals;
  final int awayGoals;
  final MatchResult? result;
  final int currentMinute;
  final List<MatchEvent> events;
  
  // Enhanced Football Manager-style fields
  final MatchStats? matchStats;
  final Map<String, PlayerPerformance>? playerPerformances;
  final MomentumTracker? momentumTracker;
  
  // Tactical system fields
  final List<tactical.TacticalHistory>? tacticalHistory;
  final Map<String, tactical.TeamChemistry>? teamChemistry;
  final Map<String, tactical.TacticalAILearning>? tacticalAILearning;
  final Map<String, double>? tacticalEffectiveness;

  const Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.weather,
    required this.kickoffTime,
    this.isNeutralVenue = false,
    this.isCompleted = false,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.result,
    this.currentMinute = 0,
    this.events = const [],
    this.matchStats,
    this.playerPerformances,
    this.momentumTracker,
    this.tacticalHistory,
    this.teamChemistry,
    this.tacticalAILearning,
    this.tacticalEffectiveness,
  });

  /// Creates a new match with validation
  factory Match.create({
    required String id,
    required Team homeTeam,
    required Team awayTeam,
    required Weather weather,
    required DateTime kickoffTime,
    bool isNeutralVenue = false,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Match ID cannot be empty');
    }
    if (homeTeam.id == awayTeam.id) {
      throw ArgumentError('Home and away teams cannot be the same');
    }
    if (kickoffTime.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw ArgumentError('Kickoff time cannot be more than 1 day in the past');
    }

    return Match(
      id: id,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      weather: weather,
      kickoffTime: kickoffTime,
      isNeutralVenue: isNeutralVenue,
    );
  }

  /// Gets the home advantage factor (1.0 to 1.15)
  double get homeAdvantage {
    if (isNeutralVenue) return 1.0;
    
    double advantage = 1.0;
    
    // Stadium capacity influence (larger stadiums = more intimidating)
    final capacity = homeTeam.stadium.capacity;
    if (capacity > 80000) {
      advantage += 0.15;
    } else if (capacity > 60000) {
      advantage += 0.12;
    } else if (capacity > 40000) {
      advantage += 0.10;
    } else if (capacity > 20000) {
      advantage += 0.08;
    } else {
      advantage += 0.05;
    }
    
    return advantage.clamp(1.0, 1.15);
  }

  /// Updates the match with new state
  Match copyWith({
    bool? isCompleted,
    int? homeGoals,
    int? awayGoals,
    MatchResult? result,
    int? currentMinute,
    List<MatchEvent>? events,
    MatchStats? matchStats,
    Map<String, PlayerPerformance>? playerPerformances,
    MomentumTracker? momentumTracker,
    List<tactical.TacticalHistory>? tacticalHistory,
    Map<String, tactical.TeamChemistry>? teamChemistry,
    Map<String, tactical.TacticalAILearning>? tacticalAILearning,
    Map<String, double>? tacticalEffectiveness,
  }) {
    return Match(
      id: id,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      weather: weather,
      kickoffTime: kickoffTime,
      isNeutralVenue: isNeutralVenue,
      isCompleted: isCompleted ?? this.isCompleted,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      result: result ?? this.result,
      currentMinute: currentMinute ?? this.currentMinute,
      events: events ?? this.events,
      matchStats: matchStats ?? this.matchStats,
      playerPerformances: playerPerformances ?? this.playerPerformances,
      momentumTracker: momentumTracker ?? this.momentumTracker,
      tacticalHistory: tacticalHistory ?? this.tacticalHistory,
      teamChemistry: teamChemistry ?? this.teamChemistry,
      tacticalAILearning: tacticalAILearning ?? this.tacticalAILearning,
      tacticalEffectiveness: tacticalEffectiveness ?? this.tacticalEffectiveness,
    );
  }

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Match(id: $id, ${homeTeam.name} vs ${awayTeam.name}, '
      'score: $homeGoals-$awayGoals, minute: $currentMinute)';
}

/// Types of events that can occur during a match
@JsonEnum()
enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  kickoff,
  halfTime,
  fullTime,
  penalty,
  ownGoal,
  assist,
  // Enhanced Football Manager-style events
  injury,
  shot,
  shotOnTarget,
  shotOffTarget,
  tackle,
  foul,
  corner,
  offside,
  save,
  tacticalChange,
  momentumShift
}

/// Represents an event that occurs during a match
@JsonSerializable()
class MatchEvent {
  final String id;
  final MatchEventType type;
  final int minute;
  final String? playerId;
  final String? playerName;
  final String teamId;
  final String description;
  final Map<String, dynamic> metadata;

  const MatchEvent({
    required this.id,
    required this.type,
    required this.minute,
    required this.teamId,
    required this.description,
    this.playerId,
    this.playerName,
    this.metadata = const {},
  });

  /// Creates a match event with validation
  factory MatchEvent.create({
    required String id,
    required MatchEventType type,
    required int minute,
    required String teamId,
    required String description,
    String? playerId,
    String? playerName,
    Map<String, dynamic> metadata = const {},
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Event ID cannot be empty');
    }
    if (minute < 0 || minute > 120) {
      throw ArgumentError('Event minute must be between 0 and 120');
    }
    if (teamId.trim().isEmpty) {
      throw ArgumentError('Team ID cannot be empty');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('Event description cannot be empty');
    }

    return MatchEvent(
      id: id,
      type: type,
      minute: minute,
      teamId: teamId,
      description: description,
      playerId: playerId,
      playerName: playerName,
      metadata: metadata,
    );
  }

  factory MatchEvent.fromJson(Map<String, dynamic> json) => _$MatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$MatchEventToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MatchEvent(${minute}\': $description)';
}
