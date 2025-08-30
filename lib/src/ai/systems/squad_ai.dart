import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:soccer_utilities/src/models/player.dart';
import '../../models/team.dart';
import '../../models/tactics.dart' hide Formation, PlayerPosition;
import '../engines/decision_engine.dart';
import '../models/gm_profile.dart';

part 'squad_ai.g.dart';

/// Types of squad decisions
enum SquadDecisionType {
  formation,
  lineup,
  substitution,
  captaincy,
  rotation,
  restPolicy,
}

/// Squad optimization priorities
enum SquadPriority {
  fitness,
  form,
  chemistry,
  experience,
  youth,
  balance,
  attack,
  defense,
}

/// Squad analysis result
@JsonSerializable(explicitToJson: true)
class SquadAnalysis extends Equatable {
  /// Formation recommendations with confidence scores
  final Map<Formation, double> formationRecommendations;
  
  /// Optimal starting XI
  final List<Player> optimalLineup;
  
  /// Bench recommendations
  final List<Player> benchPlayers;
  
  /// Captain recommendation
  final Player? captainRecommendation;
  
  /// Squad balance assessment
  final Map<String, double> balanceScores;
  
  /// Areas needing improvement
  final List<String> improvementAreas;
  
  /// Analysis confidence
  final double confidence;
  
  /// Analysis timestamp
  final DateTime timestamp;

  const SquadAnalysis({
    required this.formationRecommendations,
    required this.optimalLineup,
    required this.benchPlayers,
    this.captainRecommendation,
    required this.balanceScores,
    required this.improvementAreas,
    required this.confidence,
    required this.timestamp,
  });

  /// Creates a SquadAnalysis from JSON
  factory SquadAnalysis.fromJson(Map<String, dynamic> json) => 
      _$SquadAnalysisFromJson(json);

  /// Converts this SquadAnalysis to JSON
  Map<String, dynamic> toJson() => _$SquadAnalysisToJson(this);

  @override
  List<Object?> get props => [
    formationRecommendations,
    optimalLineup,
    benchPlayers,
    captainRecommendation,
    balanceScores,
    improvementAreas,
    confidence,
    timestamp,
  ];
}

/// Player form and fitness tracking
@JsonSerializable()
class PlayerCondition extends Equatable {
  /// Player ID
  final String playerId;
  
  /// Current fitness level (0-100)
  final int fitness;
  
  /// Current form rating (0-100)
  final int form;
  
  /// Matches played recently
  final int recentMatches;
  
  /// Minutes played this season
  final int minutesPlayed;
  
  /// Injury risk level (0-100)
  final int injuryRisk;
  
  /// Last match performance rating
  final int lastPerformance;
  
  /// Morale level (0-100)
  final int morale;

  const PlayerCondition({
    required this.playerId,
    required this.fitness,
    required this.form,
    required this.recentMatches,
    required this.minutesPlayed,
    required this.injuryRisk,
    required this.lastPerformance,
    required this.morale,
  });

  /// Creates a PlayerCondition from JSON
  factory PlayerCondition.fromJson(Map<String, dynamic> json) => 
      _$PlayerConditionFromJson(json);

  /// Converts this PlayerCondition to JSON
  Map<String, dynamic> toJson() => _$PlayerConditionToJson(this);

  /// Overall readiness score for selection
  double get readinessScore {
    // Weighted combination of factors
    return (fitness * 0.3 + 
            form * 0.3 + 
            (100 - injuryRisk) * 0.2 + 
            morale * 0.2) / 100;
  }

  /// Needs rest based on condition
  bool get needsRest {
    return fitness < 75 || injuryRisk > 60 || recentMatches > 3;
  }

  @override
  List<Object?> get props => [
    playerId,
    fitness,
    form,
    recentMatches,
    minutesPlayed,
    injuryRisk,
    lastPerformance,
    morale,
  ];
}

/// AI system for squad management and tactical decisions
@JsonSerializable(explicitToJson: true)
class SquadAI extends Equatable {
  /// Decision engine for squad decisions
  final DecisionEngine decisionEngine;
  
  /// Current squad priorities
  final List<SquadPriority> priorities;
  
