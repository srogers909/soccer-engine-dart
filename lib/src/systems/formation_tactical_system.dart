import 'dart:math';
import '../models/team.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';
import '../models/enhanced_match.dart';
import '../models/tactical_analysis.dart';
import '../models/match.dart';

/// System for managing formations, tactics, and strategic decisions
class FormationTacticalSystem {
  final Random _random = Random();

  /// Validates if a team can play with the specified formation
  ValidationResult validateFormation(Team team, Formation formation) {
    final errors = <String>[];

    if (team.players.isEmpty) {
      errors.add('No players available');
      return ValidationResult(isValid: false, errors: errors);
    }

    if (team.players.length < 11) {
      errors.add('Insufficient players (need at least 11, have ${team.players.length})');
    }

    // Check position availability for formation
    final positionRequirements = _getFormationRequirements(formation);
    final availablePositions = _getAvailablePositions(team);

    for (final entry in positionRequirements.entries) {
      final position = entry.key;
      final required = entry.value;
      final available = availablePositions[position] ?? 0;

      if (available < required) {
        errors.add('Not enough ${position.name}s (need $required, have $available)');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Gets formation recommendations based on team composition
  List<FormationRecommendation> getFormationRecommendations(Team team) {
    final recommendations = <FormationRecommendation>[];
    final formations = Formation.values;

    for (final formation in formations) {
      final suitability = _calculateFormationSuitability(team, formation);
      final reasons = _getFormationReasons(team, formation, suitability);

      recommendations.add(FormationRecommendation(
        formation: formation,
        suitabilityScore: suitability,
        reasons: reasons,
      ));
    }

    // Sort by suitability score (highest first)
    recommendations.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
    return recommendations;
  }

  /// Generates optimal starting XI for the given formation
  List<Player>? generateOptimalStartingXI(Team team, Formation formation) {
    if (team.players.length < 11) return null;

    final requirements = _getFormationRequirements(formation);
    final startingXI = <Player>[];

    // Select players by position based on formation requirements
    for (final entry in requirements.entries) {
      final position = entry.key;
      final count = entry.value;

      final positionPlayers = team.players
          .where((p) => p.position == position)
          .toList()
        ..sort((a, b) => b.overallRating.compareTo(a.overallRating));

      if (positionPlayers.length < count) {
        // Not enough players for this position
        return null;
      }

      startingXI.addAll(positionPlayers.take(count));
    }

    return startingXI.length == 11 ? startingXI : null;
  }

  /// Applies a formation change to the team
  Team applyFormationChange(Team team, Formation newFormation) {
    return team.copyWith(formation: newFormation);
  }

  /// Validates tactical instructions
  ValidationResult validateTactics(TeamTactics tactics) {
    final errors = <String>[];

    if (tactics.pressing < 0 || tactics.pressing > 100) {
      errors.add('pressing must be between 0 and 100 (current: ${tactics.pressing})');
    }

    if (tactics.tempo < 0 || tactics.tempo > 100) {
      errors.add('tempo must be between 0 and 100 (current: ${tactics.tempo})');
    }

    if (tactics.width < 0 || tactics.width > 100) {
      errors.add('Width must be between 0 and 100 (current: ${tactics.width})');
    }

    if (tactics.directness < 0 || tactics.directness > 100) {
      errors.add('Directness must be between 0 and 100 (current: ${tactics.directness})');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Gets predefined tactical presets for different playstyles
  Map<String, TeamTactics> getTacticalPresets() {
    return {
      'Attacking': TeamTactics(
        mentality: TeamMentality.attacking,
        pressing: 75,
        tempo: 80,
        width: 70,
        directness: 60,
      ),
      'Defensive': TeamTactics(
        mentality: TeamMentality.defensive,
        pressing: 45,
        tempo: 40,
        width: 50,
        directness: 45,
      ),
      'Balanced': TeamTactics(
        mentality: TeamMentality.balanced,
        pressing: 55,
        tempo: 55,
        width: 55,
        directness: 55,
      ),
      'Counter Attack': TeamTactics(
        mentality: TeamMentality.defensive,
        pressing: 35,
        tempo: 85,
        width: 40,
        directness: 80,
      ),
      'Possession': TeamTactics(
        mentality: TeamMentality.balanced,
        pressing: 65,
        tempo: 45,
        width: 75,
        directness: 30,
      ),
      'High Press': TeamTactics(
        mentality: TeamMentality.attacking,
        pressing: 95,
        tempo: 75,
        width: 60,
        directness: 55,
      ),
    };
  }

  /// Calculates tactical compatibility with formation
  TacticalCompatibility calculateTacticalCompatibility(Formation formation, TeamTactics tactics) {
    double score = 50.0; // Base score
    final warnings = <String>[];

    // Formation-specific tactical compatibility
    switch (formation) {
      case Formation.f541:
      case Formation.f532:
        // Defensive formations
        if (tactics.mentality == TeamMentality.veryAttacking || tactics.mentality == TeamMentality.attacking) {
          score -= 20;
          warnings.add('Attacking mentality conflicts with defensive formation');
        }
        if (tactics.pressing > 70) {
          score -= 15;
          warnings.add('High pressing may be difficult with defensive formation');
        }
        break;

      case Formation.f343:
      case Formation.f352:
        // Attacking formations
        if (tactics.mentality == TeamMentality.veryDefensive || tactics.mentality == TeamMentality.defensive) {
          score -= 20;
          warnings.add('Defensive mentality conflicts with attacking formation');
        }
        if (tactics.pressing < 40) {
          score -= 10;
          warnings.add('Low pressing may not suit attacking formation');
        }
        break;

      case Formation.f442:
      case Formation.f433:
      case Formation.f451:
      case Formation.f4231:
      case Formation.f4141:
      case Formation.f3421:
        // Balanced formations - more flexible
        score += 10;
        break;
    }

    // Tactical consistency checks
    if (tactics.mentality == TeamMentality.veryAttacking && tactics.tempo < 60) {
      warnings.add('Very attacking mentality usually requires higher tempo');
      score -= 10;
    }

    if (tactics.mentality == TeamMentality.veryDefensive && tactics.width > 70) {
      warnings.add('Very defensive mentality usually requires narrower play');
      score -= 10;
    }

    return TacticalCompatibility(
      score: score.clamp(0, 100),
      warnings: warnings,
    );
  }

  /// Suggests tactical adjustments for better compatibility
  List<TacticalAdjustment> suggestTacticalAdjustments(Formation formation, TeamTactics tactics) {
    final suggestions = <TacticalAdjustment>[];

    // Formation-specific adjustments
    switch (formation) {
      case Formation.f343:
        if (tactics.pressing < 60) {
          suggestions.add(TacticalAdjustment(
            parameter: 'pressing',
            currentValue: tactics.pressing,
            suggestedValue: 70,
            reason: '3-4-3 formation benefits from higher pressing to support attacking play',
          ));
        }
        if (tactics.tempo < 65) {
          suggestions.add(TacticalAdjustment(
            parameter: 'tempo',
            currentValue: tactics.tempo,
            suggestedValue: 75,
            reason: 'Higher tempo suits the attacking nature of 3-4-3',
          ));
        }
        break;

      case Formation.f541:
        if (tactics.pressing > 60) {
          suggestions.add(TacticalAdjustment(
            parameter: 'pressing',
            currentValue: tactics.pressing,
            suggestedValue: 45,
            reason: '5-4-1 formation works better with lower pressing to maintain defensive shape',
          ));
        }
        if (tactics.width > 60) {
          suggestions.add(TacticalAdjustment(
            parameter: 'width',
            currentValue: tactics.width,
            suggestedValue: 50,
            reason: 'Narrower play helps maintain defensive solidity in 5-4-1',
          ));
        }
        break;

      case Formation.f433:
        if (tactics.width < 60) {
          suggestions.add(TacticalAdjustment(
            parameter: 'width',
            currentValue: tactics.width,
            suggestedValue: 70,
            reason: '4-3-3 formation benefits from wider play to stretch the opposition',
          ));
        }
        break;

      default:
        break;
    }

    return suggestions;
  }

  /// Plans tactical changes for different match scenarios
  PlannedTacticalChange planTacticalChanges(Team team, MatchScenario scenario) {
    switch (scenario) {
      case MatchScenario.losing:
        return PlannedTacticalChange(
          targetMinute: 60,
          newTactics: TeamTactics(
            mentality: TeamMentality.attacking,
            pressing: 80,
            tempo: 85,
            width: 75,
            directness: 70,
          ),
          reason: 'Need to push forward more aggressively to equalize',
        );

      case MatchScenario.winning:
        return PlannedTacticalChange(
          targetMinute: 70,
          newTactics: TeamTactics(
            mentality: TeamMentality.defensive,
            pressing: 40,
            tempo: 45,
            width: 50,
            directness: 60,
          ),
          reason: 'Protect the lead by playing more defensively',
        );

      case MatchScenario.drawing:
        return PlannedTacticalChange(
          targetMinute: 75,
          newTactics: TeamTactics(
            mentality: TeamMentality.attacking,
            pressing: 70,
            tempo: 75,
            width: 65,
            directness: 65,
          ),
          reason: 'Push for a winner in the final stages',
        );

      case MatchScenario.behindByTwo:
        return PlannedTacticalChange(
          targetMinute: 45,
          newTactics: TeamTactics(
            mentality: TeamMentality.veryAttacking,
            pressing: 90,
            tempo: 90,
            width: 80,
            directness: 75,
          ),
          reason: 'Desperate need to score goals - all-out attack',
        );

      case MatchScenario.playerSentOff:
        return PlannedTacticalChange(
          targetMinute: 0, // Immediate
          newTactics: TeamTactics(
            mentality: TeamMentality.defensive,
            pressing: 30,
            tempo: 40,
            width: 45,
            directness: 70,
          ),
          reason: 'Adapt to playing with 10 men - more defensive and direct',
        );
    }
  }

  /// Recommends substitutions based on match scenario
  List<SubstitutionRecommendation> recommendSubstitutions(Team team, int currentMinute, MatchScenario scenario) {
    final recommendations = <SubstitutionRecommendation>[];
    final players = team.players.toList();

    if (players.length < 14) return recommendations; // Need bench players

    // Get starting XI and bench players
    final startingXI = players.take(11).toList();
    final benchPlayers = players.skip(11).toList();

    switch (scenario) {
      case MatchScenario.losing:
        // Bring on attacking players
        final defenderOnField = startingXI.firstWhere(
          (p) => p.position == PlayerPosition.defender,
          orElse: () => startingXI.first,
        );
        final attackerOnBench = benchPlayers.firstWhere(
          (p) => p.position == PlayerPosition.forward,
          orElse: () => benchPlayers.first,
        );

        recommendations.add(SubstitutionRecommendation(
          playerOut: defenderOnField,
          playerIn: attackerOnBench,
          reason: 'Replace defender with attacker to increase goal threat',
          priority: 1,
        ));
        break;

      case MatchScenario.winning:
        if (currentMinute > 70) {
          // Bring on defensive players
          final forwardOnField = startingXI.firstWhere(
            (p) => p.position == PlayerPosition.forward,
            orElse: () => startingXI.first,
          );
          final defenderOnBench = benchPlayers.firstWhere(
            (p) => p.position == PlayerPosition.defender,
            orElse: () => benchPlayers.first,
          );

          recommendations.add(SubstitutionRecommendation(
            playerOut: forwardOnField,
            playerIn: defenderOnBench,
            reason: 'Strengthen defense to protect the lead',
            priority: 2,
          ));
        }
        break;

      case MatchScenario.playerSentOff:
        // Sacrifice an attacker for defensive stability
        final forwardOnField = startingXI.firstWhere(
          (p) => p.position == PlayerPosition.forward,
          orElse: () => startingXI.first,
        );
        final defenderOnBench = benchPlayers.firstWhere(
          (p) => p.position == PlayerPosition.defender,
          orElse: () => benchPlayers.first,
        );

        recommendations.add(SubstitutionRecommendation(
          playerOut: forwardOnField,
          playerIn: defenderOnBench,
          reason: 'Add defensive stability after red card',
          priority: 1,
        ));
        break;

      default:
        break;
    }

    return recommendations;
  }

  /// Adapts tactics based on match momentum
  MomentumTacticalAdaptation adaptTacticsToMomentum(Team team, MomentumTracker momentum, {required bool isHomeTeam}) {
    final teamMomentum = isHomeTeam ? momentum.homeMomentum : momentum.awayMomentum;
    
    TeamTactics suggestedTactics;
    String reasoning;
    double confidence = 0.8;

    if (teamMomentum > 70) {
      // High momentum - capitalize with attacking play
      suggestedTactics = TeamTactics(
        mentality: TeamMentality.attacking,
        pressing: 80,
        tempo: 85,
        width: 75,
        directness: 65,
      );
      reasoning = 'Team has high momentum - push forward aggressively to capitalize';
    } else if (teamMomentum < 30) {
      // Low momentum - consolidate and rebuild
      suggestedTactics = TeamTactics(
        mentality: TeamMentality.defensive,
        pressing: 40,
        tempo: 45,
        width: 50,
        directness: 55,
      );
      reasoning = 'Team momentum is low - play more defensively to regain control';
      confidence = 0.9;
    } else {
      // Balanced momentum
      suggestedTactics = TeamTactics(
        mentality: TeamMentality.balanced,
        pressing: 60,
        tempo: 60,
        width: 60,
        directness: 60,
      );
      reasoning = 'Momentum is balanced - maintain current approach';
      confidence = 0.6;
    }

    return MomentumTacticalAdaptation(
      suggestedTactics: suggestedTactics,
      reasoning: reasoning,
      confidence: confidence,
    );
  }

  /// Analyzes tactical effectiveness against opponent
  TacticalMatchupAnalysis analyzeTacticalMatchup(Team myTeam, Team opponentTeam, TeamTactics myTactics) {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];
    double effectiveness = 50.0;

    // Analyze formation matchup
    final myFormation = myTeam.formation;
    final opponentFormation = opponentTeam.formation;

    // Formation counter-analysis
    if (_isFormationAdvantage(myFormation, opponentFormation)) {
      effectiveness += 15;
      strengths.add('Formation advantage against opponent');
    } else if (_isFormationAdvantage(opponentFormation, myFormation)) {
      effectiveness -= 15;
      weaknesses.add('Formation disadvantage against opponent');
      recommendations.add('Consider changing formation to counter opponent');
    }

    // Team strength comparison
    final myStrength = myTeam.overallRating;
    final opponentStrength = opponentTeam.overallRating;
    
    if (myStrength > opponentStrength + 5) {
      effectiveness += 10;
      strengths.add('Superior team quality');
    } else if (opponentStrength > myStrength + 5) {
      effectiveness -= 10;
      weaknesses.add('Opponent has stronger team');
      recommendations.add('Use tactical discipline to nullify quality difference');
    }

    // Tactical analysis
    if (myTactics.mentality == TeamMentality.attacking && _isDefensiveFormation(opponentFormation)) {
      effectiveness -= 5;
      weaknesses.add('Attacking play against defensive setup may be difficult');
      recommendations.add('Consider more patient build-up play');
    }

    if (myTactics.pressing > 70 && _isCounterAttackingFormation(opponentFormation)) {
      effectiveness -= 8;
      weaknesses.add('High pressing vulnerable to counter-attacks');
      recommendations.add('Reduce pressing intensity against counter-attacking teams');
    }

    // Always provide at least some tactical strengths
    if (strengths.isEmpty) {
      strengths.add('Well-organized tactical setup');
      if (myTactics.pressing >= 60) {
        strengths.add('Good pressing intensity');
      }
      if (myTactics.tempo >= 60) {
        strengths.add('Positive tempo of play');
      }
    }

    // Always provide basic recommendations if none exist
    if (recommendations.isEmpty) {
      recommendations.add('Maintain current tactical approach');
    }

    return TacticalMatchupAnalysis(
      overallEffectiveness: effectiveness.clamp(0, 100),
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
    );
  }

  /// Analyzes formation counter-effectiveness
  FormationCounterAnalysis analyzeFormationCounter(Formation myFormation, Formation opponentFormation) {
    final advantages = <String>[];
    final disadvantages = <String>[];
    final suggestions = <String>[];
    double effectiveness = 50.0;

    // Specific formation matchups
    switch (myFormation) {
      case Formation.f433:
        if (opponentFormation == Formation.f541) {
          effectiveness += 15;
          advantages.add('Wide forwards can exploit wingback areas');
          advantages.add('Central midfielder can find space between lines');
        } else if (opponentFormation == Formation.f442) {
          effectiveness += 10;
          advantages.add('Extra midfielder provides numerical advantage');
        }
        break;

      case Formation.f541:
        if (opponentFormation == Formation.f343) {
          effectiveness += 20;
          advantages.add('Defensive solidity counters attacking formation');
          advantages.add('Wingbacks can exploit wide areas left by 3 center-backs');
        } else if (opponentFormation == Formation.f433) {
          effectiveness += 10;
          advantages.add('Extra defender helps handle three forwards');
        } else {
          disadvantages.add('May lack attacking threat');
          suggestions.add('Ensure quick transitions to attack');
        }
        break;

      case Formation.f343:
        if (opponentFormation == Formation.f541) {
          effectiveness -= 15;
          disadvantages.add('Vulnerable to defensive solidity');
          suggestions.add('Be patient in build-up play');
        } else if (opponentFormation == Formation.f442) {
          effectiveness += 12;
          advantages.add('Wingbacks can overload wide areas');
          advantages.add('Three forwards stretch defense');
        }
        break;

      default:
        break;
    }

    return FormationCounterAnalysis(
      effectiveness: effectiveness.clamp(0, 100),
      advantages: advantages,
      disadvantages: disadvantages,
      suggestions: suggestions,
    );
  }

  /// Analyzes tactical performance trends over time
  TacticalPerformanceAnalysis analyzePerformanceTrends(List<TacticalPerformanceRecord> history) {
    if (history.isEmpty) {
      return TacticalPerformanceAnalysis(
        mostEffectiveFormation: null,
        averageGoalsScored: 0.0,
        averageGoalsConceded: 0.0,
        winRate: 0.0,
        recommendations: ['No match history available'],
      );
    }

    // Calculate averages
    final totalGoalsScored = history.fold<int>(0, (sum, record) => sum + record.goalsScored);
    final totalGoalsConceded = history.fold<int>(0, (sum, record) => sum + record.goalsConceded);
    final wins = history.where((r) => r.matchResult == MatchResult.homeWin || r.matchResult == MatchResult.awayWin).length;

    final averageGoalsScored = totalGoalsScored / history.length;
    final averageGoalsConceded = totalGoalsConceded / history.length;
    final winRate = (wins / history.length) * 100;

    // Find most effective formation
    final formationResults = <Formation, List<TacticalPerformanceRecord>>{};
    for (final record in history) {
      formationResults.putIfAbsent(record.formation, () => []).add(record);
    }

    Formation? mostEffectiveFormation;
    double bestFormationScore = 0.0;

    for (final entry in formationResults.entries) {
      final formation = entry.key;
      final records = entry.value;
      
      final formationWins = records.where((r) => 
          r.matchResult == MatchResult.homeWin || r.matchResult == MatchResult.awayWin).length;
      final formationWinRate = records.isNotEmpty ? (formationWins / records.length) * 100 : 0.0;
      
      final avgGoalsScored = records.fold<double>(0, (sum, r) => sum + r.goalsScored) / records.length;
      final score = formationWinRate + (avgGoalsScored * 10); // Weighted score
      
      if (score > bestFormationScore) {
        bestFormationScore = score;
        mostEffectiveFormation = formation;
      }
    }

    // Generate recommendations
    final recommendations = <String>[];
    
    if (winRate < 40) {
      recommendations.add('Consider tactical changes - current approach needs improvement');
    }
    
    if (averageGoalsScored < 1.0) {
      recommendations.add('Focus on attacking improvements - goal scoring is below average');
    }
    
    if (averageGoalsConceded > 2.0) {
      recommendations.add('Defensive stability needs attention - too many goals conceded');
    }

    if (mostEffectiveFormation != null) {
      recommendations.add('${mostEffectiveFormation!.name} has been your most effective formation');
    }

    return TacticalPerformanceAnalysis(
      mostEffectiveFormation: mostEffectiveFormation,
      averageGoalsScored: averageGoalsScored,
      averageGoalsConceded: averageGoalsConceded,
      winRate: winRate,
      recommendations: recommendations,
    );
  }

  // Private helper methods

  /// Gets formation requirements by position
  Map<PlayerPosition, int> _getFormationRequirements(Formation formation) {
    switch (formation) {
      case Formation.f442:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 4,
          PlayerPosition.midfielder: 4,
          PlayerPosition.forward: 2,
        };
      case Formation.f433:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 4,
          PlayerPosition.midfielder: 3,
          PlayerPosition.forward: 3,
        };
      case Formation.f451:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 4,
          PlayerPosition.midfielder: 5,
          PlayerPosition.forward: 1,
        };
      case Formation.f343:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 3,
          PlayerPosition.midfielder: 4,
          PlayerPosition.forward: 3,
        };
      case Formation.f352:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 3,
          PlayerPosition.midfielder: 5,
          PlayerPosition.forward: 2,
        };
      case Formation.f541:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 5,
          PlayerPosition.midfielder: 4,
          PlayerPosition.forward: 1,
        };
      case Formation.f532:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 5,
          PlayerPosition.midfielder: 3,
          PlayerPosition.forward: 2,
        };
      case Formation.f4231:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 4,
          PlayerPosition.midfielder: 4,
          PlayerPosition.forward: 2,
        };
      case Formation.f4141:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 4,
          PlayerPosition.midfielder: 5,
          PlayerPosition.forward: 1,
        };
      case Formation.f3421:
        return {
          PlayerPosition.goalkeeper: 1,
          PlayerPosition.defender: 3,
          PlayerPosition.midfielder: 6,
          PlayerPosition.forward: 1,
        };
    }
  }

  /// Gets count of available players by position
  Map<PlayerPosition, int> _getAvailablePositions(Team team) {
    final positions = <PlayerPosition, int>{};
    
    for (final player in team.players) {
      positions[player.position] = (positions[player.position] ?? 0) + 1;
    }
    
    return positions;
  }

  /// Calculates formation suitability based on team composition
  double _calculateFormationSuitability(Team team, Formation formation) {
    if (team.players.length < 11) return 0.0;
    
    final requirements = _getFormationRequirements(formation);
    final available = _getAvailablePositions(team);
    
    double suitability = 50.0; // Base score
    
    // Check if we have enough players for each position
    for (final entry in requirements.entries) {
      final position = entry.key;
      final required = entry.value;
      final playerCount = available[position] ?? 0;
      
      if (playerCount < required) {
        return 0.0; // Cannot play this formation
      }
      
      // Bonus for having quality depth
      if (playerCount > required) {
        suitability += (playerCount - required) * 5;
      }
    }
    
    // Formation-specific bonuses based on team characteristics
    final forwards = available[PlayerPosition.forward] ?? 0;
    final midfielders = available[PlayerPosition.midfielder] ?? 0;
    final defenders = available[PlayerPosition.defender] ?? 0;
    
    switch (formation) {
      case Formation.f343:
      case Formation.f352:
        if (forwards >= 3) suitability += 15;
        break;
      case Formation.f541:
      case Formation.f532:
        if (defenders >= 6) suitability += 15;
        break;
      case Formation.f451:
        if (midfielders >= 6) suitability += 10;
        break;
      default:
        break;
    }
    
    return suitability.clamp(0, 100);
  }

  /// Gets reasons for formation suitability score
  List<String> _getFormationReasons(Team team, Formation formation, double suitability) {
    final reasons = <String>[];
    
    if (suitability == 0) {
      reasons.add('Insufficient players for this formation');
      return reasons;
    }
    
    final available = _getAvailablePositions(team);
    final forwards = available[PlayerPosition.forward] ?? 0;
    final midfielders = available[PlayerPosition.midfielder] ?? 0;
    final defenders = available[PlayerPosition.defender] ?? 0;
    
    if (suitability >= 80) {
      reasons.add('Excellent fit for your squad');
    } else if (suitability >= 60) {
      reasons.add('Good option for your team');
    } else {
      reasons.add('Workable but not ideal');
    }
    
    switch (formation) {
      case Formation.f343:
        if (forwards >= 4) reasons.add('Plenty of attacking options available');
        if (defenders < 4) reasons.add('Limited defensive depth');
        break;
      case Formation.f541:
        if (defenders >= 6) reasons.add('Strong defensive foundation');
        if (forwards < 2) reasons.add('Limited attacking options');
        break;
      case Formation.f433:
        if (midfielders >= 4) reasons.add('Good midfield balance');
        if (forwards >= 4) reasons.add('Multiple attacking options');
        break;
      default:
        break;
    }
    
    return reasons;
  }

  /// Checks if formation has advantage over opponent formation
  bool _isFormationAdvantage(Formation myFormation, Formation opponentFormation) {
    // Simplified formation counter-system
    const advantageMap = {
      Formation.f433: [Formation.f442, Formation.f532],
      Formation.f541: [Formation.f343, Formation.f352],
      Formation.f343: [Formation.f442, Formation.f451],
      Formation.f442: [Formation.f451, Formation.f532],
    };
    
    return advantageMap[myFormation]?.contains(opponentFormation) ?? false;
  }

  /// Checks if formation is primarily defensive
  bool _isDefensiveFormation(Formation formation) {
    return formation == Formation.f541 || formation == Formation.f532;
  }

  /// Checks if formation is suited for counter-attacking
  bool _isCounterAttackingFormation(Formation formation) {
    return formation == Formation.f451 || formation == Formation.f541;
  }
}
