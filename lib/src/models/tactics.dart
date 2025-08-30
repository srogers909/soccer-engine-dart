import 'package:json_annotation/json_annotation.dart';

part 'tactics.g.dart';

/// Represents different football formations
enum Formation {
  @JsonValue('4-4-2')
  f442,
  @JsonValue('4-3-3')
  f433,
  @JsonValue('3-5-2')
  f352,
  @JsonValue('5-3-2')
  f532,
  @JsonValue('4-5-1')
  f451,
  @JsonValue('4-2-3-1')
  f4231,
  @JsonValue('3-4-3')
  f343,
  @JsonValue('4-1-4-1')
  f4141,
}

/// Represents attacking mentality levels
enum AttackingMentality {
  @JsonValue('ultra-defensive')
  ultraDefensive,
  @JsonValue('defensive')
  defensive,
  @JsonValue('balanced')
  balanced,
  @JsonValue('attacking')
  attacking,
  @JsonValue('ultra-attacking')
  ultraAttacking,
}

/// Represents defensive styles
enum DefensiveStyle {
  @JsonValue('man-marking')
  manMarking,
  @JsonValue('zonal')
  zonal,
  @JsonValue('high-press')
  highPress,
  @JsonValue('low-block')
  lowBlock,
}

/// Represents attacking styles
enum AttackingStyle {
  @JsonValue('possession')
  possession,
  @JsonValue('counter-attack')
  counterAttack,
  @JsonValue('direct')
  direct,
  @JsonValue('wing-play')
  wingPlay,
}

/// Represents player positions on the field
enum PlayerPosition {
  @JsonValue('goalkeeper')
  goalkeeper,
  @JsonValue('centre-back')
  centreBack,
  @JsonValue('left-back')
  leftBack,
  @JsonValue('right-back')
  rightBack,
  @JsonValue('wing-back')
  wingBack,
  @JsonValue('defensive-midfielder')
  defensiveMidfielder,
  @JsonValue('centre-midfielder')
  centreMidfielder,
  @JsonValue('attacking-midfielder')
  attackingMidfielder,
  @JsonValue('left-winger')
  leftWinger,
  @JsonValue('right-winger')
  rightWinger,
  @JsonValue('striker')
  striker,
}

/// Represents tactical instructions for a team
@JsonSerializable()
class TacticalSetup {
  /// The formation being used
  final Formation formation;
  
  /// Attacking mentality (0-100 scale mapped from enum)
  final AttackingMentality attackingMentality;
  
  /// Defensive style
  final DefensiveStyle defensiveStyle;
  
  /// Attacking style
  final AttackingStyle attackingStyle;
  
  /// Width of play (1-100, where 100 is widest)
  final int width;
  
  /// Tempo of play (1-100, where 100 is fastest)
  final int tempo;
  
  /// Defensive line height (1-100, where 100 is highest)
  final int defensiveLine;
  
  /// Pressing intensity (1-100, where 100 is most intense)
  final int pressing;

  const TacticalSetup({
    required this.formation,
    required this.attackingMentality,
    required this.defensiveStyle,
    required this.attackingStyle,
    required this.width,
    required this.tempo,
    required this.defensiveLine,
    required this.pressing,
  });

  /// Validates tactical setup parameters
  bool get isValid {
    return width >= 1 && width <= 100 &&
           tempo >= 1 && tempo <= 100 &&
           defensiveLine >= 1 && defensiveLine <= 100 &&
           pressing >= 1 && pressing <= 100;
  }

  /// Gets the attacking mentality as a numerical value (1-5)
  int get attackingMentalityValue {
    switch (attackingMentality) {
      case AttackingMentality.ultraDefensive:
        return 1;
      case AttackingMentality.defensive:
        return 2;
      case AttackingMentality.balanced:
        return 3;
      case AttackingMentality.attacking:
        return 4;
      case AttackingMentality.ultraAttacking:
        return 5;
    }
  }

