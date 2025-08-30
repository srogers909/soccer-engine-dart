// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Decision _$DecisionFromJson(Map<String, dynamic> json) => Decision(
  type: $enumDecode(_$DecisionTypeEnumMap, json['type']),
  selectedOption: json['selectedOption'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  reasoning: json['reasoning'] as String,
  gmProfile: GMProfile.fromJson(json['gmProfile'] as Map<String, dynamic>),
  context: json['context'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$DecisionToJson(Decision instance) => <String, dynamic>{
  'type': _$DecisionTypeEnumMap[instance.type]!,
  'selectedOption': instance.selectedOption,
  'confidence': instance.confidence,
  'reasoning': instance.reasoning,
  'gmProfile': instance.gmProfile.toJson(),
  'context': instance.context,
  'timestamp': instance.timestamp.toIso8601String(),
};

const _$DecisionTypeEnumMap = {
  DecisionType.transfer: 'transfer',
  DecisionType.formation: 'formation',
  DecisionType.lineup: 'lineup',
  DecisionType.tactics: 'tactics',
  DecisionType.contract: 'contract',
  DecisionType.budget: 'budget',
  DecisionType.youth: 'youth',
  DecisionType.training: 'training',
  DecisionType.facility: 'facility',
};

DecisionEngine _$DecisionEngineFromJson(Map<String, dynamic> json) =>
    DecisionEngine(
      gmProfile: GMProfile.fromJson(json['gmProfile'] as Map<String, dynamic>),
      isEnabled: json['isEnabled'] as bool? ?? true,
      decisionHistory:
          (json['decisionHistory'] as List<dynamic>?)
              ?.map((e) => Decision.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      maxHistorySize: (json['maxHistorySize'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$DecisionEngineToJson(
  DecisionEngine instance,
) => <String, dynamic>{
  'gmProfile': instance.gmProfile.toJson(),
  'isEnabled': instance.isEnabled,
  'decisionHistory': instance.decisionHistory.map((e) => e.toJson()).toList(),
  'maxHistorySize': instance.maxHistorySize,
};
