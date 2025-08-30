import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:soccer_utilities/src/models/player.dart';
import '../../models/team.dart';
import '../../models/transfer.dart';
import '../../models/financial_account.dart';
import '../../models/youth_academy.dart';
import '../engines/decision_engine.dart';
import '../models/gm_profile.dart';
import 'transfer_ai.dart';
import 'squad_ai.dart';

part 'gm_ai_system.g.dart';

/// Overall AI system status
enum AISystemStatus {
  active,
  inactive,
  maintenance,
  error,
}

/// AI decision priority levels
enum DecisionPriority {
  critical,
  high,
  medium,
  low,
}

/// Scheduled AI task
@JsonSerializable(explicitToJson: true)
class AITask extends Equatable {
  /// Unique task identifier
  final String id;
  
  /// Task description
  final String description;
  
  /// Task priority
  final DecisionPriority priority;
  
  /// When the task should be executed
  final DateTime scheduledTime;
  
  /// Task type identifier
  final String taskType;
  
  /// Task-specific parameters
  final Map<String, dynamic> parameters;
  
  /// Whether the task has been completed
  final bool isCompleted;

  const AITask({
    required this.id,
    required this.description,
    required this.priority,
    required this.scheduledTime,
    required this.taskType,
    this.parameters = const {},
    this.isCompleted = false,
  });

  /// Creates an AITask from JSON
  factory AITask.fromJson(Map<String, dynamic> json) => 
      _$AITaskFromJson(json);

  /// Converts this AITask to JSON
  Map<String, dynamic> toJson() => _$AITaskToJson(this);

  /// Marks task as completed
  AITask complete() {
    return AITask(
      id: id,
      description: description,
      priority: priority,
      scheduledTime: scheduledTime,
      taskType: taskType,
      parameters: parameters,
      isCompleted: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    description,
    priority,
    scheduledTime,
    taskType,
    parameters,
    isCompleted,
  ];
}

/// Comprehensive GM AI system report
@JsonSerializable(explicitToJson: true)
class AISystemReport extends Equatable {
  /// Transfer market analysis
  final TransferMarketAnalysis? transferAnalysis;
  
  /// Squad analysis
  final SquadAnalysis? squadAnalysis;
  
  /// Current budget status
  final Map<String, dynamic> budgetStatus;
  
  /// Recommended actions
  final List<String> recommendations;
  
  /// System performance metrics
  final Map<String, double> performanceMetrics;
  
  /// Report timestamp
  final DateTime timestamp;
  
  /// Report confidence score
  final double confidence;

  const AISystemReport({
    this.transferAnalysis,
    this.squadAnalysis,
    required this.budgetStatus,
    required this.recommendations,
    required this.performanceMetrics,
    required this.timestamp,
    required this.confidence,
  });

  /// Creates an AISystemReport from JSON
  factory AISystemReport.fromJson(Map<String, dynamic> json) => 
      _$AISystemReportFromJson(json);

  /// Converts this AISystemReport to JSON
  Map<String, dynamic> toJson() => _$AISystemReportToJson(this);

  @override
  List<Object?> get props => [
    transferAnalysis,
    squadAnalysis,
    budgetStatus,
    recommendations,
    performanceMetrics,
    timestamp,
    confidence,
  ];
}

/// Main GM AI system coordinator
@JsonSerializable(explicitToJson: true)
class GMAISystem extends Equatable {
  /// Core decision engine
  final DecisionEngine decisionEngine;
  
  /// Transfer management AI
  final TransferAI transferAI;
  
  /// Squad management AI
  final SquadAI squadAI;
  
  /// System status
  final AISystemStatus status;
  
  /// Scheduled tasks
  final List<AITask> scheduledTasks;
  
  /// Decision history for performance tracking
  final List<Decision> systemDecisionHistory;
  
  /// System configuration
  final Map<String, dynamic> configuration;
  
  /// Whether to auto-execute decisions
  final bool autoExecute;
  
  /// Minimum confidence threshold for auto-execution
  final double autoExecuteThreshold;

  const GMAISystem({
    required this.decisionEngine,
    required this.transferAI,
    required this.squadAI,
    this.status = AISystemStatus.active,
    this.scheduledTasks = const [],
    this.systemDecisionHistory = const [],
    this.configuration = const {},
    this.autoExecute = false,
    this.autoExecuteThreshold = 0.8,
  });

  /// Creates a GMAISystem from JSON
  factory GMAISystem.fromJson(Map<String, dynamic> json) => 
      _$GMAISystemFromJson(json);

  /// Converts this GMAISystem to JSON
  Map<String, dynamic> toJson() => _$GMAISystemToJson(this);

