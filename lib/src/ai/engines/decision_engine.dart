import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../models/gm_profile.dart';

part 'decision_engine.g.dart';

/// Types of decisions that can be made by the AI system
enum DecisionType {
  @JsonValue('transfer')
  transfer,
  @JsonValue('formation')
  formation,
  @JsonValue('lineup')
  lineup,
  @JsonValue('tactics')
  tactics,
  @JsonValue('contract')
  contract,
  @JsonValue('budget')
  budget,
  @JsonValue('youth')
  youth,
  @JsonValue('training')
  training,
  @JsonValue('facility')
  facility,
}

/// Represents a decision made by the AI system
@JsonSerializable(explicitToJson: true)
class Decision extends Equatable {
  /// The type of decision
  final DecisionType type;
  
  /// The selected option from available choices
  final String selectedOption;
  
  /// Confidence level in the decision (0.0 to 1.0)
  final double confidence;
  
  /// Human-readable reasoning for the decision
  final String reasoning;
  
  /// The GM profile that made this decision
  final GMProfile gmProfile;
  
  /// Context data that influenced the decision
  final Map<String, dynamic> context;
  
  /// Timestamp when the decision was made
  final DateTime timestamp;

  const Decision({
    required this.type,
    required this.selectedOption,
    required this.confidence,
    required this.reasoning,
    required this.gmProfile,
    required this.context,
    required this.timestamp,
  });

  /// Creates a Decision from JSON
  factory Decision.fromJson(Map<String, dynamic> json) => _$DecisionFromJson(json);

  /// Converts this Decision to JSON
  Map<String, dynamic> toJson() => _$DecisionToJson(this);

  /// Creates a copy with modified properties
  Decision copyWith({
    DecisionType? type,
    String? selectedOption,
    double? confidence,
    String? reasoning,
    GMProfile? gmProfile,
    Map<String, dynamic>? context,
    DateTime? timestamp,
  }) {
    return Decision(
      type: type ?? this.type,
      selectedOption: selectedOption ?? this.selectedOption,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      gmProfile: gmProfile ?? this.gmProfile,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        type,
        selectedOption,
        confidence,
        reasoning,
        gmProfile,
        context,
        timestamp,
      ];
}

/// The core decision-making engine for GM AI
@JsonSerializable(explicitToJson: true)
class DecisionEngine extends Equatable {
  /// The GM profile governing decision-making behavior
  final GMProfile gmProfile;
  
  /// Whether the engine is currently enabled
  final bool isEnabled;
  
  /// History of decisions made by this engine
  final List<Decision> decisionHistory;
  
  /// Maximum number of decisions to keep in history
  final int maxHistorySize;

  const DecisionEngine({
    required this.gmProfile,
    this.isEnabled = true,
    this.decisionHistory = const [],
    this.maxHistorySize = 100,
  });

  /// Creates a DecisionEngine from JSON
  factory DecisionEngine.fromJson(Map<String, dynamic> json) => 
      _$DecisionEngineFromJson(json);

  /// Converts this DecisionEngine to JSON
  Map<String, dynamic> toJson() => _$DecisionEngineToJson(this);

  /// Makes a decision given a type, options, and context
  Decision makeDecision({
    required DecisionType type,
    required List<String> options,
    required Map<String, dynamic> context,
  }) {
    if (!isEnabled) {
      throw StateError('DecisionEngine is disabled');
    }
    
    if (options.isEmpty) {
      throw ArgumentError('Options list cannot be empty');
    }

    // Calculate weights based on GM personality and context
    final weights = calculateWeights(type: type, context: context);
    
    // Select option based on weighted decision algorithm
    final selectedOption = _selectOption(options, weights, context);
    
    // Calculate confidence based on weights and context clarity
    final confidence = _calculateConfidence(weights, context);
    
    // Generate reasoning explanation
    final reasoning = _generateReasoning(type, selectedOption, weights, context);
    
    // Create the decision
    final decision = Decision(
      type: type,
      selectedOption: selectedOption,
      confidence: confidence,
      reasoning: reasoning,
      gmProfile: gmProfile,
      context: Map.from(context),
      timestamp: DateTime.now(),
    );
    
    return decision;
  }

  /// Calculates decision weights based on GM personality and context
  Map<String, double> calculateWeights({
    required DecisionType type,
    required Map<String, dynamic> context,
  }) {
    final weights = <String, double>{};
    
    switch (type) {
      case DecisionType.transfer:
        weights.addAll(_calculateTransferWeights(context));
        break;
      case DecisionType.formation:
        weights.addAll(_calculateFormationWeights(context));
        break;
      case DecisionType.lineup:
        weights.addAll(_calculateLineupWeights(context));
        break;
      case DecisionType.tactics:
        weights.addAll(_calculateTacticsWeights(context));
        break;
      case DecisionType.contract:
        weights.addAll(_calculateContractWeights(context));
        break;
      case DecisionType.budget:
        weights.addAll(_calculateBudgetWeights(context));
        break;
      case DecisionType.youth:
        weights.addAll(_calculateYouthWeights(context));
        break;
      case DecisionType.training:
        weights.addAll(_calculateTrainingWeights(context));
        break;
      case DecisionType.facility:
        weights.addAll(_calculateFacilityWeights(context));
        break;
    }
    
    return weights;
  }

