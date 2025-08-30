import 'dart:math' as math;
import '../models/player.dart';
import '../models/team.dart';
import '../models/tactics.dart' as tactics;

/// System for managing team tactics and their impact on performance
class TacticalSystem {
  final math.Random _random;

  TacticalSystem({int? seed}) : _random = math.Random(seed);

  /// Creates a default tactical setup for a team based on their strengths
  tactics.TacticalSetup createDefaultSetup(Team team) {
    // Analyze team strengths to suggest formation and style
    // Map attributes to approximate attacking/defending capabilities
    final avgAttacking = team.players
        .map((p) => (p.technical + p.physical) / 2)
        .reduce((a, b) => a + b) / team.players.length;
    
    final avgDefending = team.players
        .map((p) => (p.mental + p.physical) / 2)
        .reduce((a, b) => a + b) / team.players.length;

    final avgTechnical = team.players
        .map((p) => p.technical)
        .reduce((a, b) => a + b) / team.players.length;

    // Determine formation based on team balance - balance technical skill with attacking/defensive tendencies
    tactics.Formation formation;
    if (avgTechnical >= 90 && !(avgAttacking > avgDefending + 10)) {
      formation = tactics.Formation.f4231; // Technical teams get priority unless very attacking
    } else if (avgDefending > avgAttacking + 5) {
      formation = tactics.Formation.f532; // Defensive
    } else if (avgAttacking > avgDefending + 5) {
      formation = tactics.Formation.f343; // Attacking
    } else {
      formation = tactics.Formation.f442; // Balanced
    }

    // Determine mentality based on team attacking strength - analyze relative strengths
    tactics.AttackingMentality mentality;
    if (avgAttacking >= 80 || avgAttacking > avgDefending + 8) {
      mentality = tactics.AttackingMentality.attacking;
    } else if (avgDefending >= 80 || avgDefending > avgAttacking + 8) {
      mentality = tactics.AttackingMentality.defensive;
    } else {
      mentality = tactics.AttackingMentality.balanced;
    }

    // Determine styles based on team attributes
    tactics.DefensiveStyle defensiveStyle = avgTechnical > 70 
        ? tactics.DefensiveStyle.zonal 
        : tactics.DefensiveStyle.manMarking;

    tactics.AttackingStyle attackingStyle;
    if (avgTechnical > 75) {
      attackingStyle = tactics.AttackingStyle.possession;
    } else if (avgAttacking > avgDefending) {
      attackingStyle = tactics.AttackingStyle.direct;
    } else {
      attackingStyle = tactics.AttackingStyle.counterAttack;
    }

    return tactics.TacticalSetup(
      formation: formation,
      attackingMentality: mentality,
      defensiveStyle: defensiveStyle,
      attackingStyle: attackingStyle,
      width: 50 + (avgTechnical ~/ 5), // 50-70 based on technical ability
      tempo: 50 + (avgAttacking ~/ 5), // 50-70 based on attacking ability
      defensiveLine: 50 + (avgDefending ~/ 5), // 50-70 based on defensive ability
      pressing: 50 + ((avgAttacking + avgDefending) ~/ 10), // 50-70 based on overall ability
    );
  }

