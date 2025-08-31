import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';
import '../../models/team.dart';
import '../../models/transfer.dart';
import '../../models/financial_account.dart';
import '../engines/decision_engine.dart';
import '../models/gm_profile.dart';

part 'transfer_ai.g.dart';

/// Types of transfer needs
enum TransferNeed {
  goalkeeper,
  defender,
  midfielder,
  forward,
  backup,
  youth,
  star,
  depth,
}

/// Transfer target information
@JsonSerializable(explicitToJson: true)
class TransferTarget extends Equatable {
  /// Target player
  final Player player;
  
  /// Priority level (1-10, 10 being highest)
  final int priority;
  
  /// Estimated transfer fee
  final int estimatedFee;
  
  /// Maximum acceptable fee
  final int maxFee;
  
  /// Type of need this target addresses
  final TransferNeed need;
  
  /// Confidence in successful acquisition (0.0-1.0)
  final double confidence;
  
  /// Additional scouting notes
  final Map<String, dynamic> scoutingNotes;

  const TransferTarget({
    required this.player,
    required this.priority,
    required this.estimatedFee,
    required this.maxFee,
    required this.need,
    required this.confidence,
    this.scoutingNotes = const {},
  });

  /// Creates a TransferTarget from JSON
  factory TransferTarget.fromJson(Map<String, dynamic> json) => 
      _$TransferTargetFromJson(json);

  /// Converts this TransferTarget to JSON
  Map<String, dynamic> toJson() => _$TransferTargetToJson(this);

  @override
  List<Object?> get props => [
    player.id,
    priority,
    estimatedFee,
    maxFee,
    need,
    confidence,
    scoutingNotes,
  ];
}

/// Transfer market analysis result
@JsonSerializable(explicitToJson: true)
class TransferMarketAnalysis extends Equatable {
  /// Identified squad needs
  final List<TransferNeed> squadNeeds;
  
  /// List of transfer targets
  final List<TransferTarget> targets;
  
  /// Available budget for transfers
  final int availableBudget;
  
  /// Recommended transfer strategy
  final String strategy;
  
  /// Analysis confidence score
  final double confidence;
  
  /// Analysis timestamp
  final DateTime timestamp;

  const TransferMarketAnalysis({
    required this.squadNeeds,
    required this.targets,
    required this.availableBudget,
    required this.strategy,
    required this.confidence,
    required this.timestamp,
  });

  /// Creates a TransferMarketAnalysis from JSON
  factory TransferMarketAnalysis.fromJson(Map<String, dynamic> json) => 
      _$TransferMarketAnalysisFromJson(json);

  /// Converts this TransferMarketAnalysis to JSON
  Map<String, dynamic> toJson() => _$TransferMarketAnalysisToJson(this);

  @override
  List<Object?> get props => [
    squadNeeds,
    targets,
    availableBudget,
    strategy,
    confidence,
    timestamp,
  ];
}

/// AI system for managing transfer decisions
@JsonSerializable(explicitToJson: true)
class TransferAI extends Equatable {
  /// Decision engine for transfer decisions
  final DecisionEngine decisionEngine;
  
  /// Current transfer targets
  final List<TransferTarget> targets;
  
  /// Transfer budget allocation
  final int transferBudget;
  
  /// Minimum squad rating threshold
  final int minRatingThreshold;
  
  /// Whether the AI is actively seeking transfers
  final bool isActive;

  const TransferAI({
    required this.decisionEngine,
    this.targets = const [],
    this.transferBudget = 0,
    this.minRatingThreshold = 70,
    this.isActive = true,
  });

  /// Creates a TransferAI from JSON
  factory TransferAI.fromJson(Map<String, dynamic> json) => 
      _$TransferAIFromJson(json);

  /// Converts this TransferAI to JSON
  Map<String, dynamic> toJson() => _$TransferAIToJson(this);

