// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youth_academy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scout _$ScoutFromJson(Map<String, dynamic> json) => Scout(
  id: json['id'] as String,
  name: json['name'] as String,
  ability: (json['ability'] as num).toInt(),
  networkQuality: (json['networkQuality'] as num).toInt(),
  specialization: $enumDecode(
    _$ScoutSpecializationEnumMap,
    json['specialization'],
  ),
  region: $enumDecode(_$ScoutRegionEnumMap, json['region']),
  cost: (json['cost'] as num).toInt(),
);

Map<String, dynamic> _$ScoutToJson(Scout instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ability': instance.ability,
  'networkQuality': instance.networkQuality,
  'specialization': _$ScoutSpecializationEnumMap[instance.specialization]!,
  'region': _$ScoutRegionEnumMap[instance.region]!,
  'cost': instance.cost,
};

const _$ScoutSpecializationEnumMap = {
  ScoutSpecialization.technical: 'technical',
  ScoutSpecialization.physical: 'physical',
  ScoutSpecialization.mental: 'mental',
  ScoutSpecialization.goalkeeping: 'goalkeeping',
  ScoutSpecialization.pace: 'pace',
  ScoutSpecialization.leadership: 'leadership',
};

const _$ScoutRegionEnumMap = {
  ScoutRegion.domestic: 'domestic',
  ScoutRegion.international: 'international',
  ScoutRegion.europe: 'europe',
  ScoutRegion.southAmerica: 'southAmerica',
  ScoutRegion.africa: 'africa',
  ScoutRegion.asia: 'asia',
};

YouthAcademy _$YouthAcademyFromJson(Map<String, dynamic> json) => YouthAcademy(
  id: json['id'] as String,
  name: json['name'] as String,
  facilities: (json['facilities'] as num?)?.toInt(),
  coachingStaff: (json['coachingStaff'] as num?)?.toInt(),
  reputation: (json['reputation'] as num?)?.toInt(),
  capacity: (json['capacity'] as num?)?.toInt(),
  yearlyBudget: (json['yearlyBudget'] as num?)?.toInt(),
  focusAreas: (json['focusAreas'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$TrainingFocusEnumMap, e))
      .toList(),
  youthPlayers: (json['youthPlayers'] as List<dynamic>?)
      ?.map((e) => YouthPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  scouts: (json['scouts'] as List<dynamic>?)
      ?.map((e) => Scout.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$YouthAcademyToJson(YouthAcademy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'facilities': instance.facilities,
      'coachingStaff': instance.coachingStaff,
      'reputation': instance.reputation,
      'capacity': instance.capacity,
      'yearlyBudget': instance.yearlyBudget,
      'focusAreas': instance.focusAreas
          .map((e) => _$TrainingFocusEnumMap[e]!)
          .toList(),
      'youthPlayers': instance.youthPlayers.map((e) => e.toJson()).toList(),
      'scouts': instance.scouts.map((e) => e.toJson()).toList(),
    };

const _$TrainingFocusEnumMap = {
  TrainingFocus.technical: 'technical',
  TrainingFocus.physical: 'physical',
  TrainingFocus.mental: 'mental',
  TrainingFocus.tactical: 'tactical',
  TrainingFocus.goalkeeping: 'goalkeeping',
};
