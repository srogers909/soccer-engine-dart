import 'dart:math';
import 'package:tactics_fc_utilities/src/models/player.dart';

/// Market conditions affecting player valuations
class MarketConditions {
  /// Overall market inflation factor (1.0 = normal, >1.0 = inflated)
  final double inflation;
  
  /// Position-specific demand multipliers
  final Map<PlayerPosition, double> positionDemand;
  
  /// League-specific multipliers
  final double leagueMultiplier;
  
  /// Transfer window urgency factor
  final double urgencyFactor;

  const MarketConditions({
    this.inflation = 1.0,
    this.positionDemand = const {},
    this.leagueMultiplier = 1.0,
    this.urgencyFactor = 1.0,
  });
}

/// Utility class for calculating player market valuations and contract suggestions
class PlayerValuation {
  /// Base value per attribute point (in currency units)
  static const int _baseValuePerPoint = 200000;
  
  /// Minimum player value
  static const int _minimumValue = 50000;
  
  /// Maximum player value
  static const int _maximumValue = 200000000;

  /// Calculates base market value for a player
  int calculateBaseValue(Player player) {
    // Calculate position-weighted overall rating
    final positionRating = player.positionOverallRating;
    
    // Progressive value calculation based on rating tiers
    int baseValue;
    if (positionRating <= 40) {
      // Low tier players: 50K per point
      baseValue = positionRating * 50000;
    } else if (positionRating <= 60) {
      // Average tier players: 100K per point above 40, plus base
      baseValue = (40 * 50000) + ((positionRating - 40) * 100000);
    } else if (positionRating <= 80) {
      // Good tier players: 300K per point above 60, plus previous tiers
      baseValue = (40 * 50000) + (20 * 100000) + ((positionRating - 60) * 300000);
    } else if (positionRating <= 95) {
      // Very good tier players: 700K per point above 80, plus previous tiers
      baseValue = (40 * 50000) + (20 * 100000) + (20 * 300000) + ((positionRating - 80) * 700000);
    } else {
      // Elite tier players: 4.5M per point above 95, plus previous tiers
      baseValue = (40 * 50000) + (20 * 100000) + (20 * 300000) + (15 * 700000) + ((positionRating - 95) * 4500000);
    }
    
    // Apply position factor
    final positionFactor = calculatePositionFactor(player.position);
    baseValue = (baseValue * positionFactor).round();
    
    // Apply age factor
    final ageFactor = calculateAgeFactor(player.age);
    baseValue = (baseValue * ageFactor).round();
    
    // Ensure value is within reasonable bounds
    return baseValue.clamp(_minimumValue, _maximumValue);
  }

  /// Calculates market value with all factors including market conditions
  int calculateMarketValue(Player player, {MarketConditions? marketConditions}) {
    // Start with base value
    int value = calculateBaseValue(player);
    
    // Apply form factor
    final formFactor = calculateFormFactor(player);
    value = (value * formFactor).round();
    
    // Apply fitness factor
    final fitnessFactor = calculateFitnessFactor(player);
    value = (value * fitnessFactor).round();
    
    // Apply market conditions if provided
    if (marketConditions != null) {
      // Apply general inflation
      value = (value * marketConditions.inflation).round();
      
      // Apply position-specific demand
      final positionDemandFactor = marketConditions.positionDemand[player.position] ?? 1.0;
      value = (value * positionDemandFactor).round();
      
      // Apply league multiplier
      value = (value * marketConditions.leagueMultiplier).round();
      
      // Apply urgency factor
      value = (value * marketConditions.urgencyFactor).round();
    }
    
    // Ensure value is within bounds
    return value.clamp(_minimumValue, _maximumValue);
  }

  /// Calculates age factor for valuation (0.2 to 1.3)
  double calculateAgeFactor(int age) {
    if (age <= 18) {
      // Very young players have potential premium
      return 0.8 + (18 - age) * 0.05; // 0.8 to 1.15
    } else if (age <= 23) {
      // Young players with high potential
      return 0.9 + (23 - age) * 0.04; // 0.9 to 1.1
    } else if (age <= 28) {
      // Prime years - peak value
      return 1.0 + (28 - age) * 0.02; // 1.0 to 1.1
    } else if (age <= 32) {
      // Declining but experienced
      return 1.0 - (age - 28) * 0.1; // 1.0 to 0.6
    } else {
      // Veteran players - significant depreciation
      return max(0.2, 0.6 - (age - 32) * 0.05); // 0.2 to 0.6
    }
  }