  /// Calculates overall tactical effectiveness (0.8 to 1.2 multiplier)
  double calculateTacticalEffectiveness({
    required int teamChemistry,
    required int managerRating,
  }) {
    if (!isValid) return 0.8;
    
    // Base effectiveness from balance of tactical attributes
    double balance = 1.0;
    
    // Penalize extreme imbalances
    if ((attackingMentalityValue >= 4 && defensiveLine < 30) ||
        (attackingMentalityValue <= 2 && pressing > 70)) {
      balance -= 0.1;
    }
    
    // Chemistry impact (0-100 -> 0.9-1.1 multiplier)
    double chemistryMultiplier = 0.9 + (teamChemistry / 100.0) * 0.2;
    
    // Manager rating impact (0-100 -> 0.95-1.05 multiplier)
    double managerMultiplier = 0.95 + (managerRating / 100.0) * 0.1;
    
    double effectiveness = balance * chemistryMultiplier * managerMultiplier;
    
    // Clamp between 0.8 and 1.2
    return effectiveness.clamp(0.8, 1.2);
  }

  /// Creates a copy with updated values
  TacticalSetup copyWith({
    Formation? formation,
    AttackingMentality? attackingMentality,
    DefensiveStyle? defensiveStyle,
    AttackingStyle? attackingStyle,
    int? width,
    int? tempo,
    int? defensiveLine,
    int? pressing,
  }) {
    return TacticalSetup(
      formation: formation ?? this.formation,
      attackingMentality: attackingMentality ?? this.attackingMentality,
      defensiveStyle: defensiveStyle ?? this.defensiveStyle,
      attackingStyle: attackingStyle ?? this.attackingStyle,
      width: width ?? this.width,
      tempo: tempo ?? this.tempo,
      defensiveLine: defensiveLine ?? this.defensiveLine,
      pressing: pressing ?? this.pressing,
    );
  }

  /// JSON serialization
  factory TacticalSetup.fromJson(Map<String, dynamic> json) =>
      _$TacticalSetupFromJson(json);

  Map<String, dynamic> toJson() => _$TacticalSetupToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TacticalSetup &&
          runtimeType == other.runtimeType &&
          formation == other.formation &&
          attackingMentality == other.attackingMentality &&
          defensiveStyle == other.defensiveStyle &&
          attackingStyle == other.attackingStyle &&
          width == other.width &&
          tempo == other.tempo &&
          defensiveLine == other.defensiveLine &&
          pressing == other.pressing;

  @override
  int get hashCode =>
      formation.hashCode ^
      attackingMentality.hashCode ^
      defensiveStyle.hashCode ^
      attackingStyle.hashCode ^
      width.hashCode ^
      tempo.hashCode ^
      defensiveLine.hashCode ^
      pressing.hashCode;

  @override
  String toString() {
    return 'TacticalSetup(formation: $formation, mentality: $attackingMentality, '
           'defensive: $defensiveStyle, attacking: $attackingStyle, '
           'width: $width, tempo: $tempo, line: $defensiveLine, pressing: $pressing)';
  }
}

/// Represents a player's role within a tactical setup
@JsonSerializable()
class PlayerRole {
  /// The player's assigned position
  final PlayerPosition position;
  
  /// Player's individual instructions (1-100 scale)
  final int attackingFreedom; // How much the player can roam forward
  final int defensiveWork; // How much defensive work the player does
  final int width; // How wide the player should play
  final int creativeFreedom; // How much creative license the player has

  const PlayerRole({
    required this.position,
    required this.attackingFreedom,
    required this.defensiveWork,
    required this.width,
    required this.creativeFreedom,
  });

  /// Validates player role parameters
  bool get isValid {
    return attackingFreedom >= 1 && attackingFreedom <= 100 &&
           defensiveWork >= 1 && defensiveWork <= 100 &&
           width >= 1 && width <= 100 &&
           creativeFreedom >= 1 && creativeFreedom <= 100;
  }