  /// Transfer decision weights based on GM personality
  Map<String, double> _calculateTransferWeights(Map<String, dynamic> context) {
    final weights = <String, double>{};
    
    // Base weights influenced by GM personality
    switch (gmProfile.personality) {
      case GMPersonality.conservative:
        weights['stability'] = 0.8;
        weights['experience'] = 0.7;
        weights['value'] = 0.9;
        weights['risk'] = 0.2;
        weights['youth'] = 0.4;
        break;
      case GMPersonality.aggressive:
        weights['potential'] = 0.9;
        weights['attacking'] = 0.8;
        weights['risk'] = 0.7;
        weights['value'] = 0.5;
        weights['youth'] = 0.6;
        break;
      case GMPersonality.balanced:
        weights['stability'] = 0.6;
        weights['potential'] = 0.6;
        weights['experience'] = 0.6;
        weights['value'] = 0.7;
        weights['youth'] = 0.5;
        break;
      case GMPersonality.youthFocused:
        weights['youth'] = 0.9;
        weights['potential'] = 0.8;
        weights['development'] = 0.8;
        weights['value'] = 0.8;
        weights['experience'] = 0.3;
        break;
      case GMPersonality.tactical:
        weights['tactical_fit'] = 0.9;
        weights['versatility'] = 0.7;
        weights['intelligence'] = 0.8;
        weights['experience'] = 0.6;
        weights['value'] = 0.6;
        break;
    }
    
    return weights;
  }

  /// Formation decision weights
  Map<String, double> _calculateFormationWeights(Map<String, dynamic> context) {
    final weights = <String, double>{};
    
    // Use GM's formation preference method with context
    final formations = ['4-4-2', '4-3-3', '3-5-2', '4-2-3-1'];
    final availablePlayers = context['availablePlayers'] as int? ?? 11;
    
    for (final formation in formations) {
      weights[formation] = gmProfile.getFormationPreferenceWeight(
        formation: formation,
        availablePlayers: availablePlayers,
      );
    }
    
    return weights;
  }

  /// Generic weight calculation for other decision types
  Map<String, double> _calculateLineupWeights(Map<String, dynamic> context) {
    return {'fitness': 0.7, 'form': 0.8, 'experience': 0.6};
  }

  Map<String, double> _calculateTacticsWeights(Map<String, dynamic> context) {
    return {'aggression': gmProfile.personality == GMPersonality.aggressive ? 0.8 : 0.4};
  }

  Map<String, double> _calculateContractWeights(Map<String, dynamic> context) {
    return {'value': 0.8, 'length': 0.6, 'loyalty': 0.5};
  }

  Map<String, double> _calculateBudgetWeights(Map<String, dynamic> context) {
    final allocation = gmProfile.getBudgetAllocation(1000000);
    return {
      'youth': allocation.youthBudget / 1000000,
      'facilities': allocation.facilitiesBudget / 1000000,
    };
  }

  Map<String, double> _calculateYouthWeights(Map<String, dynamic> context) {
    return {'potential': 0.9, 'age': 0.7, 'development': 0.8};
  }

  Map<String, double> _calculateTrainingWeights(Map<String, dynamic> context) {
    return {'intensity': 0.6, 'focus': 0.7};
  }

  Map<String, double> _calculateFacilityWeights(Map<String, dynamic> context) {
    return {'efficiency': 0.8, 'cost': 0.7};
  }

  /// Selects an option based on weights and randomization
  String _selectOption(List<String> options, Map<String, double> weights, 
                      Map<String, dynamic> context) {
    // Simple implementation: choose randomly but weight towards first option
    // In a real implementation, this would use sophisticated algorithms
    if (options.length == 1) return options.first;
    
    // For now, return the first option (can be enhanced later)
    return options.first;
  }

  /// Calculates confidence in the decision
  double _calculateConfidence(Map<String, double> weights, 
                            Map<String, dynamic> context) {
    if (weights.isEmpty) return 0.5;
    
    // Average of all weights as a simple confidence measure
    final avgWeight = weights.values.reduce((a, b) => a + b) / weights.length;
    return (avgWeight * 0.8 + 0.2).clamp(0.0, 1.0);
  }

  /// Generates human-readable reasoning for the decision
  String _generateReasoning(DecisionType type, String selectedOption, 
                          Map<String, double> weights, 
                          Map<String, dynamic> context) {
    final personality = gmProfile.personality.toString().split('.').last;
    return 'Selected "$selectedOption" based on $personality management style and current context.';
  }

  /// Updates the decision history (used internally for state management)
  void _updateHistory(Decision decision) {
    // This is a workaround for immutable design in tests
    // In practice, we'd return a new engine instance
  }

  /// Enables the decision engine
  DecisionEngine enable() {
    return copyWith(isEnabled: true);
  }

  /// Disables the decision engine
  DecisionEngine disable() {
    return copyWith(isEnabled: false);
  }

  /// Clears the decision history
  DecisionEngine clearHistory() {
    return copyWith(decisionHistory: []);
  }

  /// Creates a copy with modified properties
  DecisionEngine copyWith({
    GMProfile? gmProfile,
    bool? isEnabled,
    List<Decision>? decisionHistory,
    int? maxHistorySize,
  }) {
    return DecisionEngine(
      gmProfile: gmProfile ?? this.gmProfile,
      isEnabled: isEnabled ?? this.isEnabled,
      decisionHistory: decisionHistory ?? this.decisionHistory,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
    );
  }

  @override
  List<Object?> get props => [
        gmProfile,
        isEnabled,
        decisionHistory,
        maxHistorySize,
      ];
}
