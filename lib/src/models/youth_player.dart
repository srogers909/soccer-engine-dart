import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:soccer_utilities/src/models/player.dart';

part 'youth_player.g.dart';

/// Represents specialties that youth players can develop
@JsonEnum()
enum YouthSpecialty {
  pace,
  technical,
  physical,
  mental,
  leadership,
  finishing,
  crossing,
  defending,
  goalkeeping;
}

/// Represents a youth academy player with development potential
@JsonSerializable()
class YouthPlayer extends Equatable {
  /// Unique identifier for the player
  final String id;

  /// Player's full name
  final String name;

  /// Player's age in years (14-18 for youth academy)
  final int age;

  /// Player's primary position
  final PlayerPosition position;

  /// Technical skill rating (1-100)
  final int technical;

  /// Physical attributes rating (1-100)
  final int physical;

  /// Mental attributes rating (1-100)
  final int mental;

  /// Current form rating (1-10)
  final int form;

  /// Current fitness percentage (0-100)
  final int fitness;

  /// Maximum potential rating the player can reach (1-100)
  final int potential;

  /// How quickly the player develops (1-10)
  final int developmentRate;

  /// Date when the player joined the academy
  final DateTime academyJoinDate;

  /// Whether the player is eligible for graduation to senior team
  final bool graduationEligible;

  /// List of specialties the player excels at
  final List<YouthSpecialty> specialties;

  /// Mental maturity level (1-100) - affects consistency and decision-making
  final int mentalMaturity;

  /// Creates a new youth player instance
  ///
  /// [id] and [name] cannot be empty
  /// [age] must be between 14 and 18 (youth academy range)
  /// [technical], [physical], [mental] must be between 1 and 100
  /// [form] must be between 1 and 10
  /// [fitness] must be between 0 and 100
  /// [potential] must be between 1 and 100, and >= current overall rating
  /// [developmentRate] must be between 1 and 10
  /// [mentalMaturity] must be between 1 and 100
  YouthPlayer({
    required this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.potential,
    required this.developmentRate,
    required this.academyJoinDate,
    int? technical,
    int? physical,
    int? mental,
    int? form,
    int? fitness,
    bool? graduationEligible,
    List<YouthSpecialty>? specialties,
    int? mentalMaturity,
  })  : technical = technical ?? 30, // Lower defaults for youth
        physical = physical ?? 30,
        mental = mental ?? 30,
        form = form ?? 7,
        fitness = fitness ?? 100,
        graduationEligible = graduationEligible ?? false,
        specialties = specialties ?? [],
        mentalMaturity = mentalMaturity ?? 50 {
    // Validation
    if (id.isEmpty) throw ArgumentError('Player ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Player name cannot be empty');
    if (age < 14 || age > 18) throw ArgumentError('Youth player age must be between 14 and 18');
    
    final techValue = technical ?? 30;
    final physValue = physical ?? 30;
    final mentalValue = mental ?? 30;
    final formValue = form ?? 7;
    final fitnessValue = fitness ?? 100;
    final maturityValue = mentalMaturity ?? 50;
    
    if (techValue < 1 || techValue > 100) throw ArgumentError('Technical rating must be between 1 and 100');
    if (physValue < 1 || physValue > 100) throw ArgumentError('Physical rating must be between 1 and 100');
    if (mentalValue < 1 || mentalValue > 100) throw ArgumentError('Mental rating must be between 1 and 100');
    if (formValue < 1 || formValue > 10) throw ArgumentError('Form rating must be between 1 and 10');
    if (fitnessValue < 0 || fitnessValue > 100) throw ArgumentError('Fitness must be between 0 and 100');
    if (potential < 1 || potential > 100) throw ArgumentError('Potential must be between 1 and 100');
    if (developmentRate < 1 || developmentRate > 10) throw ArgumentError('Development rate must be between 1 and 10');
    if (maturityValue < 1 || maturityValue > 100) throw ArgumentError('Mental maturity must be between 1 and 100');
    
    // Potential must be >= current overall rating
    final currentOverall = ((techValue + physValue + mentalValue) / 3).round();
    if (potential < currentOverall) {
      throw ArgumentError('Potential ($potential) must be greater than or equal to current overall rating ($currentOverall)');
    }
  }

  /// Creates a youth player from JSON data
  factory YouthPlayer.fromJson(Map<String, dynamic> json) => _$YouthPlayerFromJson(json);

  /// Converts the youth player to JSON data
  Map<String, dynamic> toJson() => _$YouthPlayerToJson(this);

  /// Calculates the overall rating as simple average of all attributes
  int get overallRating => ((technical + physical + mental) / 3).round();

