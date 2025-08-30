import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'player.dart';

part 'team.g.dart';

/// Represents football formations
@JsonEnum()
enum Formation {
  f442, // 4-4-2
  f433, // 4-3-3
  f352, // 3-5-2
  f541, // 5-4-1
  f343, // 3-4-3
  f532, // 5-3-2
  f4231, // 4-2-3-1
  f4141, // 4-1-4-1
  f451, // 4-5-1
  f3421; // 3-4-2-1

  /// Get formation requirements (GK, DEF, MID, FWD)
  List<int> get requirements {
    switch (this) {
      case Formation.f442:
        return [1, 4, 4, 2]; // 1 GK, 4 DEF, 4 MID, 2 FWD
      case Formation.f433:
        return [1, 4, 3, 3];
      case Formation.f352:
        return [1, 3, 5, 2];
      case Formation.f541:
        return [1, 5, 4, 1];
      case Formation.f343:
        return [1, 3, 4, 3];
      case Formation.f532:
        return [1, 5, 3, 2];
      case Formation.f4231:
        return [1, 4, 5, 1]; // 2 DM + 3 AM = 5 MID
      case Formation.f4141:
        return [1, 4, 5, 1]; // 1 DM + 4 MID = 5 MID
      case Formation.f451:
        return [1, 4, 5, 1];
      case Formation.f3421:
        return [1, 3, 6, 1]; // 4 MID + 2 AM = 6 MID
    }
  }

  /// Display name for the formation
  String get displayName {
    switch (this) {
      case Formation.f442:
        return '4-4-2';
      case Formation.f433:
        return '4-3-3';
      case Formation.f352:
        return '3-5-2';
      case Formation.f541:
        return '5-4-1';
      case Formation.f343:
        return '3-4-3';
      case Formation.f532:
        return '5-3-2';
      case Formation.f4231:
        return '4-2-3-1';
      case Formation.f4141:
        return '4-1-4-1';
      case Formation.f451:
        return '4-5-1';
      case Formation.f3421:
        return '3-4-2-1';
    }
  }
}

/// Represents a football stadium
@JsonSerializable()
class Stadium extends Equatable {
  /// Stadium name
  final String name;

  /// Stadium capacity
  final int capacity;

  /// Stadium city
  final String city;

  const Stadium({
    required this.name,
    required this.capacity,
    required this.city,
  });

  /// Creates a stadium from JSON data
  factory Stadium.fromJson(Map<String, dynamic> json) => _$StadiumFromJson(json);

  /// Converts the stadium to JSON data
  Map<String, dynamic> toJson() => _$StadiumToJson(this);

  @override
  List<Object?> get props => [name, capacity, city];

  @override
  String toString() => 'Stadium(name: $name, capacity: $capacity, city: $city)';
}

/// Represents a football team with players, formation, and management
@JsonSerializable(explicitToJson: true)
class Team extends Equatable {
  /// Unique identifier for the team
  final String id;

  /// Team name
  final String name;

  /// Team city
  final String city;

  /// Year the team was founded
  final int foundedYear;

  /// Team's home stadium
  final Stadium stadium;

  /// List of players in the squad
  final List<Player> players;

  /// Current formation
  final Formation formation;

  /// Current starting XI
  final List<Player> startingXI;

  /// Team morale (0-100)
  final int morale;

  /// Maximum squad size
  static const int maxSquadSize = 30;

  /// Minimum squad size for competitive play
  static const int minSquadSize = 16;