  /// Generates comprehensive system report
  AISystemReport generateSystemReport({
    required Team team,
    required FinancialAccount financialAccount,
    required List<Player> availablePlayers,
  }) {
    if (status != AISystemStatus.active) {
      return AISystemReport(
        budgetStatus: {},
        recommendations: ['AI System is not active'],
        performanceMetrics: {},
        timestamp: DateTime.now(),
        confidence: 0.0,
      );
    }

    // Generate transfer analysis
    final transferAnalysis = transferAI.analyzeTransferNeeds(
      team: team,
      financialAccount: financialAccount,
      availablePlayers: availablePlayers,
    );

    // Generate squad analysis
    final squadAnalysis = squadAI.analyzeSquad(
      team: team,
      conditions: squadAI.playerConditions,
    );

    // Analyze budget status
    final budgetStatus = _analyzeBudgetStatus(financialAccount);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      team,
      transferAnalysis,
      squadAnalysis,
      budgetStatus,
    );

    // Calculate performance metrics
    final performanceMetrics = _calculatePerformanceMetrics();

    // Overall confidence
    final confidence = _calculateOverallConfidence(
      transferAnalysis.confidence,
      squadAnalysis.confidence,
    );

    return AISystemReport(
      transferAnalysis: transferAnalysis,
      squadAnalysis: squadAnalysis,
      budgetStatus: budgetStatus,
      recommendations: recommendations,
      performanceMetrics: performanceMetrics,
      timestamp: DateTime.now(),
      confidence: confidence,
    );
  }

  /// Makes a comprehensive transfer decision
  Decision makeTransferDecision({
    required TransferTarget target,
    required Team team,
    required FinancialAccount financialAccount,
  }) {
    final decision = transferAI.makeTransferDecision(
      target: target,
      team: team,
      financialAccount: financialAccount,
    );

    // Log decision for system learning
    _logSystemDecision(decision);

    return decision;
  }

  /// Makes a squad management decision
  Decision makeSquadDecision({
    required Team team,
    required String decisionType,
    required Map<String, dynamic> context,
  }) {
    final Decision decision;

    switch (decisionType) {
      case 'formation':
        decision = squadAI.makeFormationDecision(
          team: team,
          availableFormations: Formation.values,
        );
        break;
      case 'lineup':
        decision = squadAI.makeLineupDecision(
          team: team,
          formation: team.formation,
          availablePlayers: team.players,
        );
        break;
      default:
        decision = decisionEngine.makeDecision(
          type: DecisionType.tactics,
          options: ['maintain', 'adjust'],
          context: context,
        );
    }

    _logSystemDecision(decision);
    return decision;
  }

  /// Schedules an AI task for future execution
  GMAISystem scheduleTask(AITask task) {
    final updatedTasks = [...scheduledTasks, task];
    return copyWith(scheduledTasks: updatedTasks);
  }

  /// Executes pending tasks
  GMAISystem executePendingTasks() {
    final now = DateTime.now();
    final pendingTasks = scheduledTasks.where((task) => 
        !task.isCompleted && task.scheduledTime.isBefore(now)).toList();

    if (pendingTasks.isEmpty) return this;

    // Execute high-priority tasks first
    pendingTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final updatedTasks = scheduledTasks.map((task) {
      if (pendingTasks.contains(task)) {
        // Execute task logic here
        return task.complete();
      }
      return task;
    }).toList();

    return copyWith(scheduledTasks: updatedTasks);
  }

  /// Updates player conditions for squad AI
  GMAISystem updatePlayerConditions(List<PlayerCondition> conditions) {
    final updatedSquadAI = squadAI.copyWith(playerConditions: conditions);
    return copyWith(squadAI: updatedSquadAI);
  }

  /// Updates transfer targets
  GMAISystem updateTransferTargets(List<TransferTarget> targets) {
    final updatedTransferAI = transferAI.copyWith(targets: targets);
    return copyWith(transferAI: updatedTransferAI);
  }

  /// Analyzes budget status across categories
  Map<String, dynamic> _analyzeBudgetStatus(FinancialAccount account) {
    return {
      'total_balance': account.balance,
      'transfer_budget': account.getAvailableBudget(BudgetCategory.transfers),
      'wage_budget': account.getAvailableBudget(BudgetCategory.wages),
      'youth_budget': account.getAvailableBudget(BudgetCategory.youth),
      'facilities_budget': account.getAvailableBudget(BudgetCategory.facilities),
      'ffp_status': account.checkFFPCompliance(
        DateTime.now().subtract(const Duration(days: 1095)), // 3 years ago
        DateTime.now(),
      ).isCompliant,
    };
  }