  /// Calculates position-specific overall rating with weighted attributes
  int get positionOverallRating {
    switch (position) {
      case PlayerPosition.goalkeeper:
        // Goalkeepers: Mental (50%), Physical (30%), Technical (20%)
        return (mental * 0.5 + physical * 0.3 + technical * 0.2).round();
      case PlayerPosition.defender:
        // Defenders: Physical (40%), Mental (35%), Technical (25%)
        return (physical * 0.4 + mental * 0.35 + technical * 0.25).round();
      case PlayerPosition.midfielder:
        // Midfielders: Technical (40%), Mental (35%), Physical (25%)
        return (technical * 0.4 + mental * 0.35 + physical * 0.25).round();
      case PlayerPosition.forward:
        // Forwards: Technical (45%), Physical (30%), Mental (25%)
        return (technical * 0.45 + physical * 0.3 + mental * 0.25).round();
    }
  }

  /// Develops the player's attributes with specified gains
  YouthPlayer developPlayer({
    int technicalGain = 0,
    int physicalGain = 0,
    int mentalGain = 0,
  }) {
    // Calculate potential caps for each attribute (simple approach: equal distribution)
    final potentialPerAttribute = potential;
    
    final newTechnical = (technical + technicalGain).clamp(1, potentialPerAttribute);
    final newPhysical = (physical + physicalGain).clamp(1, potentialPerAttribute);
    final newMental = (mental + mentalGain).clamp(1, potentialPerAttribute);

    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: newTechnical,
      physical: newPhysical,
      mental: newMental,
      form: form,
      fitness: fitness,
      graduationEligible: graduationEligible,
      specialties: specialties,
      mentalMaturity: mentalMaturity,
    );
  }

  /// Updates the graduation eligibility status
  YouthPlayer updateGraduationEligibility(bool eligible) {
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: fitness,
      graduationEligible: eligible,
      specialties: specialties,
      mentalMaturity: mentalMaturity,
    );
  }

  /// Updates the mental maturity level
  YouthPlayer updateMentalMaturity(int newMaturity) {
    final clampedMaturity = newMaturity.clamp(1, 100);
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: fitness,
      graduationEligible: graduationEligible,
      specialties: specialties,
      mentalMaturity: clampedMaturity,
    );
  }

  /// Converts the youth player to a senior player
  Player toSeniorPlayer() {
    return Player(
      id: id,
      name: name,
      age: age,
      position: position,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: fitness,
    );
  }

  /// Adds a specialty to the player
  YouthPlayer addSpecialty(YouthSpecialty specialty) {
    if (specialties.contains(specialty)) {
      return this; // Already has this specialty
    }
    
    final newSpecialties = [...specialties, specialty];
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: fitness,
      graduationEligible: graduationEligible,
      specialties: newSpecialties,
      mentalMaturity: mentalMaturity,
    );
  }

  /// Removes a specialty from the player
  YouthPlayer removeSpecialty(YouthSpecialty specialty) {
    final newSpecialties = specialties.where((s) => s != specialty).toList();
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: fitness,
      graduationEligible: graduationEligible,
      specialties: newSpecialties,
      mentalMaturity: mentalMaturity,
    );
  }

  /// Calculates time spent in academy
  Duration timeInAcademy(DateTime currentDate) {
    return currentDate.difference(academyJoinDate);
  }

  /// Creates a copy of this youth player with updated form
  YouthPlayer updateForm(int newForm) {
    final clampedForm = newForm.clamp(1, 10);
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: clampedForm,
      fitness: fitness,
      graduationEligible: graduationEligible,
      specialties: specialties,
      mentalMaturity: mentalMaturity,
    );
  }

  /// Creates a copy of this youth player with updated fitness
  YouthPlayer updateFitness(int newFitness) {
    final clampedFitness = newFitness.clamp(0, 100);
    return YouthPlayer(
      id: id,
      name: name,
      age: age,
      position: position,
      potential: potential,
      developmentRate: developmentRate,
      academyJoinDate: academyJoinDate,
      technical: technical,
      physical: physical,
      mental: mental,
      form: form,
      fitness: clampedFitness,
      graduationEligible: graduationEligible,
      specialties: specialties,
      mentalMaturity: mentalMaturity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        position,
        technical,
        physical,
        mental,
        form,
        fitness,
        potential,
        developmentRate,
        academyJoinDate,
        graduationEligible,
        specialties,
        mentalMaturity,
      ];

  @override
  String toString() {
    return 'YouthPlayer(id: $id, name: $name, age: $age, position: ${position.name}, '
        'overall: $overallRating, potential: $potential, developmentRate: $developmentRate, '
        'graduationEligible: $graduationEligible)';
  }
}
