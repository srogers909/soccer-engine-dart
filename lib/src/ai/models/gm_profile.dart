import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'gm_profile.g.dart';

/// GM personality types that influence decision-making
enum GMPersonality {
  @JsonValue('conservative')
  conservative,
  @JsonValue('aggressive')
  aggressive,
  @JsonValue('balanced')
  balanced,
  @JsonValue('youthFocused')
  youthFocused,
  @JsonValue('tactical')
  tactical,
}

/// Budget allocation structure for GM decision-making
@JsonSerializable()
class BudgetAllocation extends Equatable {
  /// Transfer budget allocation
  final int transferBudget;
  
  /// Wage budget allocation
  final int wageBudget;
  
  /// Youth development budget allocation
  final int youthBudget;
  
  /// Facilities budget allocation
  final int facilitiesBudget;

  const BudgetAllocation({
    required this.transferBudget,
    required this.wageBudget,
    required this.youthBudget,
    required this.facilitiesBudget,
  });

  @override
  List<Object> get props => [
    transferBudget,
    wageBudget,
    youthBudget,
    facilitiesBudget,
  ];

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$BudgetAllocationToJson(this);

  /// Create from JSON
  factory BudgetAllocation.fromJson(Map<String, dynamic> json) =>
      _$BudgetAllocationFromJson(json);
}

/// Represents a GM's personality profile and decision-making preferences
@JsonSerializable()
class GMProfile extends Equatable {
  /// Unique GM identifier
  final String id;
  
  /// GM's display name
  final String name;
  
  /// GM's personality type
  final GMPersonality personality;
  
  /// Risk tolerance (0.0 = very conservative, 1.0 = very risky)
  final double riskTolerance;
  
  /// Youth focus weight (0.0 = no youth focus, 1.0 = heavy youth focus)
  final double youthFocus;
  
  /// Tactical focus weight (0.0 = basic tactics, 1.0 = tactical genius)
  final double tacticalFocus;
  
  /// Ratio of total budget allocated to transfers
  final double transferBudgetRatio;
  
  /// Ratio of total budget allocated to wages
  final double wageBudgetRatio;

  /// Factory constructor with validation
  factory GMProfile({
    required String id,
    required String name,
    required GMPersonality personality,
    double riskTolerance = 0.5,
    double youthFocus = 0.5,
    double tacticalFocus = 0.5,
    double transferBudgetRatio = 0.5,
    double wageBudgetRatio = 0.4,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('GM ID cannot be empty');
    }
    if (name.isEmpty) {
      throw ArgumentError('GM name cannot be empty');
    }
    if (riskTolerance < 0.0 || riskTolerance > 1.0) {
      throw ArgumentError('Risk tolerance must be between 0.0 and 1.0');
    }
    if (youthFocus < 0.0 || youthFocus > 1.0) {
      throw ArgumentError('Youth focus must be between 0.0 and 1.0');
    }
    if (tacticalFocus < 0.0 || tacticalFocus > 1.0) {
      throw ArgumentError('Tactical focus must be between 0.0 and 1.0');
    }
    if (transferBudgetRatio < 0.0 || transferBudgetRatio > 1.0) {
      throw ArgumentError('Transfer budget ratio must be between 0.0 and 1.0');
    }
    if (wageBudgetRatio < 0.0 || wageBudgetRatio > 1.0) {
      throw ArgumentError('Wage budget ratio must be between 0.0 and 1.0');
    }

    return GMProfile._internal(
      id: id,
      name: name,
      personality: personality,
      riskTolerance: riskTolerance,
      youthFocus: youthFocus,
      tacticalFocus: tacticalFocus,
      transferBudgetRatio: transferBudgetRatio,
      wageBudgetRatio: wageBudgetRatio,
    );
  }

  /// Private constructor for validation
  const GMProfile._internal({
    required this.id,
    required this.name,
    required this.personality,
    this.riskTolerance = 0.5,
    this.youthFocus = 0.5,
    this.tacticalFocus = 0.5,
    this.transferBudgetRatio = 0.5,
    this.wageBudgetRatio = 0.4,
  });

