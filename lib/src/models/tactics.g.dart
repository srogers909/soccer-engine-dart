// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tactics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TacticalSetup _$TacticalSetupFromJson(
  Map<String, dynamic> json,
) => TacticalSetup(
  formation: $enumDecode(_$FormationEnumMap, json['formation']),
  attackingMentality: $enumDecode(
    _$AttackingMentalityEnumMap,
    json['attackingMentality'],
  ),
  defensiveStyle: $enumDecode(_$DefensiveStyleEnumMap, json['defensiveStyle']),
  attackingStyle: $enumDecode(_$AttackingStyleEnumMap, json['attackingStyle']),
  width: (json['width'] as num).toInt(),
  tempo: (json['tempo'] as num).toInt(),
  defensiveLine: (json['defensiveLine'] as num).toInt(),
  pressing: (json['pressing'] as num).toInt(),
);

Map<String, dynamic> _$TacticalSetupToJson(TacticalSetup instance) =>
    <String, dynamic>{
      'formation': _$FormationEnumMap[instance.formation]!,
      'attackingMentality':
          _$AttackingMentalityEnumMap[instance.attackingMentality]!,
      'defensiveStyle': _$DefensiveStyleEnumMap[instance.defensiveStyle]!,
      'attackingStyle': _$AttackingStyleEnumMap[instance.attackingStyle]!,
      'width': instance.width,
      'tempo': instance.tempo,
      'defensiveLine': instance.defensiveLine,
      'pressing': instance.pressing,
    };

const _$FormationEnumMap = {
  Formation.f442: '4-4-2',
  Formation.f433: '4-3-3',
  Formation.f352: '3-5-2',
  Formation.f532: '5-3-2',
  Formation.f451: '4-5-1',
  Formation.f4231: '4-2-3-1',
  Formation.f343: '3-4-3',
  Formation.f4141: '4-1-4-1',
};

const _$AttackingMentalityEnumMap = {
  AttackingMentality.ultraDefensive: 'ultra-defensive',
  AttackingMentality.defensive: 'defensive',
  AttackingMentality.balanced: 'balanced',
  AttackingMentality.attacking: 'attacking',
  AttackingMentality.ultraAttacking: 'ultra-attacking',
};

const _$DefensiveStyleEnumMap = {
  DefensiveStyle.manMarking: 'man-marking',
  DefensiveStyle.zonal: 'zonal',
  DefensiveStyle.highPress: 'high-press',
  DefensiveStyle.lowBlock: 'low-block',
};

const _$AttackingStyleEnumMap = {
  AttackingStyle.possession: 'possession',
  AttackingStyle.counterAttack: 'counter-attack',
  AttackingStyle.direct: 'direct',
  AttackingStyle.wingPlay: 'wing-play',
};

PlayerRole _$PlayerRoleFromJson(Map<String, dynamic> json) => PlayerRole(
  position: $enumDecode(_$PlayerPositionEnumMap, json['position']),
  attackingFreedom: (json['attackingFreedom'] as num).toInt(),
  defensiveWork: (json['defensiveWork'] as num).toInt(),
  width: (json['width'] as num).toInt(),
  creativeFreedom: (json['creativeFreedom'] as num).toInt(),
);

Map<String, dynamic> _$PlayerRoleToJson(PlayerRole instance) =>
    <String, dynamic>{
      'position': _$PlayerPositionEnumMap[instance.position]!,
      'attackingFreedom': instance.attackingFreedom,
      'defensiveWork': instance.defensiveWork,
      'width': instance.width,
      'creativeFreedom': instance.creativeFreedom,
    };

const _$PlayerPositionEnumMap = {
  PlayerPosition.goalkeeper: 'goalkeeper',
  PlayerPosition.centreBack: 'centre-back',
  PlayerPosition.leftBack: 'left-back',
  PlayerPosition.rightBack: 'right-back',
  PlayerPosition.wingBack: 'wing-back',
  PlayerPosition.defensiveMidfielder: 'defensive-midfielder',
  PlayerPosition.centreMidfielder: 'centre-midfielder',
  PlayerPosition.attackingMidfielder: 'attacking-midfielder',
  PlayerPosition.leftWinger: 'left-winger',
  PlayerPosition.rightWinger: 'right-winger',
  PlayerPosition.striker: 'striker',
};