  /// Player condition tracking
  final List<PlayerCondition> playerConditions;
  
  /// Preferred formation
  final Formation? preferredFormation;
  
  /// Auto-rotate players based on condition
  final bool autoRotation;
  
  /// Minimum fitness threshold for selection
  final int minFitnessThreshold;

  const SquadAI({
    required this.decisionEngine,
    this.priorities = const [SquadPriority.balance],
    this.playerConditions = const [],
    this.preferredFormation,
    this.autoRotation = true,
    this.minFitnessThreshold = 75,
  });

  /// Creates a SquadAI from JSON
  factory SquadAI.fromJson(Map<String, dynamic> json) => 
      _$SquadAIFromJson(json);

  /// Converts this SquadAI to JSON
  Map<String, dynamic> toJson() => _$SquadAIToJson(this);

  /// Analyzes squad and provides recommendations
  SquadAnalysis analyzeSquad({
    required Team team,
    required List<PlayerCondition>? conditions,
    SquadPriority? priority,
  }) {
    final effectiveConditions = conditions ?? playerConditions;
    final effectivePriority = priority ?? priorities.first;
    
    final formationRecs = _analyzeFormations(team, effectiveConditions);
    final optimalLineup = _selectOptimalLineup(team, effectiveConditions, effectivePriority);
    final bench = _selectBench(team, optimalLineup, effectiveConditions);
    final captain = _selectCaptain(optimalLineup, effectiveConditions);
    final balance = _assessSquadBalance(team, optimalLineup);
    final improvements = _identifyImprovements(team, balance);
    
    return SquadAnalysis(
      formationRecommendations: formationRecs,
      optimalLineup: optimalLineup,
      benchPlayers: bench,
      captainRecommendation: captain,
      balanceScores: balance,
      improvementAreas: improvements,
      confidence: _calculateAnalysisConfidence(team, optimalLineup),
      timestamp: DateTime.now(),
    );
  }

  /// Makes a formation decision
  Decision makeFormationDecision({
    required Team team,
    required List<Formation> availableFormations,
  }) {
    final context = _buildFormationContext(team, availableFormations);
    
    return decisionEngine.makeDecision(
      type: DecisionType.formation,
      options: availableFormations.map((f) => f.displayName).toList(),
      context: context,
    );
  }

  /// Makes a lineup decision
  Decision makeLineupDecision({
    required Team team,
    required Formation formation,
    required List<Player> availablePlayers,
  }) {
    final context = _buildLineupContext(team, formation, availablePlayers);
    
    return decisionEngine.makeDecision(
      type: DecisionType.lineup,
      options: ['optimal', 'rotation', 'youth_focus'],
      context: context,
    );
  }

  /// Makes a substitution decision during a match
  Decision makeSubstitutionDecision({
    required List<Player> currentLineup,
    required List<Player> bench,
    required Map<String, dynamic> matchContext,
  }) {
    final context = _buildSubstitutionContext(currentLineup, bench, matchContext);
    
    return decisionEngine.makeDecision(
      type: DecisionType.tactics,
      options: ['attacking_sub', 'defensive_sub', 'fresh_legs', 'no_change'],
      context: context,
    );
  }

  /// Analyzes formation suitability for current squad
  Map<Formation, double> _analyzeFormations(Team team, List<PlayerCondition> conditions) {
    final formations = <Formation, double>{};
    
    for (final formation in Formation.values) {
      double suitability = _calculateFormationSuitability(team, formation, conditions);
      
      // Apply GM personality preferences
      final gmPreference = decisionEngine.gmProfile.getFormationPreferenceWeight(
        formation: formation.displayName,
        availablePlayers: team.players.length,
      );
      
      suitability = (suitability * 0.7) + (gmPreference * 0.3);
      formations[formation] = suitability.clamp(0.0, 1.0);
    }
    
    return formations;
  }