  /// Conservative GM preset
  factory GMProfile.conservative({
    required String id,
    required String name,
  }) {
    return GMProfile(
      id: id,
      name: name,
      personality: GMPersonality.conservative,
      riskTolerance: 0.2,
      youthFocus: 0.7,
      tacticalFocus: 0.3,
      transferBudgetRatio: 0.4,
      wageBudgetRatio: 0.5,
    );
  }

  /// Aggressive GM preset
  factory GMProfile.aggressive({
    required String id,
    required String name,
  }) {
    return GMProfile(
      id: id,
      name: name,
      personality: GMPersonality.aggressive,
      riskTolerance: 0.8,
      youthFocus: 0.2,
      tacticalFocus: 0.4,
      transferBudgetRatio: 0.8,
      wageBudgetRatio: 0.15,
    );
  }

  /// Youth-focused GM preset
  factory GMProfile.youthFocused({
    required String id,
    required String name,
  }) {
    return GMProfile(
      id: id,
      name: name,
      personality: GMPersonality.youthFocused,
      riskTolerance: 0.4,
      youthFocus: 0.9,
      tacticalFocus: 0.6,
      transferBudgetRatio: 0.3,
      wageBudgetRatio: 0.4,
    );
  }

  /// Tactical GM preset
  factory GMProfile.tactical({
    required String id,
    required String name,
  }) {
    return GMProfile(
      id: id,
      name: name,
      personality: GMPersonality.tactical,
      riskTolerance: 0.5,
      youthFocus: 0.4,
      tacticalFocus: 0.9,
      transferBudgetRatio: 0.5,
      wageBudgetRatio: 0.35,
    );
  }

  @override
  List<Object> get props => [id]; // Only ID for equality

  /// Calculates preference weight for a player based on GM personality
  double getPlayerPreferenceWeight({
    required int age,
    required int rating,
    required bool isYouthPlayer,
  }) {
    double weight = 0.5; // Base weight
    
    // Age factor based on youth focus
    if (age <= 21) {
      weight += youthFocus * 0.3;
    } else if (age >= 30) {
      weight -= youthFocus * 0.2;
    }
    
    // Youth player bonus
    if (isYouthPlayer) {
      weight += youthFocus * 0.4;
    }
    
    // Rating factor
    weight += (rating - 70) * 0.01; // Normalize around 70 rating
    
    // Personality adjustments
    switch (personality) {
      case GMPersonality.conservative:
        if (age >= 25 && age <= 29) weight += 0.1; // Prime age preference
        break;
      case GMPersonality.aggressive:
        if (rating >= 80) weight += 0.2; // Star player preference
        break;
      case GMPersonality.youthFocused:
        if (age <= 23) weight += 0.3; // Young player boost
        break;
      case GMPersonality.tactical:
        weight += tacticalFocus * 0.1; // Slight tactical preference
        break;
      case GMPersonality.balanced:
        // No specific adjustments for balanced
        break;
    }
    
    return (weight).clamp(0.0, 1.0);
  }

  /// Calculates transfer urgency weight based on squad needs and time pressure
  double getTransferUrgencyWeight({
    required double squadNeed,
    required double timeRemaining,
  }) {
    double baseUrgency = squadNeed * 0.6 + (1.0 - timeRemaining) * 0.4;
    
    // Risk tolerance affects urgency response
    double urgencyModifier = riskTolerance;
    
    // Personality adjustments
    switch (personality) {
      case GMPersonality.conservative:
        urgencyModifier *= 0.8; // Less reactive to urgency
        break;
      case GMPersonality.aggressive:
        urgencyModifier *= 1.3; // More reactive to urgency
        break;
      case GMPersonality.youthFocused:
        urgencyModifier *= 0.9; // Slightly less urgent (patient for youth)
        break;
      case GMPersonality.tactical:
        urgencyModifier *= 1.1; // Slightly more urgent (needs right players)
        break;
      case GMPersonality.balanced:
        // No adjustment
        break;
    }
    
    return (baseUrgency * urgencyModifier).clamp(0.0, 1.0);
  }