  /// Analyzes team squad and identifies transfer needs
  TransferMarketAnalysis analyzeTransferNeeds({
    required Team team,
    required FinancialAccount financialAccount,
    required List<Player> availablePlayers,
  }) {
    final squadNeeds = _identifySquadNeeds(team);
    final availableBudget = financialAccount.getAvailableBudget(BudgetCategory.transfers);
    final targets = _findTransferTargets(squadNeeds, availablePlayers, availableBudget);
    final strategy = _generateTransferStrategy(team, squadNeeds, availableBudget);
    
    return TransferMarketAnalysis(
      squadNeeds: squadNeeds,
      targets: targets,
      availableBudget: availableBudget,
      strategy: strategy,
      confidence: _calculateAnalysisConfidence(squadNeeds, targets),
      timestamp: DateTime.now(),
    );
  }

  /// Makes a transfer decision for a specific target
  Decision makeTransferDecision({
    required TransferTarget target,
    required Team team,
    required FinancialAccount financialAccount,
  }) {
    final context = _buildTransferContext(target, team, financialAccount);
    
    return decisionEngine.makeDecision(
      type: DecisionType.transfer,
      options: ['accept', 'negotiate', 'reject'],
      context: context,
    );
  }

  /// Evaluates whether to sell a player
  Decision makeSellDecision({
    required Player player,
    required Team team,
    required int offerAmount,
  }) {
    final context = _buildSellContext(player, team, offerAmount);
    
    return decisionEngine.makeDecision(
      type: DecisionType.transfer,
      options: ['accept_offer', 'counter_offer', 'reject_offer'],
      context: context,
    );
  }

  /// Identifies what positions need strengthening
  List<TransferNeed> _identifySquadNeeds(Team team) {
    final needs = <TransferNeed>[];
    final positionStrengths = team.positionStrengths;
    final squadAnalysis = team.squadAnalysis;
    
    // Check position-specific needs
    final positionCounts = squadAnalysis['positionCounts'] as Map<PlayerPosition, int>;
    final positionAverages = squadAnalysis['positionAverages'] as Map<PlayerPosition, double>;
    
    // Goalkeeper needs
    final gkCount = positionCounts[PlayerPosition.goalkeeper] ?? 0;
    final gkAverage = positionAverages[PlayerPosition.goalkeeper] ?? 0;
    if (gkCount < 2 || gkAverage < minRatingThreshold) {
      needs.add(TransferNeed.goalkeeper);
    }
    
    // Defender needs
    final defCount = positionCounts[PlayerPosition.defender] ?? 0;
    final defAverage = positionAverages[PlayerPosition.defender] ?? 0;
    if (defCount < 6 || defAverage < minRatingThreshold) {
      needs.add(TransferNeed.defender);
    }
    
    // Midfielder needs
    final midCount = positionCounts[PlayerPosition.midfielder] ?? 0;
    final midAverage = positionAverages[PlayerPosition.midfielder] ?? 0;
    if (midCount < 6 || midAverage < minRatingThreshold) {
      needs.add(TransferNeed.midfielder);
    }
    
    // Forward needs
    final fwdCount = positionCounts[PlayerPosition.forward] ?? 0;
    final fwdAverage = positionAverages[PlayerPosition.forward] ?? 0;
    if (fwdCount < 4 || fwdAverage < minRatingThreshold) {
      needs.add(TransferNeed.forward);
    }
    
    // Youth development needs (based on GM personality)
    if (decisionEngine.gmProfile.youthFocus > 0.6) {
      final youngPlayers = team.players.where((p) => p.age <= 23).length;
      if (youngPlayers < 8) {
        needs.add(TransferNeed.youth);
      }
    }
    
    // Star player needs (based on GM personality)
    if (decisionEngine.gmProfile.personality == GMPersonality.aggressive) {
      final starPlayers = team.players.where((p) => p.overallRating >= 85).length;
      if (starPlayers < 3) {
        needs.add(TransferNeed.star);
      }
    }
    
    return needs;
  }