  /// Calculates how well a formation suits the current squad
  double _calculateFormationSuitability(Team team, Formation formation, List<PlayerCondition> conditions) {
    final requirements = formation.requirements;
    final positionCounts = <PlayerPosition, int>{};
    
    // Count available players by position (considering fitness)
    for (final player in team.players) {
      final condition = conditions.firstWhere(
        (c) => c.playerId == player.id,
        orElse: () => PlayerCondition(
          playerId: player.id,
          fitness: 85,
          form: 75,
          recentMatches: 1,
          minutesPlayed: 0,
          injuryRisk: 20,
          lastPerformance: 75,
          morale: 80,
        ),
      );
      
      if (condition.fitness >= minFitnessThreshold) {
        positionCounts[player.position] = (positionCounts[player.position] ?? 0) + 1;
      }
    }
    
    // Check if we have enough players for each position
    double suitability = 1.0;
    
    final gkAvailable = positionCounts[PlayerPosition.goalkeeper] ?? 0;
    final defAvailable = positionCounts[PlayerPosition.defender] ?? 0;
    final midAvailable = positionCounts[PlayerPosition.midfielder] ?? 0;
    final fwdAvailable = positionCounts[PlayerPosition.forward] ?? 0;
    
    if (gkAvailable < requirements[0]) suitability *= 0.5; // GK shortage is critical
    if (defAvailable < requirements[1]) suitability *= 0.8;
    if (midAvailable < requirements[2]) suitability *= 0.8;
    if (fwdAvailable < requirements[3]) suitability *= 0.9;
    
    return suitability;
  }

  /// Selects optimal starting XI based on priorities
  List<Player> _selectOptimalLineup(Team team, List<PlayerCondition> conditions, SquadPriority priority) {
    final availablePlayers = team.players.where((player) {
      final condition = conditions.firstWhere(
        (c) => c.playerId == player.id,
        orElse: () => PlayerCondition(
          playerId: player.id,
          fitness: 85,
          form: 75,
          recentMatches: 1,
          minutesPlayed: 0,
          injuryRisk: 20,
          lastPerformance: 75,
          morale: 80,
        ),
      );
      return condition.fitness >= minFitnessThreshold;
    }).toList();

    final formation = preferredFormation ?? team.formation;
    final requirements = formation.requirements;
    final lineup = <Player>[];

    // Select by position based on requirements
    final playersByPosition = <PlayerPosition, List<Player>>{};
    for (final player in availablePlayers) {
      playersByPosition.putIfAbsent(player.position, () => []).add(player);
    }

    // Sort players by selection criteria based on priority
    for (final entry in playersByPosition.entries) {
      entry.value.sort((a, b) => _comparePlayersForSelection(a, b, conditions, priority));
    }

    // Select required number for each position
    _selectPlayersByPosition(lineup, playersByPosition, PlayerPosition.goalkeeper, requirements[0]);
    _selectPlayersByPosition(lineup, playersByPosition, PlayerPosition.defender, requirements[1]);
    _selectPlayersByPosition(lineup, playersByPosition, PlayerPosition.midfielder, requirements[2]);
    _selectPlayersByPosition(lineup, playersByPosition, PlayerPosition.forward, requirements[3]);

    return lineup;
  }

  /// Selects players for a specific position
  void _selectPlayersByPosition(
    List<Player> lineup,
    Map<PlayerPosition, List<Player>> playersByPosition,
    PlayerPosition position,
    int required,
  ) {
    final available = playersByPosition[position] ?? [];
    final toSelect = available.take(required);
    lineup.addAll(toSelect);
  }

  /// Compares two players for selection priority
  int _comparePlayersForSelection(
    Player a,
    Player b,
    List<PlayerCondition> conditions,
    SquadPriority priority,
  ) {
    final conditionA = conditions.firstWhere((c) => c.playerId == a.id, orElse: () => _defaultCondition(a.id));
    final conditionB = conditions.firstWhere((c) => c.playerId == b.id, orElse: () => _defaultCondition(b.id));

    switch (priority) {
      case SquadPriority.fitness:
        return conditionB.fitness.compareTo(conditionA.fitness);
      case SquadPriority.form:
        return conditionB.form.compareTo(conditionA.form);
      case SquadPriority.experience:
        return b.age.compareTo(a.age);
      case SquadPriority.youth:
        return a.age.compareTo(b.age);
      case SquadPriority.chemistry:
        return conditionB.morale.compareTo(conditionA.morale);
      default:
        // Default to overall rating
        return b.overallRating.compareTo(a.overallRating);
    }
  }

