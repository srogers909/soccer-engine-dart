import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'team.dart';

part 'league.g.dart';

/// Represents different league formats
@JsonEnum()
enum LeagueFormat {
  /// Standard round-robin format where each team plays every other team twice
  roundRobin,
  /// Single round-robin where each team plays every other team once
  singleRoundRobin,
  /// Playoff format with elimination rounds
  playoff,
  /// Group stage followed by knockout rounds
  groupAndKnockout;
}

/// Represents the tier/division level of a league
@JsonEnum()
enum LeagueTier {
  /// Top tier league (e.g., Premier League, La Liga)
  tier1,
  /// Second tier league (e.g., Championship, La Liga 2)
  tier2,
  /// Third tier league
  tier3,
  /// Fourth tier league
  tier4,
  /// Fifth tier and below
  tier5Plus;

  /// Gets the display name for the tier
  String get displayName {
    switch (this) {
      case LeagueTier.tier1:
        return '1st Tier';
      case LeagueTier.tier2:
        return '2nd Tier';
      case LeagueTier.tier3:
        return '3rd Tier';
      case LeagueTier.tier4:
        return '4th Tier';
      case LeagueTier.tier5Plus:
        return '5th+ Tier';
    }
  }
}

/// Represents league rules for promotion, relegation, and points
@JsonSerializable()
class LeagueRules extends Equatable {
  /// Number of teams promoted to higher tier
  final int promotionSpots;

  /// Number of teams relegated to lower tier
  final int relegationSpots;

  /// Number of teams in promotion playoffs
  final int playoffSpots;

  /// Points awarded for a win
  final int pointsForWin;

  /// Points awarded for a draw
  final int pointsForDraw;

  /// Points awarded for a loss
  final int pointsForLoss;

  /// Whether goal difference is used for tiebreaking
  final bool useGoalDifference;

  /// Whether head-to-head record is used for tiebreaking
  final bool useHeadToHead;

  const LeagueRules({
    this.promotionSpots = 2,
    this.relegationSpots = 3,
    this.playoffSpots = 4,
    this.pointsForWin = 3,
    this.pointsForDraw = 1,
    this.pointsForLoss = 0,
    this.useGoalDifference = true,
    this.useHeadToHead = false,
  });

  /// Creates league rules from JSON data
  factory LeagueRules.fromJson(Map<String, dynamic> json) => _$LeagueRulesFromJson(json);

  /// Converts the league rules to JSON data
  Map<String, dynamic> toJson() => _$LeagueRulesToJson(this);

  @override
  List<Object?> get props => [
        promotionSpots,
        relegationSpots,
        playoffSpots,
        pointsForWin,
        pointsForDraw,
        pointsForLoss,
        useGoalDifference,
        useHeadToHead,
      ];

  @override
  String toString() => 'LeagueRules(promotion: $promotionSpots, relegation: $relegationSpots)';
}

/// Represents a football league with teams, rules, and metadata
@JsonSerializable(explicitToJson: true)
class League extends Equatable {
  /// Unique identifier for the league
  final String id;

  /// League name (e.g., "Premier League", "La Liga")
  final String name;

  /// Country where the league is based
  final String country;

  /// League tier/division level
  final LeagueTier tier;

  /// League format (round-robin, playoff, etc.)
  final LeagueFormat format;

  /// Teams participating in the league
  final List<Team> teams;

  /// League rules for promotion, relegation, and scoring
  final LeagueRules rules;

  /// Year the league was founded
  final int foundedYear;

  /// Maximum number of teams allowed in the league
  final int maxTeams;

  /// Minimum number of teams required for the league
  final int minTeams;

