// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gameweek.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gameweek _$GameweekFromJson(Map<String, dynamic> json) => Gameweek(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  seasonId: json['seasonId'] as String,
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
  matches: (json['matches'] as List<dynamic>?)
      ?.map((e) => Match.fromJson(e as Map<String, dynamic>))
      .toList(),
  status:
      $enumDecodeNullable(_$GameweekStatusEnumMap, json['status']) ??
      GameweekStatus.scheduled,
  name: json['name'] as String?,
  isSpecial: json['isSpecial'] as bool? ?? false,
);

Map<String, dynamic> _$GameweekToJson(Gameweek instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'seasonId': instance.seasonId,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'matches': instance.matches.map((e) => e.toJson()).toList(),
  'status': _$GameweekStatusEnumMap[instance.status]!,
  'name': instance.name,
  'isSpecial': instance.isSpecial,
};

const _$GameweekStatusEnumMap = {
  GameweekStatus.scheduled: 'scheduled',
  GameweekStatus.inProgress: 'inProgress',
  GameweekStatus.completed: 'completed',
  GameweekStatus.postponed: 'postponed',
  GameweekStatus.cancelled: 'cancelled',
};