  /// Creates a new team instance
  Team({
    required this.id,
    required this.name,
    required this.city,
    required this.foundedYear,
    Stadium? stadium,
    List<Player>? players,
    Formation? formation,
    List<Player>? startingXI,
    int? morale,
  })  : stadium = stadium ?? Stadium(
          name: '$name Stadium',
          capacity: 40000,
          city: city,
        ),
        players = players ?? [],
        formation = formation ?? Formation.f442,
        startingXI = startingXI ?? [],
        morale = morale ?? 75 {
    // Validation
    if (id.isEmpty) throw ArgumentError('Team ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Team name cannot be empty');
    if (city.isEmpty) throw ArgumentError('Team city cannot be empty');
    if (foundedYear < 1850 || foundedYear > DateTime.now().year) {
      throw ArgumentError('Founded year must be between 1850 and ${DateTime.now().year}');
    }
    if (this.players.length > maxSquadSize) {
      throw ArgumentError('Squad size cannot exceed $maxSquadSize players');
    }
    if (this.morale < 0 || this.morale > 100) {
      throw ArgumentError('Morale must be between 0 and 100');
    }
    
    // Validate starting XI
    if (this.startingXI.isNotEmpty) {
      _validateStartingXI(this.startingXI, this.players);
    }
  }

  /// Creates a team from JSON data
  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  /// Converts the team to JSON data
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  /// Validates starting XI
  void _validateStartingXI(List<Player> xi, List<Player> squad) {
    if (xi.length != 11) {
      throw ArgumentError('Starting XI must contain exactly 11 players');
    }
    
    for (final player in xi) {
      if (!squad.any((p) => p.id == player.id)) {
        throw ArgumentError('Starting XI contains player not in squad: ${player.name}');
      }
    }
    
    // Check for duplicates
    final playerIds = xi.map((p) => p.id).toSet();
    if (playerIds.length != 11) {
      throw ArgumentError('Starting XI cannot contain duplicate players');
    }
  }

