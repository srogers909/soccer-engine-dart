import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'match.dart';

part 'gameweek.g.dart';

/// Represents the status of a gameweek
@JsonEnum()
enum GameweekStatus {
  /// Gameweek is scheduled but not yet started
  scheduled,
  /// Gameweek is currently in progress
  inProgress,
  /// Gameweek has been completed
  completed,
  /// Gameweek has been postponed
  postponed,
  /// Gameweek has been cancelled
  cancelled;
}

/// Represents a gameweek/matchday in a league season
@JsonSerializable(explicitToJson: true)
class Gameweek extends Equatable {
  /// Unique identifier for the gameweek
  final String id;

  /// Gameweek number in the season (1-based)
  final int number;

  /// League season identifier this gameweek belongs to
  final String seasonId;

  /// Scheduled date for the gameweek
  final DateTime scheduledDate;

  /// List of matches in this gameweek
  final List<Match> matches;

  /// Current status of the gameweek
  final GameweekStatus status;

  /// Name/description of the gameweek (optional)
  final String? name;

  /// Whether this is a special gameweek (e.g., cup match, international break)
  final bool isSpecial;

  /// Creates a new gameweek instance
  Gameweek({
    required this.id,
    required this.number,
    required this.seasonId,
    required this.scheduledDate,
    List<Match>? matches,
    this.status = GameweekStatus.scheduled,
    this.name,
    this.isSpecial = false,
  }) : matches = matches ?? [] {
    // Validation
    if (id.isEmpty) throw ArgumentError('Gameweek ID cannot be empty');
    if (seasonId.isEmpty) throw ArgumentError('Season ID cannot be empty');
    if (number < 1) throw ArgumentError('Gameweek number must be positive');
    
    // Validate matches don't have conflicts
    _validateMatches(this.matches);
  }

  /// Creates a gameweek from JSON data
  factory Gameweek.fromJson(Map<String, dynamic> json) => _$GameweekFromJson(json);

  /// Converts the gameweek to JSON data
  Map<String, dynamic> toJson() => _$GameweekToJson(this);

  /// Validates that matches don't have team conflicts
  void _validateMatches(List<Match> matchList) {
    final teamsInMatches = <String>[];
    
    for (final match in matchList) {
      if (teamsInMatches.contains(match.homeTeam.id)) {
        throw ArgumentError('Team ${match.homeTeam.id} appears in multiple matches in the same gameweek');
      }
      if (teamsInMatches.contains(match.awayTeam.id)) {
        throw ArgumentError('Team ${match.awayTeam.id} appears in multiple matches in the same gameweek');
      }
      
      teamsInMatches.add(match.homeTeam.id);
      teamsInMatches.add(match.awayTeam.id);
    }
  }

  /// Adds a match to the gameweek
  Gameweek addMatch(Match match) {
    final updatedMatches = [...matches, match];
    
    return Gameweek(
      id: id,
      number: number,
      seasonId: seasonId,
      scheduledDate: scheduledDate,
      matches: updatedMatches,
      status: status,
      name: name,
      isSpecial: isSpecial,
    );
  }

  /// Removes a match from the gameweek
  Gameweek removeMatch(String matchId) {
    final updatedMatches = matches.where((m) => m.id != matchId).toList();
    
    return Gameweek(
      id: id,
      number: number,
      seasonId: seasonId,
      scheduledDate: scheduledDate,
      matches: updatedMatches,
      status: status,
      name: name,
      isSpecial: isSpecial,
    );
  }

  /// Updates the gameweek status
  Gameweek updateStatus(GameweekStatus newStatus) {
    return Gameweek(
      id: id,
      number: number,
      seasonId: seasonId,
      scheduledDate: scheduledDate,
      matches: matches,
      status: newStatus,
      name: name,
      isSpecial: isSpecial,
    );
  }

  /// Updates the scheduled date
  Gameweek updateScheduledDate(DateTime newDate) {
    return Gameweek(
      id: id,
      number: number,
      seasonId: seasonId,
      scheduledDate: newDate,
      matches: matches,
      status: status,
      name: name,
      isSpecial: isSpecial,
    );
  }

  /// Checks if all matches in the gameweek are completed
  bool get isCompleted {
    return matches.isNotEmpty && matches.every((match) => match.isCompleted);
  }

  /// Checks if any matches in the gameweek have started
  bool get hasStarted {
    return matches.any((match) => match.currentMinute > 0);
  }

  /// Gets the number of completed matches
  int get completedMatchesCount {
    return matches.where((match) => match.isCompleted).length;
  }

  /// Gets the number of scheduled matches
  int get scheduledMatchesCount {
    return matches.where((match) => match.currentMinute == 0).length;
  }

  /// Gets the number of in-progress matches
  int get inProgressMatchesCount {
    return matches.where((match) => match.currentMinute > 0 && !match.isCompleted).length;
  }

  /// Gets all teams participating in this gameweek
  Set<String> get participatingTeams {
    final teams = <String>{};
    for (final match in matches) {
      teams.add(match.homeTeam.id);
      teams.add(match.awayTeam.id);
    }
    return teams;
  }

  /// Gets matches for a specific team
  List<Match> getMatchesForTeam(String teamId) {
    return matches.where((match) => 
        match.homeTeam.id == teamId || match.awayTeam.id == teamId).toList();
  }

  /// Gets the match between two specific teams (if exists)
  Match? getMatchBetweenTeams(String team1Id, String team2Id) {
    try {
      return matches.firstWhere((match) => 
          (match.homeTeam.id == team1Id && match.awayTeam.id == team2Id) ||
          (match.homeTeam.id == team2Id && match.awayTeam.id == team1Id));
    } catch (e) {
      return null;
    }
  }

  /// Gets gameweek statistics
  Map<String, dynamic> get statistics {
    final totalGoals = matches.fold<int>(0, (sum, match) => 
        sum + match.homeGoals + match.awayGoals);
    
    final averageGoals = matches.isEmpty ? 0.0 : totalGoals / matches.length;
    
    return {
      'totalMatches': matches.length,
      'completedMatches': completedMatchesCount,
      'inProgressMatches': inProgressMatchesCount,
      'scheduledMatches': scheduledMatchesCount,
      'participatingTeams': participatingTeams.length,
      'totalGoals': totalGoals,
      'averageGoals': averageGoals.toStringAsFixed(2),
      'isCompleted': isCompleted,
      'hasStarted': hasStarted,
    };
  }

  /// Gets the display name for the gameweek
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return 'Gameweek $number';
  }

  /// Checks if the gameweek can be started (all matches are valid)
  bool get canStart {
    if (matches.isEmpty) return false;
    if (status == GameweekStatus.cancelled) return false;
    
    // Check that no team appears twice
    try {
      _validateMatches(matches);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the earliest match date in the gameweek
  DateTime? get earliestMatchDate {
    if (matches.isEmpty) return null;
    
    final matchDates = matches.map((match) => match.kickoffTime);
    
    return matchDates.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Gets the latest match date in the gameweek
  DateTime? get latestMatchDate {
    if (matches.isEmpty) return null;
    
    final matchDates = matches.map((match) => match.kickoffTime);
    
    return matchDates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  List<Object?> get props => [
        id,
        number,
        seasonId,
        scheduledDate,
        matches,
        status,
        name,
        isSpecial,
      ];

  @override
  String toString() {
    return 'Gameweek(id: $id, number: $number, matches: ${matches.length}, '
        'status: ${status.name}, date: ${scheduledDate.toIso8601String().split('T')[0]})';
  }
}
