// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gm_ai_system.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AITask _$AITaskFromJson(Map<String, dynamic> json) => AITask(
  id: json['id'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$DecisionPriorityEnumMap, json['priority']),
  scheduledTime: DateTime.parse(json['scheduledTime'] as String),
  taskType: json['taskType'] as String,
  parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$AITaskToJson(AITask instance) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'priority': _$DecisionPriorityEnumMap[instance.priority]!,
  'scheduledTime': instance.scheduledTime.toIso8601String(),
  'taskType': instance.taskType,
  'parameters': instance.parameters,
  'isCompleted': instance.isCompleted,
};

const _$DecisionPriorityEnumMap = {
  DecisionPriority.critical: 'critical',
  DecisionPriority.high: 'high',
  DecisionPriority.medium: 'medium',
  DecisionPriority.low: 'low',
};

AISystemReport _$AISystemReportFromJson(Map<String, dynamic> json) =>
    AISystemReport(
      transferAnalysis: json['transferAnalysis'] == null
          ? null
          : TransferMarketAnalysis.fromJson(
              json['transferAnalysis'] as Map<String, dynamic>,
            ),
      squadAnalysis: json['squadAnalysis'] == null
          ? null
          : SquadAnalysis.fromJson(
              json['squadAnalysis'] as Map<String, dynamic>,
            ),
      budgetStatus: json['budgetStatus'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$AISystemReportToJson(AISystemReport instance) =>
    <String, dynamic>{
      'transferAnalysis': instance.transferAnalysis?.toJson(),
      'squadAnalysis': instance.squadAnalysis?.toJson(),
      'budgetStatus': instance.budgetStatus,
      'recommendations': instance.recommendations,
      'performanceMetrics': instance.performanceMetrics,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': instance.confidence,
    };

GMAISystem _$GMAISystemFromJson(Map<String, dynamic> json) => GMAISystem(
  decisionEngine: DecisionEngine.fromJson(
    json['decisionEngine'] as Map<String, dynamic>,
  ),
  transferAI: TransferAI.fromJson(json['transferAI'] as Map<String, dynamic>),
  squadAI: SquadAI.fromJson(json['squadAI'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$AISystemStatusEnumMap, json['status']) ??
      AISystemStatus.active,
  scheduledTasks:
      (json['scheduledTasks'] as List<dynamic>?)
          ?.map((e) => AITask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  systemDecisionHistory:
      (json['systemDecisionHistory'] as List<dynamic>?)
          ?.map((e) => Decision.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  configuration: json['configuration'] as Map<String, dynamic>? ?? const {},
  autoExecute: json['autoExecute'] as bool? ?? false,
  autoExecuteThreshold:
      (json['autoExecuteThreshold'] as num?)?.toDouble() ?? 0.8,
);

Map<String, dynamic> _$GMAISystemToJson(GMAISystem instance) =>
    <String, dynamic>{
      'decisionEngine': instance.decisionEngine.toJson(),
      'transferAI': instance.transferAI.toJson(),
      'squadAI': instance.squadAI.toJson(),
      'status': _$AISystemStatusEnumMap[instance.status]!,
      'scheduledTasks': instance.scheduledTasks.map((e) => e.toJson()).toList(),
      'systemDecisionHistory': instance.systemDecisionHistory
          .map((e) => e.toJson())
          .toList(),
      'configuration': instance.configuration,
      'autoExecute': instance.autoExecute,
      'autoExecuteThreshold': instance.autoExecuteThreshold,
    };

const _$AISystemStatusEnumMap = {
  AISystemStatus.active: 'active',
  AISystemStatus.inactive: 'inactive',
  AISystemStatus.maintenance: 'maintenance',
  AISystemStatus.error: 'error',
};