  /// Generates system recommendations
  List<String> _generateRecommendations(
    Team team,
    TransferMarketAnalysis transferAnalysis,
    SquadAnalysis squadAnalysis,
    Map<String, dynamic> budgetStatus,
  ) {
    final recommendations = <String>[];

    // Transfer recommendations
    if (transferAnalysis.targets.isNotEmpty) {
      final topTarget = transferAnalysis.targets.first;
      recommendations.add(
        'Priority transfer: ${topTarget.player.name} (${topTarget.need.name}) - €${topTarget.estimatedFee ~/ 1000000}M'
      );
    }

    // Squad recommendations
    if (squadAnalysis.improvementAreas.isNotEmpty) {
      recommendations.addAll(squadAnalysis.improvementAreas.take(2));
    }

    // Budget recommendations
    final transferBudget = budgetStatus['transfer_budget'] as int;
    if (transferBudget < 5000000) {
      recommendations.add('Consider loan deals or free transfers due to limited budget');
    }

    // Formation recommendations
    final bestFormation = squadAnalysis.formationRecommendations.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    if (bestFormation.value > 0.8 && bestFormation.key != team.formation) {
      recommendations.add('Consider switching to ${bestFormation.key.displayName} formation');
    }

    return recommendations.take(5).toList(); // Top 5 recommendations
  }

  /// Calculates system performance metrics
  Map<String, double> _calculatePerformanceMetrics() {
    if (systemDecisionHistory.isEmpty) {
      return {
        'avg_decision_confidence': 0.7,
        'decision_count': 0.0,
        'success_rate': 0.0,
      };
    }

    final avgConfidence = systemDecisionHistory
        .map((d) => d.confidence)
        .reduce((a, b) => a + b) / systemDecisionHistory.length;

    return {
      'avg_decision_confidence': avgConfidence,
      'decision_count': systemDecisionHistory.length.toDouble(),
      'success_rate': 0.75, // Placeholder - would track actual outcomes
    };
  }

  /// Calculates overall system confidence
  double _calculateOverallConfidence(double transferConfidence, double squadConfidence) {
    return (transferConfidence + squadConfidence) / 2;
  }

  /// Logs a decision for system performance tracking
  void _logSystemDecision(Decision decision) {
    // In a mutable implementation, this would add to history
    // For immutable pattern, this is handled externally
  }

  /// Activates the AI system
  GMAISystem activate() {
    return copyWith(status: AISystemStatus.active);
  }

  /// Deactivates the AI system
  GMAISystem deactivate() {
    return copyWith(status: AISystemStatus.inactive);
  }

  /// Puts system in maintenance mode
  GMAISystem enterMaintenance() {
    return copyWith(status: AISystemStatus.maintenance);
  }

  /// Sets system configuration
  GMAISystem configure(Map<String, dynamic> newConfiguration) {
    return copyWith(configuration: newConfiguration);
  }

  /// Enables auto-execution of decisions
  GMAISystem enableAutoExecution({double? threshold}) {
    return copyWith(
      autoExecute: true,
      autoExecuteThreshold: threshold ?? autoExecuteThreshold,
    );
  }

  /// Disables auto-execution of decisions
  GMAISystem disableAutoExecution() {
    return copyWith(autoExecute: false);
  }

  /// Creates a copy with updated properties
  GMAISystem copyWith({
    DecisionEngine? decisionEngine,
    TransferAI? transferAI,
    SquadAI? squadAI,
    AISystemStatus? status,
    List<AITask>? scheduledTasks,
    List<Decision>? systemDecisionHistory,
    Map<String, dynamic>? configuration,
    bool? autoExecute,
    double? autoExecuteThreshold,
  }) {
    return GMAISystem(
      decisionEngine: decisionEngine ?? this.decisionEngine,
      transferAI: transferAI ?? this.transferAI,
      squadAI: squadAI ?? this.squadAI,
      status: status ?? this.status,
      scheduledTasks: scheduledTasks ?? this.scheduledTasks,
      systemDecisionHistory: systemDecisionHistory ?? this.systemDecisionHistory,
      configuration: configuration ?? this.configuration,
      autoExecute: autoExecute ?? this.autoExecute,
      autoExecuteThreshold: autoExecuteThreshold ?? this.autoExecuteThreshold,
    );
  }

  @override
  List<Object?> get props => [
    decisionEngine,
    transferAI,
    squadAI,
    status,
    scheduledTasks,
    systemDecisionHistory,
    configuration,
    autoExecute,
    autoExecuteThreshold,
  ];
}
