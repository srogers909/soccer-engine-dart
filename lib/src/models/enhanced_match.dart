import 'package:json_annotation/json_annotation.dart';

part 'enhanced_match.g.dart';

/// Team mentality options for tactical instructions
@JsonEnum()
enum TeamMentality {
  veryDefensive,
  defensive,
  balanced,
  attacking,
  veryAttacking
}

/// Detailed match statistics for Football Manager-style analysis
@JsonSerializable()
class MatchStats {
  double homePossession;
  double awayPossession;
  int homeShots;
  int awayShots;
  int homeShotsOnTarget;
  int awayShotsOnTarget;
  int homePasses;
  int awayPasses;
  double homePassAccuracy;
  double awayPassAccuracy;
  int homeTackles;
  int awayTackles;
  int homeCorners;
  int awayCorners;
  int homeOffsides;
  int awayOffsides;
  int homeFouls;
  int awayFouls;

  MatchStats({
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homePasses,
    required this.awayPasses,
    required this.homePassAccuracy,
    required this.awayPassAccuracy,
    required this.homeTackles,
    required this.awayTackles,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeOffsides,
    required this.awayOffsides,
    required this.homeFouls,
    required this.awayFouls,
  });

  factory MatchStats.fromJson(Map<String, dynamic> json) => _$MatchStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MatchStatsToJson(this);

  @override
  String toString() =>
      'MatchStats(possession: ${homePossession.toStringAsFixed(1)}%-${awayPossession.toStringAsFixed(1)}%, '
      'shots: $homeShots-$awayShots, passAccuracy: ${homePassAccuracy.toStringAsFixed(1)}%-${awayPassAccuracy.toStringAsFixed(1)}%)';
}

/// Individual player performance during a match
@JsonSerializable()
class PlayerPerformance {
  final String playerId;
  final String playerName;
  final double rating; // 1.0 to 10.0 Football Manager style rating
  final int goals;
  final int assists;
  final int shots;
  final int shotsOnTarget;
  final int passes;
  final double passAccuracy;
  final int tackles;
  final int fouls;
  final int yellowCards;
  final int redCards;
  final int minutesPlayed;

  const PlayerPerformance({
    required this.playerId,
    required this.playerName,
    required this.rating,
    this.goals = 0,
    this.assists = 0,
    this.shots = 0,
    this.shotsOnTarget = 0,
    this.passes = 0,
    this.passAccuracy = 0.0,
    this.tackles = 0,
    this.fouls = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.minutesPlayed = 0,
  });

  factory PlayerPerformance.fromJson(Map<String, dynamic> json) => _$PlayerPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerPerformanceToJson(this);

  @override
  String toString() =>
      'PlayerPerformance($playerName: rating ${rating.toStringAsFixed(1)}, '
      '${minutesPlayed}min, $goals goals, $assists assists)';
}

/// Tracks match momentum changes over time
@JsonSerializable()
class MomentumTracker {
  double homeMomentum; // 0.0 to 100.0
  double awayMomentum; // 0.0 to 100.0
  int lastShift;
  List<String> shiftEvents;

  MomentumTracker({
    required this.homeMomentum,
    required this.awayMomentum,
    required this.lastShift,
    required this.shiftEvents,
  });

  factory MomentumTracker.fromJson(Map<String, dynamic> json) => _$MomentumTrackerFromJson(json);
  Map<String, dynamic> toJson() => _$MomentumTrackerToJson(this);

  @override
  String toString() =>
      'MomentumTracker(home ${homeMomentum.toStringAsFixed(1)}%, '
      'away ${awayMomentum.toStringAsFixed(1)}%, lastShift: $lastShift)';
}

/// Team tactical instructions for matches
@JsonSerializable()
class TeamTactics {
  final TeamMentality mentality;
  final int pressing;
  final int tempo;
  final int width;
  final int directness;

  const TeamTactics({
    required this.mentality,
    required this.pressing,
    required this.tempo,
    required this.width,
    required this.directness,
  });

  /// Gets the attacking modifier based on mentality and tactics
  double get attackingModifier {
    double modifier = 1.0;

    // Mentality effects
    switch (mentality) {
      case TeamMentality.veryDefensive:
        modifier *= 0.7;
        break;
      case TeamMentality.defensive:
        modifier *= 0.85;
        break;
      case TeamMentality.balanced:
        modifier *= 1.0;
        break;
      case TeamMentality.attacking:
        modifier *= 1.15;
        break;
      case TeamMentality.veryAttacking:
        modifier *= 1.3;
        break;
    }

    // Tempo effects
    modifier *= (0.8 + (tempo * 0.004)); // Range: 0.8 to 1.2

    // Width effects (wider play can create more chances)
    modifier *= (0.95 + (width * 0.001)); // Range: 0.95 to 1.05

    return modifier;
  }

  /// Gets the defensive modifier based on mentality and tactics
  double get defensiveModifier {
    double modifier = 1.0;

    // Mentality effects (inverse of attacking)
    switch (mentality) {
      case TeamMentality.veryDefensive:
        modifier *= 1.3;
        break;
      case TeamMentality.defensive:
        modifier *= 1.15;
        break;
      case TeamMentality.balanced:
        modifier *= 1.0;
        break;
      case TeamMentality.attacking:
        modifier *= 0.85;
        break;
      case TeamMentality.veryAttacking:
        modifier *= 0.7;
        break;
    }

    // Pressing intensity effects
    modifier *= (0.9 + (pressing * 0.002)); // Range: 0.9 to 1.1

    return modifier;
  }

  factory TeamTactics.fromJson(Map<String, dynamic> json) => _$TeamTacticsFromJson(json);
  Map<String, dynamic> toJson() => _$TeamTacticsToJson(this);

  @override
  String toString() =>
      'TeamTactics(mentality: $mentality, pressing: $pressing, tempo: $tempo)';
}