  /// Calculates how well this role suits a player's attributes
  double calculateRoleSuitability({
    required int playerAttacking,
    required int playerDefending,
    required int playerTechnical,
    required int playerPhysical,
  }) {
    if (!isValid) return 0.5;
    
    double suitability = 0.0;
    
    // Position-specific suitability
    switch (position) {
      case PlayerPosition.goalkeeper:
        // Goalkeepers primarily need technical skills
        suitability = playerTechnical / 100.0;
        break;
      case PlayerPosition.centreBack:
      case PlayerPosition.leftBack:
      case PlayerPosition.rightBack:
        // Defenders need good defending and physical
        suitability = (playerDefending * 0.6 + playerPhysical * 0.4) / 100.0;
        break;
      case PlayerPosition.wingBack:
        // Wing-backs need attacking, defending, and physical
        suitability = (playerAttacking * 0.3 + playerDefending * 0.4 + playerPhysical * 0.3) / 100.0;
        break;
      case PlayerPosition.defensiveMidfielder:
        // DMs need defending and some technical
        suitability = (playerDefending * 0.7 + playerTechnical * 0.3) / 100.0;
        break;
      case PlayerPosition.centreMidfielder:
        // CMs need balanced attributes
        suitability = (playerAttacking * 0.25 + playerDefending * 0.25 + 
                      playerTechnical * 0.3 + playerPhysical * 0.2) / 100.0;
        break;
      case PlayerPosition.attackingMidfielder:
        // AMs need attacking and technical
        suitability = (playerAttacking * 0.5 + playerTechnical * 0.5) / 100.0;
        break;
      case PlayerPosition.leftWinger:
      case PlayerPosition.rightWinger:
        // Wingers need attacking, technical, and some physical
        suitability = (playerAttacking * 0.5 + playerTechnical * 0.3 + playerPhysical * 0.2) / 100.0;
        break;
      case PlayerPosition.striker:
        // Strikers need attacking primarily
        suitability = (playerAttacking * 0.7 + playerTechnical * 0.3) / 100.0;
        break;
    }
    
    // Adjust based on role instructions match
    double roleMatch = 1.0;
    
    // If high attacking freedom but low attacking skill, reduce suitability
    if (attackingFreedom > 70 && playerAttacking < 50) {
      roleMatch -= 0.2;
    }
    
    // If high defensive work but low defending skill, reduce suitability
    if (defensiveWork > 70 && playerDefending < 50) {
      roleMatch -= 0.2;
    }
    
    return (suitability * roleMatch).clamp(0.0, 1.0);
  }

  /// Creates a copy with updated values
  PlayerRole copyWith({
    PlayerPosition? position,
    int? attackingFreedom,
    int? defensiveWork,
    int? width,
    int? creativeFreedom,
  }) {
    return PlayerRole(
      position: position ?? this.position,
      attackingFreedom: attackingFreedom ?? this.attackingFreedom,
      defensiveWork: defensiveWork ?? this.defensiveWork,
      width: width ?? this.width,
      creativeFreedom: creativeFreedom ?? this.creativeFreedom,
    );
  }

  /// JSON serialization
  factory PlayerRole.fromJson(Map<String, dynamic> json) =>
      _$PlayerRoleFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerRoleToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerRole &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          attackingFreedom == other.attackingFreedom &&
          defensiveWork == other.defensiveWork &&
          width == other.width &&
          creativeFreedom == other.creativeFreedom;

  @override
  int get hashCode =>
      position.hashCode ^
      attackingFreedom.hashCode ^
      defensiveWork.hashCode ^
      width.hashCode ^
      creativeFreedom.hashCode;

  @override
  String toString() {
    return 'PlayerRole(position: $position, attacking: $attackingFreedom, '
           'defending: $defensiveWork, width: $width, creative: $creativeFreedom)';
  }
}