  /// Calculates formation preference weight based on tactical focus
  double getFormationPreferenceWeight({
    required String formation,
    required int availablePlayers,
  }) {
    double baseWeight = 0.5;
    
    // Tactical focus influences formation preference strength
    double tacticalInfluence = tacticalFocus * 0.3;
    
    // Formation complexity preferences based on personality
    Map<String, double> formationComplexity = {
      '4-4-2': 0.2,
      '4-3-3': 0.5,
      '3-5-2': 0.7,
      '4-2-3-1': 0.6,
      '3-4-3': 0.8,
      '5-3-2': 0.4,
    };
    
    double complexity = formationComplexity[formation] ?? 0.5;
    
    // Adjust based on tactical focus and complexity preference
    if (tacticalFocus > 0.7) {
      baseWeight += complexity * 0.3; // High tactical focus likes complexity
    } else if (tacticalFocus < 0.3) {
      baseWeight += (1.0 - complexity) * 0.3; // Low tactical focus prefers simple
    }
    
    // Availability constraint (need enough players)
    int requiredPlayers = _getRequiredPlayersForFormation(formation);
    if (availablePlayers < requiredPlayers) {
      baseWeight *= 0.3; // Heavy penalty for insufficient players
    }
    
    return (baseWeight + tacticalInfluence).clamp(0.0, 1.0);
  }

  /// Helper method to get required players for formation
  int _getRequiredPlayersForFormation(String formation) {
    // Simplified - in real implementation, this would be more sophisticated
    return 11; // All formations need at least 11 players
  }

  /// Calculates budget allocation based on personality and preferences
  BudgetAllocation getBudgetAllocation(int totalBudget) {
    int transferBudget = (totalBudget * transferBudgetRatio).round();
    int wageBudget = (totalBudget * wageBudgetRatio).round();
    
    // Calculate remaining budget for youth and facilities
    int remainingBudget = totalBudget - transferBudget - wageBudget;
    
    // Allocate remaining budget based on personality
    double youthRatio;
    double facilitiesRatio;
    
    switch (personality) {
      case GMPersonality.conservative:
        // Conservative: 75% youth, 25% facilities
        youthRatio = 0.75;
        facilitiesRatio = 0.25;
        break;
      case GMPersonality.aggressive:
        // Aggressive: equal split for remaining small budget
        youthRatio = 0.5;
        facilitiesRatio = 0.5;
        break;
      case GMPersonality.youthFocused:
        // Youth focused: 80% youth, 20% facilities
        youthRatio = 0.8;
        facilitiesRatio = 0.2;
        break;
      default:
        // Balanced/tactical: 60% youth, 40% facilities
        youthRatio = 0.6;
        facilitiesRatio = 0.4;
        break;
    }
    
    int youthBudget = (remainingBudget * youthRatio).round();
    int facilitiesBudget = (remainingBudget * facilitiesRatio).round();
    
    return BudgetAllocation(
      transferBudget: transferBudget,
      wageBudget: wageBudget,
      youthBudget: youthBudget,
      facilitiesBudget: facilitiesBudget,
    );
  }

  /// Creates a copy with updated values
  GMProfile copyWith({
    String? id,
    String? name,
    GMPersonality? personality,
    double? riskTolerance,
    double? youthFocus,
    double? tacticalFocus,
    double? transferBudgetRatio,
    double? wageBudgetRatio,
  }) {
    return GMProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      personality: personality ?? this.personality,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      youthFocus: youthFocus ?? this.youthFocus,
      tacticalFocus: tacticalFocus ?? this.tacticalFocus,
      transferBudgetRatio: transferBudgetRatio ?? this.transferBudgetRatio,
      wageBudgetRatio: wageBudgetRatio ?? this.wageBudgetRatio,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$GMProfileToJson(this);

  /// Create from JSON
  factory GMProfile.fromJson(Map<String, dynamic> json) =>
      _$GMProfileFromJson(json);
}