  /// Finds suitable transfer targets for identified needs
  List<TransferTarget> _findTransferTargets(
    List<TransferNeed> needs,
    List<Player> availablePlayers,
    int budget,
  ) {
    final targets = <TransferTarget>[];
    
    for (final need in needs) {
      final suitablePlayers = _filterPlayersByNeed(need, availablePlayers);
      
      for (final player in suitablePlayers.take(3)) { // Top 3 per need
        final estimatedFee = _estimateTransferFee(player);
        final maxFee = (estimatedFee * 1.2).round(); // 20% buffer
        
        if (maxFee <= budget) {
          final priority = _calculatePriority(need, player);
          final confidence = _calculateAcquisitionConfidence(player, estimatedFee);
          
          targets.add(TransferTarget(
            player: player,
            priority: priority,
            estimatedFee: estimatedFee,
            maxFee: maxFee,
            need: need,
            confidence: confidence,
            scoutingNotes: _generateScoutingNotes(player),
          ));
        }
      }
    }
    
    // Sort by priority and return top targets
    targets.sort((a, b) => b.priority.compareTo(a.priority));
    return targets.take(10).toList(); // Top 10 targets
  }

  /// Filters players based on transfer need
  List<Player> _filterPlayersByNeed(TransferNeed need, List<Player> players) {
    switch (need) {
      case TransferNeed.goalkeeper:
        return players.where((p) => p.position == PlayerPosition.goalkeeper).toList();
      case TransferNeed.defender:
        return players.where((p) => p.position == PlayerPosition.defender).toList();
      case TransferNeed.midfielder:
        return players.where((p) => p.position == PlayerPosition.midfielder).toList();
      case TransferNeed.forward:
        return players.where((p) => p.position == PlayerPosition.forward).toList();
      case TransferNeed.youth:
        return players.where((p) => p.age <= 23).toList();
      case TransferNeed.star:
        return players.where((p) => p.overallRating >= 85).toList();
      case TransferNeed.backup:
        return players.where((p) => p.overallRating >= 70 && p.overallRating <= 80).toList();
      case TransferNeed.depth:
        return players.where((p) => p.overallRating >= 65).toList();
    }
  }

  /// Estimates transfer fee for a player
  int _estimateTransferFee(Player player) {
    // Basic estimation based on rating, age, and position
    var baseFee = player.overallRating * 100000; // €100k per rating point
    
    // Age factor
    if (player.age <= 23) {
      baseFee = (baseFee * 1.5).round(); // Youth premium
    } else if (player.age >= 30) {
      baseFee = (baseFee * 0.7).round(); // Age discount
    }
    
    // Position factor
    switch (player.position) {
      case PlayerPosition.goalkeeper:
        baseFee = (baseFee * 0.8).round();
        break;
      case PlayerPosition.defender:
        baseFee = (baseFee * 0.9).round();
        break;
      case PlayerPosition.midfielder:
        baseFee = (baseFee * 1.1).round();
        break;
      case PlayerPosition.forward:
        baseFee = (baseFee * 1.3).round();
        break;
    }
    
    return baseFee.clamp(100000, 200000000); // €100k to €200M range
  }

  /// Calculates priority for a transfer target
  int _calculatePriority(TransferNeed need, Player player) {
    var priority = 5; // Base priority
    
    // Adjust based on need urgency
    switch (need) {
      case TransferNeed.goalkeeper:
      case TransferNeed.defender:
        priority += 3; // High priority for defensive positions
        break;
      case TransferNeed.star:
        priority += 2;
        break;
      case TransferNeed.youth:
        priority += (decisionEngine.gmProfile.youthFocus * 3).round();
        break;
      default:
        priority += 1;
    }
    
    // Adjust based on player quality
    if (player.overallRating >= 85) {
      priority += 2;
    } else if (player.overallRating >= 80) {
      priority += 1;
    }
    
    return priority.clamp(1, 10);
  }

  /// Calculates confidence in successfully acquiring a player
  double _calculateAcquisitionConfidence(Player player, int estimatedFee) {
    var confidence = 0.7; // Base confidence
    
    // Adjust based on player rating (higher rated = harder to get)
    if (player.overallRating >= 85) {
      confidence *= 0.6;
    } else if (player.overallRating >= 80) {
      confidence *= 0.8;
    }
    
    // Adjust based on fee relative to typical market
    final marketValue = _estimateTransferFee(player);
    if (estimatedFee > marketValue * 1.5) {
      confidence *= 0.7; // Overpaying reduces confidence
    }
    
    return confidence.clamp(0.1, 0.9);
  }