  /// Creates optimal player roles for a given formation
  List<tactics.PlayerRole> createOptimalRoles(tactics.Formation formation, List<Player> players) {
    final roles = <tactics.PlayerRole>[];
    
    // Define position requirements for each formation
    final positionRequirements = _getFormationPositions(formation);
    
    // For limited players, prioritize key positions
    final prioritizedPositions = <tactics.PlayerPosition>[];
    if (players.length < positionRequirements.length) {
      // Add most important positions first: GK, then forwards/strikers, then others
      for (final pos in positionRequirements) {
        if (pos == tactics.PlayerPosition.goalkeeper) {
          prioritizedPositions.insert(0, pos); // GK first
        } else if (pos == tactics.PlayerPosition.striker) {
          prioritizedPositions.insert(prioritizedPositions.length > 0 ? 1 : 0, pos); // Strikers second
        } else {
          prioritizedPositions.add(pos);
        }
      }
    } else {
      prioritizedPositions.addAll(positionRequirements);
    }
    
    // Assign players to positions based on their natural positions first
    final remainingPlayers = List<Player>.from(players);
    final assignedPlayers = <Player>[];

    // Assign roles based on prioritized formation requirements
    for (int i = 0; i < prioritizedPositions.length && remainingPlayers.isNotEmpty; i++) {
      final requiredPosition = prioritizedPositions[i];
      
      // Find the best suited player for this position
      Player? bestPlayer;
      
      // For goalkeeper position, strongly prioritize actual goalkeepers
      if (requiredPosition == tactics.PlayerPosition.goalkeeper) {
        for (final player in remainingPlayers) {
          if (player.position == PlayerPosition.goalkeeper) {
            bestPlayer = player;
            break; // Take the first (and likely only) goalkeeper
          }
        }
      }
      
      // If no goalkeeper found for goalkeeper position, or for other positions, use normal logic
      if (bestPlayer == null) {
        // First try to find a player with matching natural position
        for (final player in remainingPlayers) {
          if (_isPositionCompatible(player.position, requiredPosition)) {
            if (bestPlayer == null || player.overallRating > bestPlayer.overallRating) {
              bestPlayer = player;
            }
          }
        }
        
        // If no compatible player found, take the best available player
        if (bestPlayer == null && remainingPlayers.isNotEmpty) {
          bestPlayer = remainingPlayers.reduce((a, b) => 
            a.overallRating > b.overallRating ? a : b);
        }
      }
      
      if (bestPlayer != null) {
        roles.add(_createRoleForPosition(requiredPosition, bestPlayer));
        remainingPlayers.remove(bestPlayer);
        assignedPlayers.add(bestPlayer);
      }
    }

    return roles;
  }

  /// Calculates team chemistry based on tactical setup and player roles
  double calculateTeamChemistry(Team team, tactics.TacticalSetup setup, List<tactics.PlayerRole> roles) {
    if (roles.length != team.players.length) {
      return 0.5; // Invalid setup
    }

    double totalChemistry = 0.0;
    
    for (int i = 0; i < team.players.length; i++) {
      final player = team.players[i];
      final role = roles[i];
      
      // Calculate individual player-role chemistry
      // Map player attributes to expected parameters
      final playerAttacking = (player.technical + player.physical) ~/ 2;
      final playerDefending = (player.mental + player.physical) ~/ 2;
      
      double roleSuitability = role.calculateRoleSuitability(
        playerAttacking: playerAttacking,
        playerDefending: playerDefending,
        playerTechnical: player.technical,
        playerPhysical: player.physical,
      );
      
      // Apply severe penalty for position mismatches
      if (!_isPositionCompatible(player.position, role.position)) {
        roleSuitability *= 0.3; // 70% penalty for playing out of position
      }
      
      // Additional penalty for goalkeepers playing outfield (and vice versa)
      if (player.position == PlayerPosition.goalkeeper && role.position != tactics.PlayerPosition.goalkeeper) {
        roleSuitability *= 0.1; // 90% penalty - goalkeepers can't play outfield
      } else if (player.position != PlayerPosition.goalkeeper && role.position == tactics.PlayerPosition.goalkeeper) {
        roleSuitability *= 0.1; // 90% penalty - outfield players can't keep goal
      }
      
      totalChemistry += roleSuitability;
    }

    // Average chemistry (0.0 to 1.0) converted to 0-100 scale
    double baseChemistry = (totalChemistry / team.players.length) * 100;
    
    // Apply formation familiarity bonus/penalty
    double formationModifier = _getFormationFamiliarityModifier(setup.formation);
    
    return (baseChemistry * formationModifier).clamp(0.0, 100.0);
  }

