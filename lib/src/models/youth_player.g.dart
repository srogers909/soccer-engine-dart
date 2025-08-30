// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youth_player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YouthPlayer _$YouthPlayerFromJson(Map<String, dynamic> json) => YouthPlayer(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  position: $enumDecode(_$PlayerPositionEnumMap, json['position']),
  potential: (json['potential'] as num).toInt(),
  developmentRate: (json['developmentRate'] as num).toInt(),
  academyJoinDate: DateTime.parse(json['academyJoinDate'] as String),
  technical: (json['technical'] as num?)?.toInt(),
  physical: (json['physical'] as num?)?.toInt(),
  mental: (json['mental'] as num?)?.toInt(),
  form: (json['form'] as num?)?.toInt(),
  fitness: (json['fitness'] as num?)?.toInt(),
  graduationEligible: json['graduationEligible'] as bool?,
  specialties: (json['specialties'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$YouthSpecialtyEnumMap, e))
      .toList(),
  mentalMaturity: (json['mentalMaturity'] as num?)?.toInt(),
);

Map<String, dynamic> _$YouthPlayerToJson(YouthPlayer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'position': _$PlayerPositionEnumMap[instance.position]!,
      'technical': instance.technical,
      'physical': instance.physical,
      'mental': instance.mental,
      'form': instance.form,
      'fitness': instance.fitness,
      'potential': instance.potential,
      'developmentRate': instance.developmentRate,
      'academyJoinDate': instance.academyJoinDate.toIso8601String(),
      'graduationEligible': instance.graduationEligible,
      'specialties': instance.specialties
          .map((e) => _$YouthSpecialtyEnumMap[e]!)
          .toList(),
      'mentalMaturity': instance.mentalMaturity,
    };

const _$PlayerPositionEnumMap = {
  PlayerPosition.goalkeeper: 'goalkeeper',
  PlayerPosition.defender: 'defender',
  PlayerPosition.midfielder: 'midfielder',
  PlayerPosition.forward: 'forward',
};

const _$YouthSpecialtyEnumMap = {
  YouthSpecialty.pace: 'pace',
  YouthSpecialty.technical: 'technical',
  YouthSpecialty.physical: 'physical',
  YouthSpecialty.mental: 'mental',
  YouthSpecialty.leadership: 'leadership',
  YouthSpecialty.finishing: 'finishing',
  YouthSpecialty.crossing: 'crossing',
  YouthSpecialty.defending: 'defending',
  YouthSpecialty.goalkeeping: 'goalkeeping',
};
