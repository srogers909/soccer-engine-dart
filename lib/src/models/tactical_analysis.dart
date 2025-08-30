import 'enhanced_match.dart';
import 'match.dart';
import 'team.dart';
import 'package:soccer_utilities/src/models/player.dart';

/// Validation result for formations and tactics
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}

/// Formation recommendation with suitability analysis
class FormationRecommendation {
  final Formation formation;
  final double suitabilityScore;
  final List<String> reasons;

  FormationRecommendation({
    required this.formation,
    required this.suitabilityScore,
    required this.reasons,
  });
}

/// Tactical compatibility analysis result
class TacticalCompatibility {
  final double score;
  final List<String> warnings;

  TacticalCompatibility({
    required this.score,
    required this.warnings,
  });
}

/// Tactical adjustment suggestion
class TacticalAdjustment {
  final String parameter;
  final num currentValue;
  final num suggestedValue;
  final String reason;

  TacticalAdjustment({
    required this.parameter,
    required this.currentValue,
    required this.suggestedValue,
    required this.reason,
  });
}

/// Match scenarios for tactical planning
enum MatchScenario {
  losing,
  winning,
  drawing,
  behindByTwo,
  playerSentOff,
}

/// Planned tactical changes for specific scenarios
class PlannedTacticalChange {
  final int targetMinute;
  final TeamTactics newTactics;
  final String reason;

  PlannedTacticalChange({
    required this.targetMinute,
    required this.newTactics,
    required this.reason,
  });
}

/// Substitution recommendation
class SubstitutionRecommendation {
  final Player playerOut;
  final Player playerIn;
  final String reason;
  final int priority; // 1 = high, 2 = medium, 3 = low

  SubstitutionRecommendation({
    required this.playerOut,
    required this.playerIn,
    required this.reason,
    required this.priority,
  });
}

/// Momentum-based tactical adaptation
class MomentumTacticalAdaptation {
  final TeamTactics suggestedTactics;
  final String reasoning;
  final double confidence;

  MomentumTacticalAdaptation({
    required this.suggestedTactics,
    required this.reasoning,
    required this.confidence,
  });
}

/// Tactical matchup analysis result
class TacticalMatchupAnalysis {
  final double overallEffectiveness;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;

  TacticalMatchupAnalysis({
    required this.overallEffectiveness,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
  });
}

/// Formation counter-analysis result
class FormationCounterAnalysis {
  final double effectiveness;
  final List<String> advantages;
  final List<String> disadvantages;
  final List<String> suggestions;

  FormationCounterAnalysis({
    required this.effectiveness,
    required this.advantages,
    required this.disadvantages,
    required this.suggestions,
  });
}

/// Historical tactical performance record
class TacticalPerformanceRecord {
  final Formation formation;
  final TeamTactics tactics;
  final MatchResult matchResult;
  final int goalsScored;
  final int goalsConceded;
  final double possession;
  final double passAccuracy;

  TacticalPerformanceRecord({
    required this.formation,
    required this.tactics,
    required this.matchResult,
    required this.goalsScored,
    required this.goalsConceded,
    required this.possession,
    required this.passAccuracy,
  });
}

/// Tactical performance trend analysis
class TacticalPerformanceAnalysis {
  final Formation? mostEffectiveFormation;
  final double averageGoalsScored;
  final double averageGoalsConceded;
  final double winRate;
  final List<String> recommendations;

  TacticalPerformanceAnalysis({
    required this.mostEffectiveFormation,
    required this.averageGoalsScored,
    required this.averageGoalsConceded,
    required this.winRate,
    required this.recommendations,
  });
}