  /// Calculates position factor for valuation
  double calculatePositionFactor(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 0.9; // Slightly lower due to specialized role
      case PlayerPosition.defender:
        return 0.95; // Standard valuation
      case PlayerPosition.midfielder:
        return 1.05; // Slight premium for versatility
      case PlayerPosition.forward:
        return 1.1; // Premium for goal-scoring ability
    }
  }

  /// Calculates form factor for valuation (0.85 to 1.2)
  double calculateFormFactor(Player player) {
    // Form scale: 1-10, where 7 is average
    final formDifference = player.form - 7;
    return (1.0 + (formDifference * 0.05)).clamp(0.85, 1.2); // ±5% per form point, clamped
  }

  /// Calculates fitness factor for valuation (0.8 to 1.0)
  double calculateFitnessFactor(Player player) {
    // Fitness affects value but not as much as other factors
    return 0.8 + (player.fitness / 100.0) * 0.2;
  }

  /// Suggests release clause amount (typically 1.5-2.5x market value)
  int suggestReleaseClause(Player player, {MarketConditions? marketConditions}) {
    final marketValue = calculateMarketValue(player, marketConditions: marketConditions);
    
    // Release clause multiplier based on player quality and age
    double multiplier = 2.0; // Base multiplier
    
    // Higher multiplier for young, high-potential players
    if (player.age <= 23 && player.positionOverallRating >= 80) {
      multiplier = 2.5;
    }
    
    // Lower multiplier for older players
    if (player.age >= 30) {
      multiplier = 1.5;
    }
    
    return (marketValue * multiplier).round();
  }

  /// Suggests weekly wage based on player value and market conditions
  int suggestWeeklyWage(Player player, {MarketConditions? marketConditions}) {
    final marketValue = calculateMarketValue(player, marketConditions: marketConditions);
    
    // Weekly wage is typically 0.1% to 0.5% of market value
    double wagePercentage = 0.002; // 0.2% base
    
    // Adjust based on player quality
    if (player.positionOverallRating >= 90) {
      wagePercentage = 0.005; // 0.5% for world-class players
    } else if (player.positionOverallRating >= 80) {
      wagePercentage = 0.003; // 0.3% for top players
    } else if (player.positionOverallRating >= 70) {
      wagePercentage = 0.0025; // 0.25% for good players
    }
    
    final suggestedWage = (marketValue * wagePercentage).round();
    
    // Ensure minimum and maximum bounds
    return suggestedWage.clamp(1000, 400000);
  }

  /// Suggests signing bonus based on player value and transfer circumstances
  int suggestSigningBonus(Player player, {
    MarketConditions? marketConditions,
    bool isFreeTransfer = false,
    bool isHighDemand = false,
  }) {
    final marketValue = calculateMarketValue(player, marketConditions: marketConditions);
    
    double bonusPercentage = 0.0; // Base percentage
    
    // Free transfers typically get higher signing bonuses
    if (isFreeTransfer) {
      bonusPercentage = 0.15; // 15% of market value
    } else {
      bonusPercentage = 0.05; // 5% for regular transfers
    }
    
    // High demand situations increase signing bonus
    if (isHighDemand) {
      bonusPercentage += 0.05;
    }
    
    // Age factor - younger players may get higher bonuses
    if (player.age <= 23) {
      bonusPercentage += 0.02;
    }
    
    final suggestedBonus = (marketValue * bonusPercentage).round();
    
    // Cap at 20% of market value
    return min(suggestedBonus, (marketValue * 0.2).round());
  }

  /// Suggests loyalty bonus based on contract length and player value
  int suggestLoyaltyBonus(Player player, int contractYears, {MarketConditions? marketConditions}) {
    final marketValue = calculateMarketValue(player, marketConditions: marketConditions);
    
    // Loyalty bonus as percentage of market value based on contract length
    double bonusPercentage = contractYears * 0.02; // 2% per year
    
    // Cap at 10%
    bonusPercentage = min(bonusPercentage, 0.1);
    
    return (marketValue * bonusPercentage).round();
  }

  /// Calculates depreciation factor for older players
  double calculateDepreciationFactor(Player player) {
    if (player.age <= 28) return 1.0;
    
    // 5% depreciation per year after 28
    final yearsAfterPeak = player.age - 28;
    return max(0.3, 1.0 - (yearsAfterPeak * 0.05));
  }

  /// Estimates potential future value for young players
  int estimatePotentialValue(Player player, {int yearsInFuture = 3}) {
    if (player.age >= 25) {
      // For older players, just apply depreciation
      final futureAge = player.age + yearsInFuture;
      final futureAgeFactor = calculateAgeFactor(futureAge);
      final currentAgeFactor = calculateAgeFactor(player.age);
      
      final currentValue = calculateMarketValue(player);
      return (currentValue * (futureAgeFactor / currentAgeFactor)).round();
    }
    
    // For young players, estimate development
    final currentValue = calculateMarketValue(player);
    final developmentFactor = 1.0 + (yearsInFuture * 0.1); // 10% improvement per year
    final futureAge = player.age + yearsInFuture;
    final futureAgeFactor = calculateAgeFactor(futureAge);
    final currentAgeFactor = calculateAgeFactor(player.age);
    
    final potentialValue = currentValue * developmentFactor * (futureAgeFactor / currentAgeFactor);
    return potentialValue.round().clamp(_minimumValue, _maximumValue);
  }
}