  /// Adds a player to the squad
  Team addPlayer(Player player) {
    if (players.any((p) => p.id == player.id)) {
      throw ArgumentError('Player ${player.name} is already in the squad');
    }
    
    if (players.length >= maxSquadSize) {
      throw ArgumentError('Cannot add player: squad is at maximum capacity ($maxSquadSize)');
    }
    
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: foundedYear,
      stadium: stadium,
      players: [...players, player],
      formation: formation,
      startingXI: startingXI,
      morale: morale,
    );
  }

  /// Removes a player from the squad
  Team removePlayer(String playerId) {
    final updatedPlayers = players.where((p) => p.id != playerId).toList();
    final updatedStartingXI = startingXI.where((p) => p.id != playerId).toList();
    
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: foundedYear,
      stadium: stadium,
      players: updatedPlayers,
      formation: formation,
      startingXI: updatedStartingXI,
      morale: morale,
    );
  }

  /// Sets the team formation
  Team setFormation(Formation newFormation) {
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: foundedYear,
      stadium: stadium,
      players: players,
      formation: newFormation,
      startingXI: startingXI,
      morale: morale,
    );
  }

  /// Sets the starting XI
  Team setStartingXI(List<Player> newStartingXI) {
    _validateStartingXI(newStartingXI, players);
    
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: foundedYear,
      stadium: stadium,
      players: players,
      formation: formation,
      startingXI: newStartingXI,
      morale: morale,
    );
  }

  /// Updates team morale
  Team updateMorale(int newMorale) {
    final clampedMorale = newMorale.clamp(0, 100);
    
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: foundedYear,
      stadium: stadium,
      players: players,
      formation: formation,
      startingXI: startingXI,
      morale: clampedMorale,
    );
  }

  /// Creates a copy of the team with updated values
  Team copyWith({
    String? id,
    String? name,
    String? city,
    int? foundedYear,
    Stadium? stadium,
    List<Player>? players,
    Formation? formation,
    List<Player>? startingXI,
    int? morale,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      foundedYear: foundedYear ?? this.foundedYear,
      stadium: stadium ?? this.stadium,
      players: players ?? this.players,
      formation: formation ?? this.formation,
      startingXI: startingXI ?? this.startingXI,
      morale: morale ?? this.morale,
    );
  }

  /// Calculates overall team rating based on all players
  int get overallRating {
    if (players.isEmpty) return 0;
    
    final totalRating = players.map((p) => p.overallRating).reduce((a, b) => a + b);
    return (totalRating / players.length).round();
  }

  /// Calculates position-specific team strengths
  Map<PlayerPosition, int> get positionStrengths {
    final strengths = <PlayerPosition, int>{};
    
    for (final position in PlayerPosition.values) {
      final positionPlayers = players.where((p) => p.position == position).toList();
      if (positionPlayers.isNotEmpty) {
        final totalRating = positionPlayers
            .map((p) => p.positionOverallRating)
            .reduce((a, b) => a + b);
        strengths[position] = (totalRating / positionPlayers.length).round();
      } else {
        strengths[position] = 0;
      }
    }
    
    return strengths;
  }

  /// Calculates team chemistry based on various factors
  int get chemistry {
    if (players.isEmpty) return 50;
    
    // Base chemistry from morale
    int chemistryScore = morale;
    
    // Bonus for balanced squad
    final positionCounts = <PlayerPosition, int>{};
    for (final player in players) {
      positionCounts[player.position] = (positionCounts[player.position] ?? 0) + 1;
    }
    
    // Ideal distribution: 2-3 GK, 6-8 DEF, 6-8 MID, 4-6 FWD
    final gkCount = positionCounts[PlayerPosition.goalkeeper] ?? 0;
    final defCount = positionCounts[PlayerPosition.defender] ?? 0;
    final midCount = positionCounts[PlayerPosition.midfielder] ?? 0;
    final fwdCount = positionCounts[PlayerPosition.forward] ?? 0;
    
    // Calculate balance bonus (max 20 points)
    int balanceBonus = 0;
    if (gkCount >= 2 && gkCount <= 3) balanceBonus += 5;
    if (defCount >= 6 && defCount <= 8) balanceBonus += 5;
    if (midCount >= 6 && midCount <= 8) balanceBonus += 5;
    if (fwdCount >= 4 && fwdCount <= 6) balanceBonus += 5;
    
    chemistryScore = ((chemistryScore + balanceBonus) * 0.8).round();
    
    // Squad size bonus/penalty
    if (players.length >= minSquadSize && players.length <= 25) {
      chemistryScore += 5;
    } else if (players.length < minSquadSize) {
      chemistryScore -= 15;
    }
    
    return chemistryScore.clamp(0, 100);
  }

  /// Gets players by position
  List<Player> getPlayersByPosition(PlayerPosition position) {
    return players.where((p) => p.position == position).toList();
  }

  /// Checks if team has minimum players for competitive play
  bool get isCompetitive => players.length >= minSquadSize;

  /// Gets squad depth analysis
  Map<String, dynamic> get squadAnalysis {
    final positionCounts = <PlayerPosition, int>{};
    final positionAverages = <PlayerPosition, double>{};
    
    for (final position in PlayerPosition.values) {
      final positionPlayers = getPlayersByPosition(position);
      positionCounts[position] = positionPlayers.length;
      
      if (positionPlayers.isNotEmpty) {
        final avgRating = positionPlayers
            .map((p) => p.positionOverallRating)
            .reduce((a, b) => a + b) / positionPlayers.length;
        positionAverages[position] = avgRating;
      } else {
        positionAverages[position] = 0.0;
      }
    }
    
    return {
      'totalPlayers': players.length,
      'positionCounts': positionCounts,
      'positionAverages': positionAverages,
      'overallRating': overallRating,
      'chemistry': chemistry,
      'isCompetitive': isCompetitive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        foundedYear,
        stadium,
        players,
        formation,
        startingXI,
        morale,
      ];

  @override
  String toString() {
    return 'Team(id: $id, name: $name, city: $city, players: ${players.length}, '
        'formation: ${formation.displayName}, overall: $overallRating, morale: $morale)';
  }
}