  /// Creates a new league instance
  League({
    required this.id,
    required this.name,
    required this.country,
    this.tier = LeagueTier.tier1,
    this.format = LeagueFormat.roundRobin,
    List<Team>? teams,
    LeagueRules? rules,
    int? foundedYear,
    this.maxTeams = 20,
    this.minTeams = 8,
  })  : teams = teams ?? [],
        rules = rules ?? const LeagueRules(),
        foundedYear = foundedYear ?? DateTime.now().year {
    // Validation
    if (id.isEmpty) throw ArgumentError('League ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('League name cannot be empty');
    if (country.isEmpty) throw ArgumentError('League country cannot be empty');
    if (maxTeams < minTeams) throw ArgumentError('Max teams cannot be less than min teams');
    if (this.foundedYear < 1850 || this.foundedYear > DateTime.now().year) {
      throw ArgumentError('Founded year must be between 1850 and ${DateTime.now().year}');
    }
    if (this.teams.length > maxTeams) {
      throw ArgumentError('Cannot have more than $maxTeams teams');
    }
    if (this.teams.length > 0 && this.teams.length < minTeams) {
      throw ArgumentError('Must have at least $minTeams teams for competitive play');
    }

    // Validate even number of teams for round-robin format
    if (format == LeagueFormat.roundRobin && this.teams.length % 2 != 0) {
      throw ArgumentError('Round-robin format requires an even number of teams');
    }

    // Check for duplicate team IDs
    final teamIds = this.teams.map((t) => t.id).toSet();
    if (teamIds.length != this.teams.length) {
      throw ArgumentError('League cannot contain duplicate teams');
    }
  }

  /// Creates a league from JSON data
  factory League.fromJson(Map<String, dynamic> json) => _$LeagueFromJson(json);

  /// Converts the league to JSON data
  Map<String, dynamic> toJson() => _$LeagueToJson(this);

  /// Adds a team to the league
  League addTeam(Team team) {
    if (teams.any((t) => t.id == team.id)) {
      throw ArgumentError('Team ${team.name} is already in the league');
    }

    if (teams.length >= maxTeams) {
      throw ArgumentError('Cannot add team: league is at maximum capacity ($maxTeams)');
    }

    final updatedTeams = [...teams, team];

    // Check if we still have valid number for format
    if (format == LeagueFormat.roundRobin && updatedTeams.length % 2 != 0) {
      throw ArgumentError('Cannot add team: round-robin format requires even number of teams');
    }

    return League(
      id: id,
      name: name,
      country: country,
      tier: tier,
      format: format,
      teams: updatedTeams,
      rules: rules,
      foundedYear: foundedYear,
      maxTeams: maxTeams,
      minTeams: minTeams,
    );
  }

  /// Removes a team from the league
  League removeTeam(String teamId) {
    final updatedTeams = teams.where((t) => t.id != teamId).toList();

    if (updatedTeams.length > 0 && updatedTeams.length < minTeams) {
      throw ArgumentError('Cannot remove team: would fall below minimum of $minTeams teams');
    }

    return League(
      id: id,
      name: name,
      country: country,
      tier: tier,
      format: format,
      teams: updatedTeams,
      rules: rules,
      foundedYear: foundedYear,
      maxTeams: maxTeams,
      minTeams: minTeams,
    );
  }

  /// Updates league rules
  League updateRules(LeagueRules newRules) {
    return League(
      id: id,
      name: name,
      country: country,
      tier: tier,
      format: format,
      teams: teams,
      rules: newRules,
      foundedYear: foundedYear,
      maxTeams: maxTeams,
      minTeams: minTeams,
    );
  }

  /// Gets a team by ID
  Team? getTeam(String teamId) {
    try {
      return teams.firstWhere((t) => t.id == teamId);
    } catch (e) {
      return null;
    }
  }

  /// Checks if the league is ready for competitive play
  bool get isCompetitive => teams.length >= minTeams;

  /// Checks if the league can start a season with fixture generation
  bool get canStartSeason {
    if (!isCompetitive) return false;
    if ((format == LeagueFormat.roundRobin || format == LeagueFormat.singleRoundRobin) && teams.length % 2 != 0) return false;
    return true;
  }

  /// Gets the number of matchdays/gameweeks required for the season
  int get requiredGameweeks {
    switch (format) {
      case LeagueFormat.roundRobin:
        return (teams.length - 1) * 2; // Each team plays every other team twice
      case LeagueFormat.singleRoundRobin:
        return teams.length - 1; // Each team plays every other team once
      case LeagueFormat.playoff:
      case LeagueFormat.groupAndKnockout:
        // These would need more complex calculation based on tournament structure
        return teams.length - 1; // Simplified for now
    }
  }

  /// Gets league statistics
  Map<String, dynamic> get statistics {
    final totalPlayers = teams.fold<int>(0, (sum, team) => sum + team.players.length);
    final avgSquadSize = teams.isEmpty ? 0.0 : totalPlayers / teams.length;
    final avgOverallRating = teams.isEmpty ? 0.0 : 
        teams.fold<int>(0, (sum, team) => sum + team.overallRating) / teams.length;

    return {
      'totalTeams': teams.length,
      'totalPlayers': totalPlayers,
      'averageSquadSize': avgSquadSize.toStringAsFixed(1),
      'averageOverallRating': avgOverallRating.toStringAsFixed(1),
      'isCompetitive': isCompetitive,
      'canStartSeason': canStartSeason,
      'requiredGameweeks': requiredGameweeks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        country,
        tier,
        format,
        teams,
        rules,
        foundedYear,
        maxTeams,
        minTeams,
      ];

  @override
  String toString() {
    return 'League(id: $id, name: $name, country: $country, teams: ${teams.length}, '
        'tier: ${tier.displayName}, format: ${format.name})';
  }
}
