import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'youth_player.dart';
import 'player.dart';

part 'youth_academy.g.dart';

/// Represents training focus areas for youth development
@JsonEnum()
enum TrainingFocus {
  technical,
  physical,
  mental,
  tactical,
  goalkeeping;
}

/// Represents scout specializations
@JsonEnum()
enum ScoutSpecialization {
  technical,
  physical,
  mental,
  goalkeeping,
  pace,
  leadership;
}

/// Represents scout regions
@JsonEnum()
enum ScoutRegion {
  domestic,
  international,
  europe,
  southAmerica,
  africa,
  asia;
}

/// Represents a scout for discovering youth talent
@JsonSerializable()
class Scout extends Equatable {
  /// Unique identifier for the scout
  final String id;

  /// Scout's name
  final String name;

  /// Scouting ability rating (1-100)
  final int ability;

  /// Network quality for finding prospects (1-100)
  final int networkQuality;

  /// Scout's specialization area
  final ScoutSpecialization specialization;

  /// Scout's operating region
  final ScoutRegion region;

  /// Annual cost to employ this scout
  final int cost;

  /// Creates a new scout instance
  Scout({
    required this.id,
    required this.name,
    required this.ability,
    required this.networkQuality,
    required this.specialization,
    required this.region,
    required this.cost,
  }) {
    if (id.isEmpty) throw ArgumentError('Scout ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Scout name cannot be empty');
    if (ability < 1 || ability > 100) throw ArgumentError('Scout ability must be between 1 and 100');
    if (networkQuality < 1 || networkQuality > 100) throw ArgumentError('Network quality must be between 1 and 100');
    if (cost < 0) throw ArgumentError('Scout cost cannot be negative');
  }

  /// Creates a scout from JSON data
  factory Scout.fromJson(Map<String, dynamic> json) => _$ScoutFromJson(json);

  /// Converts the scout to JSON data
  Map<String, dynamic> toJson() => _$ScoutToJson(this);

  /// Calculates overall effectiveness of this scout
  double get effectiveness {
    return (ability + networkQuality) / 200.0; // 0.0 to 1.0
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ability,
        networkQuality,
        specialization,
        region,
        cost,
      ];

  @override
  String toString() {
    return 'Scout(id: $id, name: $name, ability: $ability, '
        'specialization: ${specialization.name}, region: ${region.name}, cost: $cost)';
  }
}

/// Represents a youth academy with facilities, staff, and players
@JsonSerializable(explicitToJson: true)
class YouthAcademy extends Equatable {
  /// Unique identifier for the academy
  final String id;

  /// Academy name
  final String name;

  /// Quality of training facilities (1-100)
  final int facilities;

  /// Quality of coaching staff (1-100)
  final int coachingStaff;

  /// Academy reputation (1-100) - affects player attraction
  final int reputation;

  /// Maximum number of youth players
  final int capacity;

  /// Annual budget for academy operations
  final int yearlyBudget;

  /// Training focus areas
  final List<TrainingFocus> focusAreas;

  /// List of youth players in the academy
  final List<YouthPlayer> youthPlayers;

  /// List of scouts employed by the academy
  final List<Scout> scouts;

  /// Creates a new youth academy instance
  YouthAcademy({
    required this.id,
    required this.name,
    int? facilities,
    int? coachingStaff,
    int? reputation,
    int? capacity,
    int? yearlyBudget,
    List<TrainingFocus>? focusAreas,
    List<YouthPlayer>? youthPlayers,
    List<Scout>? scouts,
  })  : facilities = facilities ?? 50,
        coachingStaff = coachingStaff ?? 50,
        reputation = reputation ?? 50,
        capacity = capacity ?? 30,
        yearlyBudget = yearlyBudget ?? 500000,
        focusAreas = focusAreas ?? [],
        youthPlayers = youthPlayers ?? [],
        scouts = scouts ?? [] {
    // Validation
    if (id.isEmpty) throw ArgumentError('Academy ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Academy name cannot be empty');
    
    final facilityValue = facilities ?? 50;
    final coachingValue = coachingStaff ?? 50;
    final reputationValue = reputation ?? 50;
    final capacityValue = capacity ?? 30;
    final budgetValue = yearlyBudget ?? 500000;
    
    if (facilityValue < 1 || facilityValue > 100) throw ArgumentError('Facilities rating must be between 1 and 100');
    if (coachingValue < 1 || coachingValue > 100) throw ArgumentError('Coaching staff rating must be between 1 and 100');
    if (reputationValue < 1 || reputationValue > 100) throw ArgumentError('Reputation must be between 1 and 100');
    if (capacityValue < 1 || capacityValue > 100) throw ArgumentError('Capacity must be between 1 and 100');
    if (budgetValue < 0) throw ArgumentError('Yearly budget cannot be negative');
  }

  /// Creates a youth academy from JSON data
  factory YouthAcademy.fromJson(Map<String, dynamic> json) => _$YouthAcademyFromJson(json);

  /// Converts the youth academy to JSON data
  Map<String, dynamic> toJson() => _$YouthAcademyToJson(this);

  /// Current number of youth players in academy
  int get currentCapacity => youthPlayers.length;

  /// Calculates overall academy quality
  int get overallQuality => ((facilities + coachingStaff + reputation) / 3).round();

