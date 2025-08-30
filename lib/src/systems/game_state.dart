import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/league.dart';
import '../models/team.dart';

part 'game_state.g.dart';

/// Represents the current state of the game including time progression,
/// league status, and player team management
@JsonSerializable(explicitToJson: true)
class GameState extends Equatable {
  /// The current league being played
  final League league;

  /// ID of the team controlled by the player
  final String playerTeamId;

  /// Current date in the game world
  final DateTime currentDate;

  /// Current day number in the game (1-based)
  final int currentDay;

  /// Current season number (1-based)
  final int currentSeason;

  /// Creates a new GameState instance
  GameState({
    required this.league,
    required this.playerTeamId,
    required this.currentDate,
    required this.currentDay,
    this.currentSeason = 1,
  }) {
    // Validate current day
    if (currentDay < 1) {
      throw ArgumentError('Current day must be 1 or greater');
    }
    
    // Validate current season
    if (currentSeason < 1) {
      throw ArgumentError('Current season must be 1 or greater');
    }
    
    // Validate player team exists in league
    final playerTeamExists = league.teams.any((team) => team.id == playerTeamId);
    if (!playerTeamExists) {
      throw ArgumentError('Player team with ID $playerTeamId not found in league');
    }
  }

  /// Factory constructor to initialize a new game
  factory GameState.initialize({
    required League league,
    required String playerTeamId,
    required DateTime startDate,
  }) {
    // Validate player team exists in league
    final playerTeamExists = league.teams.any((team) => team.id == playerTeamId);
    if (!playerTeamExists) {
      throw ArgumentError('Player team with ID $playerTeamId not found in league');
    }
    
    return GameState(
      league: league,
      playerTeamId: playerTeamId,
      currentDate: startDate,
      currentDay: 1,
      currentSeason: 1,
    );
  }

  /// Factory constructor to create from save data
  factory GameState.fromSaveData(Map<String, dynamic> saveData) {
    final league = League.fromJson(saveData['league'] as Map<String, dynamic>);
    final playerTeamId = saveData['playerTeamId'] as String;
    
    // Validate player team exists in league
    final playerTeamExists = league.teams.any((team) => team.id == playerTeamId);
    if (!playerTeamExists) {
      throw ArgumentError('Player team with ID $playerTeamId not found in league');
    }
    
    return GameState(
      league: league,
      playerTeamId: playerTeamId,
      currentDate: DateTime.parse(saveData['currentDate'] as String),
      currentDay: saveData['currentDay'] as int,
      currentSeason: saveData['currentSeason'] as int,
    );
  }

  /// Creates a GameState from JSON data
  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);

  /// Converts the GameState to JSON data
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  /// Gets the player's team
  Team get playerTeam {
    return league.teams.firstWhere(
      (team) => team.id == playerTeamId,
      orElse: () => throw StateError('Player team not found in league'),
    );
  }

  /// Gets the current day of the week as a string
  String get dayOfWeek {
    const days = [
      'Monday',
      'Tuesday', 
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[currentDate.weekday - 1];
  }

  /// Gets the current week number (1-based)
  int get currentWeek {
    return ((currentDay - 1) ~/ 7) + 1;
  }

  /// Determines if today is a match day for the player's team
  bool get isMatchDay {
    // For now, return false - this will be enhanced when we add match scheduling
    // TODO: Check if player team has a match scheduled for current date
    return false;
  }

  /// Validates the integrity of the game state
  bool get isValid {
    try {
      // Check if player team exists
      playerTeam;
      
      // Check day is valid
      if (currentDay < 1) return false;
      
      // Check season is valid
      if (currentSeason < 1) return false;
      
      // Check league is competitive
      if (!league.isCompetitive) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Advances the game by one day
  GameState advanceDay() {
    return GameState(
      league: league,
      playerTeamId: playerTeamId,
      currentDate: currentDate.add(const Duration(days: 1)),
      currentDay: currentDay + 1,
      currentSeason: currentSeason,
    );
  }

  /// Advances to the next season
  GameState advanceToNextSeason() {
    // Calculate start date of next season (assume July 1st start)
    final nextSeasonStart = DateTime(currentDate.year + 1, 7, 1);
    
    return GameState(
      league: league,
      playerTeamId: playerTeamId,
      currentDate: nextSeasonStart,
      currentDay: 1,
      currentSeason: currentSeason + 1,
    );
  }

  /// Updates the league while preserving other state
  GameState updateLeague(League newLeague) {
    return GameState(
      league: newLeague,
      playerTeamId: playerTeamId,
      currentDate: currentDate,
      currentDay: currentDay,
      currentSeason: currentSeason,
    );
  }

  /// Creates a copy with updated parameters
  GameState copyWith({
    League? league,
    String? playerTeamId,
    DateTime? currentDate,
    int? currentDay,
    int? currentSeason,
  }) {
    return GameState(
      league: league ?? this.league,
      playerTeamId: playerTeamId ?? this.playerTeamId,
      currentDate: currentDate ?? this.currentDate,
      currentDay: currentDay ?? this.currentDay,
      currentSeason: currentSeason ?? this.currentSeason,
    );
  }

  @override
  List<Object?> get props => [
        league,
        playerTeamId,
        currentDate,
        currentDay,
        currentSeason,
      ];

  @override
  String toString() {
    return 'GameState(day: $currentDay, season: $currentSeason, '
        'date: ${currentDate.toIso8601String().split('T')[0]}, '
        'team: $playerTeamId)';
  }
}