  /// Applies tactical instructions to modify team performance
  Map<String, double> applyTacticalModifiers({
    required tactics.TacticalSetup setup,
    required double teamChemistry,
    required int managerRating,
    required bool isHomeTeam,
  }) {
    final tacticalEffectiveness = setup.calculateTacticalEffectiveness(
      teamChemistry: teamChemistry.round(),
      managerRating: managerRating,
    );

    // Base modifiers from tactical setup
    double attackingModifier = 1.0;
    double defendingModifier = 1.0;
    double possessionModifier = 1.0;
    double chanceCreationModifier = 1.0;

    // Apply attacking mentality effects
    switch (setup.attackingMentality) {
      case tactics.AttackingMentality.ultraDefensive:
        attackingModifier *= 0.8;
        defendingModifier *= 1.2;
        possessionModifier *= 0.9;
        break;
      case tactics.AttackingMentality.defensive:
        attackingModifier *= 0.9;
        defendingModifier *= 1.1;
        break;
      case tactics.AttackingMentality.balanced:
        // No modifications
        break;
      case tactics.AttackingMentality.attacking:
        attackingModifier *= 1.1;
        defendingModifier *= 0.9;
        chanceCreationModifier *= 1.1;
        break;
      case tactics.AttackingMentality.ultraAttacking:
        attackingModifier *= 1.2;
        defendingModifier *= 0.8;
        chanceCreationModifier *= 1.2;
        possessionModifier *= 1.1;
        break;
    }

    // Apply formation-specific modifiers
    final formationModifiers = _getFormationModifiers(setup.formation);
    attackingModifier *= formationModifiers['attacking']!;
    defendingModifier *= formationModifiers['defending']!;
    possessionModifier *= formationModifiers['possession']!;

    // Apply tactical style effects
    switch (setup.attackingStyle) {
      case tactics.AttackingStyle.possession:
        possessionModifier *= 1.15;
        chanceCreationModifier *= 0.95;
        break;
      case tactics.AttackingStyle.counterAttack:
        chanceCreationModifier *= 1.1;
        possessionModifier *= 0.9;
        break;
      case tactics.AttackingStyle.direct:
        attackingModifier *= 1.05;
        possessionModifier *= 0.95;
        break;
      case tactics.AttackingStyle.wingPlay:
        chanceCreationModifier *= 1.05;
        break;
    }

    // Apply width and tempo effects
    final widthEffect = (setup.width - 50) / 100; // -0.5 to +0.5
    final tempoEffect = (setup.tempo - 50) / 100; // -0.5 to +0.5
    
    chanceCreationModifier *= (1.0 + widthEffect * 0.1);
    attackingModifier *= (1.0 + tempoEffect * 0.05);

    // Apply pressing and defensive line effects
    final pressingEffect = (setup.pressing - 50) / 100;
    final defensiveLineEffect = (setup.defensiveLine - 50) / 100;
    
    defendingModifier *= (1.0 + pressingEffect * 0.1);
    possessionModifier *= (1.0 + defensiveLineEffect * 0.05);

    // Apply overall tactical effectiveness
    attackingModifier *= tacticalEffectiveness;
    defendingModifier *= tacticalEffectiveness;
    possessionModifier *= tacticalEffectiveness;
    chanceCreationModifier *= tacticalEffectiveness;

    return {
      'attacking': attackingModifier,
      'defending': defendingModifier,
      'possession': possessionModifier,
      'chanceCreation': chanceCreationModifier,
    };
  }

  /// Suggests tactical adjustments based on match situation
  tactics.TacticalSetup suggestTacticalAdjustment({
    required tactics.TacticalSetup currentSetup,
    required int currentScore,
    required int opponentScore,
    required int minutesRemaining,
    required double currentPossession,
  }) {
    final scoreDifference = currentScore - opponentScore;
    final isLosing = scoreDifference < 0;
    final isWinning = scoreDifference > 0;
    final isCloseToEnd = minutesRemaining < 20;

    tactics.TacticalSetup adjustedSetup = currentSetup;

    // Adjust based on score situation
    if (isLosing && isCloseToEnd) {
      // More attacking when losing late in the game
      adjustedSetup = adjustedSetup.copyWith(
        attackingMentality: tactics.AttackingMentality.attacking,
        pressing: math.min(100, currentSetup.pressing + 20),
        tempo: math.min(100, currentSetup.tempo + 15),
      );
    } else if (isWinning && isCloseToEnd) {
      // More defensive when winning late in the game
      adjustedSetup = adjustedSetup.copyWith(
        attackingMentality: tactics.AttackingMentality.defensive,
        defensiveLine: math.max(1, currentSetup.defensiveLine - 15),
        pressing: math.max(1, currentSetup.pressing - 10),
      );
    }

    // Adjust based on possession
    if (currentPossession < 0.4) {
      // Struggling with possession - make adjustments
      adjustedSetup = adjustedSetup.copyWith(
        attackingStyle: tactics.AttackingStyle.counterAttack,
        tempo: math.max(1, currentSetup.tempo - 10),
      );
    } else if (currentPossession > 0.65) {
      // Dominating possession - be more direct
      adjustedSetup = adjustedSetup.copyWith(
        attackingStyle: tactics.AttackingStyle.direct,
        tempo: math.min(100, currentSetup.tempo + 10),
      );
    }

    return adjustedSetup;
  }

