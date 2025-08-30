// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_ai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadAnalysis _$SquadAnalysisFromJson(
  Map<String, dynamic> json,
) => SquadAnalysis(
  formationRecommendations:
      (json['formationRecommendations'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$FormationEnumMap, k), (e as num).toDouble()),
      ),
  optimalLineup: (json['optimalLineup'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  benchPlayers: (json['benchPlayers'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  captainRecommendation: json['captainRecommendation'] == null
      ? null
      : Player.fromJson(json['captainRecommendation'] as Map<String, dynamic>),
  balanceScores: (json['balanceScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  improvementAreas: (json['improvementAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$SquadAnalysisToJson(SquadAnalysis instance) =>
    <String, dynamic>{
      'formationRecommendations': instance.formationRecommendations.map(
        (k, e) => MapEntry(_$FormationEnumMap[k]!, e),
      ),
      'optimalLineup': instance.optimalLineup.map((e) => e.toJson()).toList(),
      'benchPlayers': instance.benchPlayers.map((e) => e.toJson()).toList(),
      'captainRecommendation': instance.captainRecommendation?.toJson(),
      'balanceScores': instance.balanceScores,
      'improvementAreas': instance.improvementAreas,
      'confidence': instance.confidence,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$FormationEnumMap = {
  Formation.f442: 'f442',
  Formation.f433: 'f433',
  Formation.f352: 'f352',
  Formation.f541: 'f541',
  Formation.f343: 'f343',
  Formation.f532: 'f532',
  Formation.f4231: 'f4231',
  Formation.f4141: 'f4141',
  Formation.f451: 'f451',
  Formation.f3421: 'f3421',
};

PlayerCondition _$PlayerConditionFromJson(Map<String, dynamic> json) =>
    PlayerCondition(
      playerId: json['playerId'] as String,
      fitness: (json['fitness'] as num).toInt(),
      form: (json['form'] as num).toInt(),
      recentMatches: (json['recentMatches'] as num).toInt(),
      minutesPlayed: (json['minutesPlayed'] as num).toInt(),
      injuryRisk: (json['injuryRisk'] as num).toInt(),
      lastPerformance: (json['lastPerformance'] as num).toInt(),
      morale: (json['morale'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerConditionToJson(PlayerCondition instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'fitness': instance.fitness,
      'form': instance.form,
      'recentMatches': instance.recentMatches,
      'minutesPlayed': instance.minutesPlayed,
      'injuryRisk': instance.injuryRisk,
      'lastPerformance': instance.lastPerformance,
      'morale': instance.morale,
    };

SquadAI _$SquadAIFromJson(Map<String, dynamic> json) => SquadAI(
  decisionEngine: DecisionEngine.fromJson(
    json['decisionEngine'] as Map<String, dynamic>,
  ),
  priorities:
      (json['priorities'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SquadPriorityEnumMap, e))
          .toList() ??
      const [SquadPriority.balance],
  playerConditions:
      (json['playerConditions'] as List<dynamic>?)
          ?.map((e) => PlayerCondition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  preferredFormation: $enumDecodeNullable(
    _$FormationEnumMap,
    json['preferredFormation'],
  ),
  autoRotation: json['autoRotation'] as bool? ?? true,
  minFitnessThreshold: (json['minFitnessThreshold'] as num?)?.toInt() ?? 75,
);

Map<String, dynamic> _$SquadAIToJson(SquadAI instance) => <String, dynamic>{
  'decisionEngine': instance.decisionEngine.toJson(),
  'priorities': instance.priorities
      .map((e) => _$SquadPriorityEnumMap[e]!)
      .toList(),
  'playerConditions': instance.playerConditions.map((e) => e.toJson()).toList(),
  'preferredFormation': _$FormationEnumMap[instance.preferredFormation],
  'autoRotation': instance.autoRotation,
  'minFitnessThreshold': instance.minFitnessThreshold,
};

const _$SquadPriorityEnumMap = {
  SquadPriority.fitness: 'fitness',
  SquadPriority.form: 'form',
  SquadPriority.chemistry: 'chemistry',
  SquadPriority.experience: 'experience',
  SquadPriority.youth: 'youth',
  SquadPriority.balance: 'balance',
  SquadPriority.attack: 'attack',
  SquadPriority.defense: 'defense',
};