  /// Creates default condition for player
  PlayerCondition _defaultCondition(String playerId) {
    return PlayerCondition(
      playerId: playerId,
      fitness: 85,
      form: 75,
      recentMatches: 1,
      minutesPlayed: 0,
      injuryRisk: 20,
      lastPerformance: 75,
      morale: 80,
    );
  }

  /// Selects bench players
  List<Player> _selectBench(Team team, List<Player> lineup, List<PlayerCondition> conditions) {
    final startingIds = lineup.map((p) => p.id).toSet();
    final availableForBench = team.players.where((p) => !startingIds.contains(p.id)).toList();
    
    // Sort by overall utility and condition
    availableForBench.sort((a, b) {
      final conditionA = conditions.firstWhere((c) => c.playerId == a.id, orElse: () => _defaultCondition(a.id));
      final conditionB = conditions.firstWhere((c) => c.playerId == b.id, orElse: () => _defaultCondition(b.id));
      
      final scoreA = a.overallRating * conditionA.readinessScore;
      final scoreB = b.overallRating * conditionB.readinessScore;
      
      return scoreB.compareTo(scoreA);
    });
    
    return availableForBench.take(7).toList(); // Standard bench size
  }

  /// Selects team captain
  Player? _selectCaptain(List<Player> lineup, List<PlayerCondition> conditions) {
    if (lineup.isEmpty) return null;
    
    // Captain selection criteria: experience, morale, position importance
    var bestCandidate = lineup.first;
    var bestScore = 0.0;
    
    for (final player in lineup) {
      final condition = conditions.firstWhere((c) => c.playerId == player.id, orElse: () => _defaultCondition(player.id));
      
      var score = 0.0;
      score += player.age * 0.3; // Experience
      score += condition.morale * 0.4; // Leadership/morale
      score += player.overallRating * 0.3; // Quality
      
      // Position bonus (defenders and midfielders often make good captains)
      if (player.position == PlayerPosition.defender || player.position == PlayerPosition.midfielder) {
        score *= 1.1;
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestCandidate = player;
      }
    }
    
    return bestCandidate;
  }

  /// Assesses squad balance across different metrics
  Map<String, double> _assessSquadBalance(Team team, List<Player> lineup) {
    final balance = <String, double>{};
    
    // Age balance
    final avgAge = lineup.map((p) => p.age).reduce((a, b) => a + b) / lineup.length;
    balance['age_balance'] = _calculateAgeBalance(avgAge);
    
    // Position balance
    balance['position_balance'] = _calculatePositionBalance(lineup);
    
    // Quality balance
    final avgRating = lineup.map((p) => p.overallRating).reduce((a, b) => a + b) / lineup.length;
    balance['quality_balance'] = (avgRating / 100).clamp(0.0, 1.0);
    
    // Experience vs Youth balance
    final youngPlayers = lineup.where((p) => p.age <= 23).length;
    final experiencedPlayers = lineup.where((p) => p.age >= 28).length;
    balance['experience_youth_balance'] = _calculateExperienceYouthBalance(youngPlayers, experiencedPlayers);
    
    return balance;
  }

  /// Calculates age balance score
  double _calculateAgeBalance(double avgAge) {
    // Ideal average age is around 26-28
    if (avgAge >= 26 && avgAge <= 28) return 1.0;
    if (avgAge >= 24 && avgAge <= 30) return 0.8;
    if (avgAge >= 22 && avgAge <= 32) return 0.6;
    return 0.4;
  }

  /// Calculates position balance score
  double _calculatePositionBalance(List<Player> lineup) {
    final positionCounts = <PlayerPosition, int>{};
    for (final player in lineup) {
      positionCounts[player.position] = (positionCounts[player.position] ?? 0) + 1;
    }
    
    // Check if formation requirements are met
    final formation = preferredFormation ?? Formation.f442;
    final requirements = formation.requirements;
    
    var balance = 1.0;
    if ((positionCounts[PlayerPosition.goalkeeper] ?? 0) != requirements[0]) balance *= 0.5;
    if ((positionCounts[PlayerPosition.defender] ?? 0) != requirements[1]) balance *= 0.8;
    if ((positionCounts[PlayerPosition.midfielder] ?? 0) != requirements[2]) balance *= 0.8;
    if ((positionCounts[PlayerPosition.forward] ?? 0) != requirements[3]) balance *= 0.8;
    
    return balance;
  }