  // Private helper methods

  List<tactics.PlayerPosition> _getFormationPositions(tactics.Formation formation) {
    switch (formation) {
      case tactics.Formation.f442:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.leftBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.rightWinger,
          tactics.PlayerPosition.striker, tactics.PlayerPosition.striker,
        ];
      case tactics.Formation.f433:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.leftBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.striker, tactics.PlayerPosition.rightWinger,
        ];
      case tactics.Formation.f352:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack,
          tactics.PlayerPosition.wingBack, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.wingBack,
          tactics.PlayerPosition.striker, tactics.PlayerPosition.striker,
        ];
      case tactics.Formation.f532:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack,
          tactics.PlayerPosition.wingBack, tactics.PlayerPosition.defensiveMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.defensiveMidfielder, tactics.PlayerPosition.wingBack,
          tactics.PlayerPosition.striker, tactics.PlayerPosition.striker,
        ];
      case tactics.Formation.f451:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.leftBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.rightWinger,
          tactics.PlayerPosition.attackingMidfielder,
          tactics.PlayerPosition.striker,
        ];
      case tactics.Formation.f4231:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.leftBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.defensiveMidfielder, tactics.PlayerPosition.defensiveMidfielder,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.attackingMidfielder, tactics.PlayerPosition.rightWinger,
          tactics.PlayerPosition.striker,
        ];
      case tactics.Formation.f343:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack,
          tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.striker, tactics.PlayerPosition.rightWinger,
        ];
      case tactics.Formation.f4141:
        return [
          tactics.PlayerPosition.goalkeeper,
          tactics.PlayerPosition.leftBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.centreBack, tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.defensiveMidfielder,
          tactics.PlayerPosition.leftWinger, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.centreMidfielder, tactics.PlayerPosition.rightWinger,
          tactics.PlayerPosition.striker,
        ];
    }
  }

  tactics.PlayerRole _createRoleForPosition(tactics.PlayerPosition position, Player player) {
    // Create role instructions based on position and player attributes
    int attackingFreedom = 50;
    int defensiveWork = 50;
    int width = 50;
    int creativeFreedom = 50;

    switch (position) {
      case tactics.PlayerPosition.goalkeeper:
        attackingFreedom = 10;
        defensiveWork = 90;
        width = 30;
        creativeFreedom = 20;
        break;
      case tactics.PlayerPosition.centreBack:
        attackingFreedom = 20;
        defensiveWork = 80;
        width = 40;
        creativeFreedom = 30;
        break;
      case tactics.PlayerPosition.leftBack:
      case tactics.PlayerPosition.rightBack:
        attackingFreedom = 40;
        defensiveWork = 70;
        width = 80;
        creativeFreedom = 40;
        break;
      case tactics.PlayerPosition.wingBack:
        attackingFreedom = 60;
        defensiveWork = 60;
        width = 90;
        creativeFreedom = 50;
        break;
      case tactics.PlayerPosition.defensiveMidfielder:
        attackingFreedom = 30;
        defensiveWork = 80;
        width = 50;
        creativeFreedom = 40;
        break;
      case tactics.PlayerPosition.centreMidfielder:
        attackingFreedom = 60;
        defensiveWork = 60;
        width = 50;
        creativeFreedom = 70;
        break;
      case tactics.PlayerPosition.attackingMidfielder:
        attackingFreedom = 80;
        defensiveWork = 30;
        width = 50;
        creativeFreedom = 90;
        break;
      case tactics.PlayerPosition.leftWinger:
      case tactics.PlayerPosition.rightWinger:
        attackingFreedom = 80;
        defensiveWork = 40;
        width = 90;
        creativeFreedom = 80;
        break;
      case tactics.PlayerPosition.striker:
        attackingFreedom = 90;
        defensiveWork = 20;
        width = 60;
        creativeFreedom = 70;
        break;
    }

    // Adjust based on player's actual attributes with larger bonuses for exceptional players
    // Goalkeepers get no attribute adjustments to maintain their base role values
    if (position != tactics.PlayerPosition.goalkeeper) {
      final playerAttacking = (player.technical + player.physical) ~/ 2;
      final playerDefending = (player.mental + player.physical) ~/ 2;
      
      // Provide significant bonuses for high-attribute players (only for non-goalkeeper positions)
      if (playerAttacking > 85) {
        attackingFreedom = math.min(100, attackingFreedom + 25);
      } else if (playerAttacking >= 75) {
        attackingFreedom = math.min(100, attackingFreedom + 15);
      }
      
      // Only apply defensive work bonuses to defensive positions - strikers shouldn't get defensive bonuses
      if (position != tactics.PlayerPosition.striker && position != tactics.PlayerPosition.attackingMidfielder) {
        if (playerDefending > 85) {
          defensiveWork = math.min(100, defensiveWork + 25);
        } else if (playerDefending >= 75) {
          defensiveWork = math.min(100, defensiveWork + 15);
        }
      }
      
      if (player.technical > 85) {
        creativeFreedom = math.min(100, creativeFreedom + 25);
      } else if (player.technical >= 75) {
        creativeFreedom = math.min(100, creativeFreedom + 15);
      }
    }

    return tactics.PlayerRole(
      position: position,
      attackingFreedom: attackingFreedom,
      defensiveWork: defensiveWork,
      width: width,
      creativeFreedom: creativeFreedom,
    );
  }

  double _getFormationFamiliarityModifier(tactics.Formation formation) {
    // Simulate formation familiarity - more common formations have higher familiarity
    switch (formation) {
      case tactics.Formation.f442:
      case tactics.Formation.f433:
        return 1.05; // Very common formations
      case tactics.Formation.f4231:
      case tactics.Formation.f352:
        return 1.0; // Common formations
      case tactics.Formation.f451:
      case tactics.Formation.f532:
        return 0.98; // Less common formations
      case tactics.Formation.f343:
      case tactics.Formation.f4141:
        return 0.95; // Uncommon formations
    }
  }

  Map<String, double> _getFormationModifiers(tactics.Formation formation) {
    switch (formation) {
      case tactics.Formation.f442:
        return {'attacking': 1.0, 'defending': 1.0, 'possession': 1.0};
      case tactics.Formation.f433:
        return {'attacking': 1.05, 'defending': 0.98, 'possession': 1.02};
      case tactics.Formation.f352:
        return {'attacking': 0.98, 'defending': 1.05, 'possession': 0.98};
      case tactics.Formation.f532:
        return {'attacking': 0.95, 'defending': 1.1, 'possession': 0.95};
      case tactics.Formation.f451:
        return {'attacking': 0.98, 'defending': 1.02, 'possession': 1.05};
      case tactics.Formation.f4231:
        return {'attacking': 1.02, 'defending': 1.0, 'possession': 1.08};
      case tactics.Formation.f343:
        return {'attacking': 1.1, 'defending': 0.9, 'possession': 1.05};
      case tactics.Formation.f4141:
        return {'attacking': 0.95, 'defending': 1.05, 'possession': 1.08};
    }
  }

  bool _isPositionCompatible(PlayerPosition playerPosition, tactics.PlayerPosition tacticalPosition) {
    // Map player natural positions to tactical positions
    switch (playerPosition) {
      case PlayerPosition.goalkeeper:
        return tacticalPosition == tactics.PlayerPosition.goalkeeper;
      case PlayerPosition.defender:
        return [
          tactics.PlayerPosition.centreBack,
          tactics.PlayerPosition.leftBack,
          tactics.PlayerPosition.rightBack,
          tactics.PlayerPosition.wingBack,
        ].contains(tacticalPosition);
      case PlayerPosition.midfielder:
        return [
          tactics.PlayerPosition.defensiveMidfielder,
          tactics.PlayerPosition.centreMidfielder,
          tactics.PlayerPosition.attackingMidfielder,
          tactics.PlayerPosition.leftWinger,
          tactics.PlayerPosition.rightWinger,
        ].contains(tacticalPosition);
      case PlayerPosition.forward:
        return [
          tactics.PlayerPosition.striker,
          tactics.PlayerPosition.leftWinger,
          tactics.PlayerPosition.rightWinger,
          tactics.PlayerPosition.attackingMidfielder,
        ].contains(tacticalPosition);
    }
  }
}
