// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueRules _$LeagueRulesFromJson(Map<String, dynamic> json) => LeagueRules(
  promotionSpots: (json['promotionSpots'] as num?)?.toInt() ?? 2,
  relegationSpots: (json['relegationSpots'] as num?)?.toInt() ?? 3,
  playoffSpots: (json['playoffSpots'] as num?)?.toInt() ?? 4,
  pointsForWin: (json['pointsForWin'] as num?)?.toInt() ?? 3,
  pointsForDraw: (json['pointsForDraw'] as num?)?.toInt() ?? 1,
  pointsForLoss: (json['pointsForLoss'] as num?)?.toInt() ?? 0,
  useGoalDifference: json['useGoalDifference'] as bool? ?? true,
  useHeadToHead: json['useHeadToHead'] as bool? ?? false,
);

Map<String, dynamic> _$LeagueRulesToJson(LeagueRules instance) =>
    <String, dynamic>{
      'promotionSpots': instance.promotionSpots,
      'relegationSpots': instance.relegationSpots,
      'playoffSpots': instance.playoffSpots,
      'pointsForWin': instance.pointsForWin,
      'pointsForDraw': instance.pointsForDraw,
      'pointsForLoss': instance.pointsForLoss,
      'useGoalDifference': instance.useGoalDifference,
      'useHeadToHead': instance.useHeadToHead,
    };

League _$LeagueFromJson(Map<String, dynamic> json) => League(
  id: json['id'] as String,
  name: json['name'] as String,
  country: json['country'] as String,
  tier:
      $enumDecodeNullable(_$LeagueTierEnumMap, json['tier']) ??
      LeagueTier.tier1,
  format:
      $enumDecodeNullable(_$LeagueFormatEnumMap, json['format']) ??
      LeagueFormat.roundRobin,
  teams: (json['teams'] as List<dynamic>?)
      ?.map((e) => Team.fromJson(e as Map<String, dynamic>))
      .toList(),
  rules: json['rules'] == null
      ? null
      : LeagueRules.fromJson(json['rules'] as Map<String, dynamic>),
  foundedYear: (json['foundedYear'] as num?)?.toInt(),
  maxTeams: (json['maxTeams'] as num?)?.toInt() ?? 20,
  minTeams: (json['minTeams'] as num?)?.toInt() ?? 8,
);

Map<String, dynamic> _$LeagueToJson(League instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'country': instance.country,
  'tier': _$LeagueTierEnumMap[instance.tier]!,
  'format': _$LeagueFormatEnumMap[instance.format]!,
  'teams': instance.teams.map((e) => e.toJson()).toList(),
  'rules': instance.rules.toJson(),
  'foundedYear': instance.foundedYear,
  'maxTeams': instance.maxTeams,
  'minTeams': instance.minTeams,
};

const _$LeagueTierEnumMap = {
  LeagueTier.tier1: 'tier1',
  LeagueTier.tier2: 'tier2',
  LeagueTier.tier3: 'tier3',
  LeagueTier.tier4: 'tier4',
  LeagueTier.tier5Plus: 'tier5Plus',
};

const _$LeagueFormatEnumMap = {
  LeagueFormat.roundRobin: 'roundRobin',
  LeagueFormat.singleRoundRobin: 'singleRoundRobin',
  LeagueFormat.playoff: 'playoff',
  LeagueFormat.groupAndKnockout: 'groupAndKnockout',
};