  /// Calculates experience vs youth balance
  double _calculateExperienceYouthBalance(int youngPlayers, int experiencedPlayers) {
    // Ideal mix: 3-4 young, 3-4 experienced, rest in between
    if (youngPlayers >= 3 && youngPlayers <= 4 && experiencedPlayers >= 3 && experiencedPlayers <= 4) {
      return 1.0;
    }
    return 0.7;
  }

  /// Identifies areas for improvement
  List<String> _identifyImprovements(Team team, Map<String, double> balance) {
    final improvements = <String>[];
    
    if (balance['age_balance']! < 0.7) {
      improvements.add('Improve age balance in squad');
    }
    if (balance['position_balance']! < 0.8) {
      improvements.add('Address positional imbalances');
    }
    if (balance['quality_balance']! < 0.7) {
      improvements.add('Upgrade overall squad quality');
    }
    if (balance['experience_youth_balance']! < 0.8) {
      improvements.add('Better experience-youth mix needed');
    }
    
    return improvements;
  }

  /// Calculates confidence in analysis
  double _calculateAnalysisConfidence(Team team, List<Player> lineup) {
    if (lineup.length != 11) return 0.3;
    
    var confidence = 0.8;
    
    // Reduce confidence if squad is unbalanced
    if (team.chemistry < 70) confidence *= 0.9;
    if (team.players.length < Team.minSquadSize) confidence *= 0.8;
    
    return confidence.clamp(0.3, 0.95);
  }

  /// Builds context for formation decisions
  Map<String, dynamic> _buildFormationContext(Team team, List<Formation> formations) {
    return {
      'squad_size': team.players.length,
      'team_chemistry': team.chemistry,
      'available_formations': formations.map((f) => f.displayName).toList(),
      'current_formation': team.formation.displayName,
      'team_morale': team.morale,
      'available_players': team.players.length,
    };
  }

  /// Builds context for lineup decisions
  Map<String, dynamic> _buildLineupContext(Team team, Formation formation, List<Player> players) {
    final avgFitness = playerConditions.isEmpty ? 85.0 : 
        playerConditions.map((c) => c.fitness).reduce((a, b) => a + b) / playerConditions.length;
        
    return {
      'formation': formation.displayName,
      'available_players': players.length,
      'avg_fitness': avgFitness,
      'team_chemistry': team.chemistry,
      'rotation_needed': autoRotation && avgFitness < 80,
    };
  }

  /// Builds context for substitution decisions
  Map<String, dynamic> _buildSubstitutionContext(
    List<Player> lineup,
    List<Player> bench,
    Map<String, dynamic> matchContext,
  ) {
    return {
      'current_score': matchContext['score'] ?? '0-0',
      'match_minute': matchContext['minute'] ?? 45,
      'bench_quality': bench.isEmpty ? 0 : bench.map((p) => p.overallRating).reduce((a, b) => a + b) / bench.length,
      'lineup_fatigue': matchContext['fatigue_level'] ?? 0.5,
      ...matchContext,
    };
  }

  /// Creates a copy with updated properties
  SquadAI copyWith({
    DecisionEngine? decisionEngine,
    List<SquadPriority>? priorities,
    List<PlayerCondition>? playerConditions,
    Formation? preferredFormation,
    bool? autoRotation,
    int? minFitnessThreshold,
  }) {
    return SquadAI(
      decisionEngine: decisionEngine ?? this.decisionEngine,
      priorities: priorities ?? this.priorities,
      playerConditions: playerConditions ?? this.playerConditions,
      preferredFormation: preferredFormation ?? this.preferredFormation,
      autoRotation: autoRotation ?? this.autoRotation,
      minFitnessThreshold: minFitnessThreshold ?? this.minFitnessThreshold,
    );
  }

  @override
  List<Object?> get props => [
    decisionEngine,
    priorities,
    playerConditions,
    preferredFormation,
    autoRotation,
    minFitnessThreshold,
  ];
}