  /// Calculates development effectiveness multiplier (0.5 to 2.0)
  double get developmentEffectiveness {
    final facilityFactor = facilities / 100.0;
    final coachingFactor = coachingStaff / 100.0;
    final baseFactor = (facilityFactor + coachingFactor) / 2.0;
    
    // Apply focus area bonuses
    double focusBonus = 1.0;
    if (focusAreas.isNotEmpty) {
      focusBonus += (focusAreas.length * 0.1); // 10% bonus per focus area
    }
    
    return (baseFactor * focusBonus).clamp(0.5, 2.0);
  }

  /// Calculates scouting effectiveness multiplier (0.5 to 2.0)
  double get scoutingEffectiveness {
    if (scouts.isEmpty) return 0.5;
    
    final avgScoutEffectiveness = scouts.map((s) => s.effectiveness).reduce((a, b) => a + b) / scouts.length;
    final reputationFactor = reputation / 100.0;
    
    return ((avgScoutEffectiveness + reputationFactor) / 2.0).clamp(0.5, 2.0);
  }

  /// Total annual cost for all scouts
  int get totalScoutCosts => scouts.map((s) => s.cost).fold(0, (sum, cost) => sum + cost);

  /// Adds a youth player to the academy
  YouthAcademy addYouthPlayer(YouthPlayer player) {
    if (youthPlayers.any((p) => p.id == player.id)) {
      throw ArgumentError('Youth player ${player.name} is already in the academy');
    }
    
    if (currentCapacity >= capacity) {
      throw ArgumentError('Cannot add youth player: academy is at maximum capacity ($capacity)');
    }
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: focusAreas,
      youthPlayers: [...youthPlayers, player],
      scouts: scouts,
    );
  }

  /// Removes a youth player from the academy
  YouthAcademy removeYouthPlayer(String playerId) {
    final updatedPlayers = youthPlayers.where((p) => p.id != playerId).toList();
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: focusAreas,
      youthPlayers: updatedPlayers,
      scouts: scouts,
    );
  }

  /// Gets youth players by position
  List<YouthPlayer> getYouthPlayersByPosition(PlayerPosition position) {
    return youthPlayers.where((p) => p.position == position).toList();
  }

  /// Adds a scout to the academy
  YouthAcademy addScout(Scout scout) {
    if (scouts.any((s) => s.id == scout.id)) {
      throw ArgumentError('Scout ${scout.name} is already employed by the academy');
    }
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: focusAreas,
      youthPlayers: youthPlayers,
      scouts: [...scouts, scout],
    );
  }

  /// Removes a scout from the academy
  YouthAcademy removeScout(String scoutId) {
    final updatedScouts = scouts.where((s) => s.id != scoutId).toList();
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: focusAreas,
      youthPlayers: youthPlayers,
      scouts: updatedScouts,
    );
  }

  /// Adds a training focus area
  YouthAcademy addFocusArea(TrainingFocus focus) {
    if (focusAreas.contains(focus)) {
      return this; // Already has this focus
    }
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: [...focusAreas, focus],
      youthPlayers: youthPlayers,
      scouts: scouts,
    );
  }

  /// Removes a training focus area
  YouthAcademy removeFocusArea(TrainingFocus focus) {
    final updatedFocusAreas = focusAreas.where((f) => f != focus).toList();
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: facilities,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: updatedFocusAreas,
      youthPlayers: youthPlayers,
      scouts: scouts,
    );
  }

  /// Calculates total operational costs for the academy
  int calculateOperationalCosts() {
    // Base facility maintenance costs (higher quality = higher costs)
    final facilityCosts = (facilities * 1000).round();
    
    // Youth player base costs (salary, equipment, etc.)
    final youthPlayerCosts = youthPlayers.length * 5000;
    
    // Coaching staff costs
    final coachingCosts = (coachingStaff * 800).round();
    
    // Scout costs
    final scoutCosts = totalScoutCosts;
    
    return facilityCosts + youthPlayerCosts + coachingCosts + scoutCosts;
  }

  /// Calculates cost to upgrade facilities to target level
  int calculateFacilityUpgradeCost(int targetLevel) {
    if (targetLevel <= facilities) {
      throw ArgumentError('Target facility level must be higher than current level');
    }
    
    final levelDifference = targetLevel - facilities;
    // Cost increases exponentially for higher levels
    return (levelDifference * levelDifference * 10000).round();
  }

  /// Upgrades facilities to target level
  YouthAcademy upgradeFacilities(int targetLevel) {
    if (targetLevel <= facilities) {
      throw ArgumentError('Cannot downgrade facilities');
    }
    
    return YouthAcademy(
      id: id,
      name: name,
      facilities: targetLevel,
      coachingStaff: coachingStaff,
      reputation: reputation,
      capacity: capacity,
      yearlyBudget: yearlyBudget,
      focusAreas: focusAreas,
      youthPlayers: youthPlayers,
      scouts: scouts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        facilities,
        coachingStaff,
        reputation,
        capacity,
        yearlyBudget,
        focusAreas,
        youthPlayers,
        scouts,
      ];

  @override
  String toString() {
    return 'YouthAcademy(id: $id, name: $name, facilities: $facilities, '
        'capacity: $currentCapacity/$capacity, quality: $overallQuality)';
  }
}