  /// Generates scouting notes for a player
  Map<String, dynamic> _generateScoutingNotes(Player player) {
    return {
      'age_profile': player.age <= 23 ? 'young' : player.age >= 30 ? 'experienced' : 'prime',
      'rating_category': player.overallRating >= 85 ? 'star' : player.overallRating >= 75 ? 'quality' : 'developing',
      'position_fit': 'suitable',
      'personality_match': _assessPersonalityMatch(player),
    };
  }

  /// Assesses how well a player matches the GM's personality preferences
  String _assessPersonalityMatch(Player player) {
    final gmPersonality = decisionEngine.gmProfile.personality;
    
    switch (gmPersonality) {
      case GMPersonality.youthFocused:
        return player.age <= 23 ? 'excellent' : 'poor';
      case GMPersonality.aggressive:
        return player.overallRating >= 80 ? 'excellent' : 'average';
      case GMPersonality.conservative:
        return player.age >= 25 && player.age <= 30 ? 'excellent' : 'average';
      case GMPersonality.tactical:
        return 'good'; // Assumes all players can fit tactical systems
      case GMPersonality.balanced:
        return 'good';
    }
  }

  /// Generates transfer strategy based on analysis
  String _generateTransferStrategy(Team team, List<TransferNeed> needs, int budget) {
    if (needs.isEmpty) {
      return 'Squad is well-balanced. Focus on opportunistic signings and youth development.';
    }
    
    if (budget < 5000000) { // Less than €5M
      return 'Limited budget strategy: Focus on loan deals, free transfers, and youth academy development.';
    }
    
    final priorityNeeds = needs.take(3).toList();
    final needsStr = priorityNeeds.map((n) => n.name).join(', ');
    
    return 'Target key positions: $needsStr. Budget allows for ${budget ~/ 1000000}M+ signings.';
  }

  /// Calculates confidence in the overall analysis
  double _calculateAnalysisConfidence(List<TransferNeed> needs, List<TransferTarget> targets) {
    if (needs.isEmpty) return 0.9; // High confidence in balanced squad
    
    final addressedNeeds = targets.map((t) => t.need).toSet().length;
    final totalNeeds = needs.length;
    
    return (addressedNeeds / totalNeeds).clamp(0.3, 0.9);
  }

  /// Builds context for transfer decisions
  Map<String, dynamic> _buildTransferContext(
    TransferTarget target,
    Team team,
    FinancialAccount financialAccount,
  ) {
    return {
      'player_rating': target.player.overallRating,
      'player_age': target.player.age,
      'transfer_fee': target.estimatedFee,
      'available_budget': financialAccount.getAvailableBudget(BudgetCategory.transfers),
      'squad_need_priority': target.priority,
      'position_need': target.need.name,
      'team_chemistry': team.chemistry,
      'squad_size': team.players.length,
      'acquisition_confidence': target.confidence,
    };
  }

  /// Builds context for sell decisions
  Map<String, dynamic> _buildSellContext(Player player, Team team, int offerAmount) {
    final estimatedValue = _estimateTransferFee(player);
    return {
      'player_rating': player.overallRating,
      'player_age': player.age,
      'offer_amount': offerAmount,
      'estimated_value': estimatedValue,
      'is_starter': team.startingXI.any((p) => p.id == player.id),
      'squad_depth': team.getPlayersByPosition(player.position).length,
      'value_vs_offer': offerAmount / estimatedValue,
    };
  }

  /// Creates a copy with updated properties
  TransferAI copyWith({
    DecisionEngine? decisionEngine,
    List<TransferTarget>? targets,
    int? transferBudget,
    int? minRatingThreshold,
    bool? isActive,
  }) {
    return TransferAI(
      decisionEngine: decisionEngine ?? this.decisionEngine,
      targets: targets ?? this.targets,
      transferBudget: transferBudget ?? this.transferBudget,
      minRatingThreshold: minRatingThreshold ?? this.minRatingThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    decisionEngine,
    targets,
    transferBudget,
    minRatingThreshold,
    isActive,
  ];
}
