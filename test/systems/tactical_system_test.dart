import 'package:test/test.dart';
import '../../lib/src/models/player.dart';
import '../../lib/src/models/team.dart';
import '../../lib/src/models/tactics.dart' as tactics;
import '../../lib/src/systems/tactical_system.dart';

void main() {
  group('TacticalSystem Tests', () {
    late TacticalSystem tacticalSystem;
    late Team testTeam;
    late List<Player> balancedPlayers;

    setUp(() {
      tacticalSystem = TacticalSystem(seed: 42);
      
      // Create a balanced test team
      balancedPlayers = [
        Player(id: '1', name: 'Goalkeeper', age: 25, position: PlayerPosition.goalkeeper, technical: 80, physical: 70, mental: 85),
        Player(id: '2', name: 'Centre Back 1', age: 28, position: PlayerPosition.defender, technical: 60, physical: 80, mental: 75),
        Player(id: '3', name: 'Centre Back 2', age: 27, position: PlayerPosition.defender, technical: 65, physical: 85, mental: 78),
        Player(id: '4', name: 'Left Back', age: 24, position: PlayerPosition.defender, technical: 75, physical: 75, mental: 65),
        Player(id: '5', name: 'Right Back', age: 26, position: PlayerPosition.defender, technical: 70, physical: 70, mental: 68),
        Player(id: '6', name: 'CDM', age: 29, position: PlayerPosition.midfielder, technical: 75, physical: 70, mental: 80),
        Player(id: '7', name: 'CM 1', age: 25, position: PlayerPosition.midfielder, technical: 80, physical: 65, mental: 75),
        Player(id: '8', name: 'CM 2', age: 27, position: PlayerPosition.midfielder, technical: 85, physical: 60, mental: 78),
        Player(id: '9', name: 'LW', age: 23, position: PlayerPosition.forward, technical: 80, physical: 65, mental: 70),
        Player(id: '10', name: 'RW', age: 24, position: PlayerPosition.forward, technical: 85, physical: 70, mental: 72),
        Player(id: '11', name: 'Striker', age: 26, position: PlayerPosition.forward, technical: 75, physical: 80, mental: 75),
      ];
      
      testTeam = Team(
        id: 'test-team',
        name: 'Test FC',
        city: 'Test City',
        foundedYear: 2000,
        players: balancedPlayers,
        morale: 80,
      );
    });

    test('should create default tactical setup based on team strengths', () {
      final setup = tacticalSystem.createDefaultSetup(testTeam);

      expect(setup.formation, isA<tactics.Formation>());
      expect(setup.attackingMentality, isA<tactics.AttackingMentality>());
      expect(setup.defensiveStyle, isA<tactics.DefensiveStyle>());
      expect(setup.attackingStyle, isA<tactics.AttackingStyle>());
      expect(setup.isValid, isTrue);
      
      // Should be balanced formation for balanced team
      expect(setup.formation, equals(tactics.Formation.f442));
      expect(setup.attackingMentality, equals(tactics.AttackingMentality.balanced));
    });

    test('should create defensive setup for defensive team', () {
      final defensivePlayers = [
        Player(id: '1', name: 'Goalkeeper', age: 25, position: PlayerPosition.goalkeeper, technical: 80, physical: 70, mental: 95),
        Player(id: '2', name: 'Centre Back 1', age: 28, position: PlayerPosition.defender, technical: 40, physical: 90, mental: 85),
        Player(id: '3', name: 'Centre Back 2', age: 27, position: PlayerPosition.defender, technical: 45, physical: 95, mental: 88),
        Player(id: '4', name: 'Left Back', age: 24, position: PlayerPosition.defender, technical: 55, physical: 85, mental: 75),
        Player(id: '5', name: 'Right Back', age: 26, position: PlayerPosition.defender, technical: 50, physical: 80, mental: 78),
        Player(id: '6', name: 'CDM', age: 29, position: PlayerPosition.midfielder, technical: 55, physical: 80, mental: 90),
        Player(id: '7', name: 'CM 1', age: 25, position: PlayerPosition.midfielder, technical: 60, physical: 75, mental: 85),
        Player(id: '8', name: 'CM 2', age: 27, position: PlayerPosition.midfielder, technical: 65, physical: 70, mental: 88),
        Player(id: '9', name: 'LW', age: 23, position: PlayerPosition.forward, technical: 60, physical: 75, mental: 80),
        Player(id: '10', name: 'RW', age: 24, position: PlayerPosition.forward, technical: 65, physical: 80, mental: 82),
        Player(id: '11', name: 'Striker', age: 26, position: PlayerPosition.forward, technical: 55, physical: 90, mental: 85),
      ];
      
      final defensiveTeam = Team(
        id: 'defensive-team',
        name: 'Defensive FC',
        city: 'Defensive City',
        foundedYear: 2000,
        players: defensivePlayers,
        morale: 80,
      );
      final setup = tacticalSystem.createDefaultSetup(defensiveTeam);

      expect(setup.attackingMentality, equals(tactics.AttackingMentality.defensive));
      expect(setup.formation, equals(tactics.Formation.f532));
    });

    test('should create attacking setup for attacking team', () {
      final attackingPlayers = [
        Player(id: '1', name: 'Goalkeeper', age: 25, position: PlayerPosition.goalkeeper, technical: 80, physical: 70, mental: 85),
        Player(id: '2', name: 'Centre Back 1', age: 28, position: PlayerPosition.defender, technical: 80, physical: 70, mental: 65),
        Player(id: '3', name: 'Centre Back 2', age: 27, position: PlayerPosition.defender, technical: 85, physical: 75, mental: 68),
        Player(id: '4', name: 'Left Back', age: 24, position: PlayerPosition.defender, technical: 95, physical: 65, mental: 55),
        Player(id: '5', name: 'Right Back', age: 26, position: PlayerPosition.defender, technical: 90, physical: 60, mental: 58),
        Player(id: '6', name: 'CDM', age: 29, position: PlayerPosition.midfielder, technical: 95, physical: 60, mental: 70),
        Player(id: '7', name: 'CM 1', age: 25, position: PlayerPosition.midfielder, technical: 100, physical: 55, mental: 65),
        Player(id: '8', name: 'CM 2', age: 27, position: PlayerPosition.midfielder, technical: 100, physical: 50, mental: 68),
        Player(id: '9', name: 'LW', age: 23, position: PlayerPosition.forward, technical: 100, physical: 55, mental: 60),
        Player(id: '10', name: 'RW', age: 24, position: PlayerPosition.forward, technical: 100, physical: 60, mental: 62),
        Player(id: '11', name: 'Striker', age: 26, position: PlayerPosition.forward, technical: 95, physical: 70, mental: 65),
      ];
      
      final attackingTeam = Team(
        id: 'attacking-team',
        name: 'Attacking FC',
        city: 'Attacking City',
        foundedYear: 2000,
        players: attackingPlayers,
        morale: 80,
      );
      final setup = tacticalSystem.createDefaultSetup(attackingTeam);

      expect(setup.attackingMentality, equals(tactics.AttackingMentality.attacking));
      expect(setup.formation, equals(tactics.Formation.f343));
    });

    test('should create technical setup for high-technical team', () {
      final technicalPlayers = [
        Player(id: '1', name: 'Goalkeeper', age: 25, position: PlayerPosition.goalkeeper, technical: 90, physical: 70, mental: 85),
        Player(id: '2', name: 'Centre Back 1', age: 28, position: PlayerPosition.defender, technical: 90, physical: 80, mental: 75),
        Player(id: '3', name: 'Centre Back 2', age: 27, position: PlayerPosition.defender, technical: 90, physical: 85, mental: 78),
        Player(id: '4', name: 'Left Back', age: 24, position: PlayerPosition.defender, technical: 90, physical: 75, mental: 65),
        Player(id: '5', name: 'Right Back', age: 26, position: PlayerPosition.defender, technical: 90, physical: 70, mental: 68),
        Player(id: '6', name: 'CDM', age: 29, position: PlayerPosition.midfielder, technical: 90, physical: 70, mental: 80),
        Player(id: '7', name: 'CM 1', age: 25, position: PlayerPosition.midfielder, technical: 90, physical: 65, mental: 75),
        Player(id: '8', name: 'CM 2', age: 27, position: PlayerPosition.midfielder, technical: 90, physical: 60, mental: 78),
        Player(id: '9', name: 'LW', age: 23, position: PlayerPosition.forward, technical: 90, physical: 65, mental: 70),
        Player(id: '10', name: 'RW', age: 24, position: PlayerPosition.forward, technical: 90, physical: 70, mental: 72),
        Player(id: '11', name: 'Striker', age: 26, position: PlayerPosition.forward, technical: 90, physical: 80, mental: 75),
      ];
      
      final technicalTeam = Team(
        id: 'technical-team',
        name: 'Technical FC',
        city: 'Technical City',
        foundedYear: 2000,
        players: technicalPlayers,
        morale: 80,
      );
      final setup = tacticalSystem.createDefaultSetup(technicalTeam);

      expect(setup.formation, equals(tactics.Formation.f4231));
      expect(setup.attackingStyle, equals(tactics.AttackingStyle.possession));
      expect(setup.defensiveStyle, equals(tactics.DefensiveStyle.zonal));
    });

    test('should create optimal player roles for formations', () {
      final roles442 = tacticalSystem.createOptimalRoles(tactics.Formation.f442, balancedPlayers);
      expect(roles442.length, equals(11));
      expect(roles442.first.position, equals(tactics.PlayerPosition.goalkeeper));
      expect(roles442.last.position, equals(tactics.PlayerPosition.striker));

      final roles433 = tacticalSystem.createOptimalRoles(tactics.Formation.f433, balancedPlayers);
      expect(roles433.length, equals(11));
      expect(roles433.first.position, equals(tactics.PlayerPosition.goalkeeper));

      final roles352 = tacticalSystem.createOptimalRoles(tactics.Formation.f352, balancedPlayers);
      expect(roles352.length, equals(11));
      expect(roles352.where((r) => r.position == tactics.PlayerPosition.centreBack).length, equals(3));
    });

    test('should handle insufficient players for formation', () {
      final fewPlayers = balancedPlayers.take(8).toList();
      final roles = tacticalSystem.createOptimalRoles(tactics.Formation.f442, fewPlayers);
      expect(roles.length, equals(8)); // Only as many roles as players
    });

    test('should calculate team chemistry correctly', () {
      final setup = tacticalSystem.createDefaultSetup(testTeam);
      final roles = tacticalSystem.createOptimalRoles(setup.formation, balancedPlayers);
      
      final chemistry = tacticalSystem.calculateTeamChemistry(testTeam, setup, roles);
      
      expect(chemistry, greaterThan(0.0));
      expect(chemistry, lessThanOrEqualTo(100.0));
      expect(chemistry, greaterThan(50.0)); // Should be decent for balanced team
    });

    test('should return low chemistry for mismatched roles', () {
      final setup = tacticalSystem.createDefaultSetup(testTeam);
      final wrongRoles = List.generate(11, (index) => const tactics.PlayerRole(
        position: tactics.PlayerPosition.goalkeeper, // All goalkeepers!
        attackingFreedom: 10,
        defensiveWork: 90,
        width: 30,
        creativeFreedom: 20,
      ));
      
      final chemistry = tacticalSystem.calculateTeamChemistry(testTeam, setup, wrongRoles);
      expect(chemistry, lessThan(30.0)); // Very low chemistry
    });

    test('should return invalid chemistry for wrong number of roles', () {
      final setup = tacticalSystem.createDefaultSetup(testTeam);
      final wrongRoles = [const tactics.PlayerRole(
        position: tactics.PlayerPosition.goalkeeper,
        attackingFreedom: 10,
        defensiveWork: 90,
        width: 30,
        creativeFreedom: 20,
      )]; // Only one role for 11 players
      
      final chemistry = tacticalSystem.calculateTeamChemistry(testTeam, setup, wrongRoles);
      expect(chemistry, equals(0.5)); // Invalid setup
    });

    test('should apply tactical modifiers correctly', () {
      final setup = const tactics.TacticalSetup(
        formation: tactics.Formation.f442,
        attackingMentality: tactics.AttackingMentality.attacking,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 60,
        tempo: 70,
        defensiveLine: 55,
        pressing: 50,
      );

      final modifiers = tacticalSystem.applyTacticalModifiers(
        setup: setup,
        teamChemistry: 80.0,
        managerRating: 75,
        isHomeTeam: true,
      );

      expect(modifiers, containsPair('attacking', isA<double>()));
      expect(modifiers, containsPair('defending', isA<double>()));
      expect(modifiers, containsPair('possession', isA<double>()));
      expect(modifiers, containsPair('chanceCreation', isA<double>()));

      // Attacking mentality should boost attacking
      expect(modifiers['attacking'], greaterThan(1.0));
      // And reduce defending
      expect(modifiers['defending'], lessThan(1.0));
      // Possession style should boost possession
      expect(modifiers['possession'], greaterThan(1.0));
    });

    test('should apply ultra-defensive modifiers correctly', () {
      final setup = const tactics.TacticalSetup(
        formation: tactics.Formation.f532,
        attackingMentality: tactics.AttackingMentality.ultraDefensive,
        defensiveStyle: tactics.DefensiveStyle.lowBlock,
        attackingStyle: tactics.AttackingStyle.counterAttack,
        width: 40,
        tempo: 30,
        defensiveLine: 30,
        pressing: 20,
      );

      final modifiers = tacticalSystem.applyTacticalModifiers(
        setup: setup,
        teamChemistry: 70.0,
        managerRating: 60,
        isHomeTeam: false,
      );

      // Ultra-defensive should reduce attacking
      expect(modifiers['attacking'], lessThan(1.0));
      // And boost defending significantly
      expect(modifiers['defending'], greaterThan(1.0));
    });

    test('should suggest tactical adjustments when losing', () {
      final currentSetup = const tactics.TacticalSetup(
        formation: tactics.Formation.f442,
        attackingMentality: tactics.AttackingMentality.balanced,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 50,
        tempo: 50,
        defensiveLine: 50,
        pressing: 50,
      );

      final adjustedSetup = tacticalSystem.suggestTacticalAdjustment(
        currentSetup: currentSetup,
        currentScore: 0,
        opponentScore: 1,
        minutesRemaining: 15,
        currentPossession: 0.45,
      );

      // Should become more attacking when losing late
      expect(adjustedSetup.attackingMentality, equals(tactics.AttackingMentality.attacking));
      expect(adjustedSetup.pressing, greaterThan(currentSetup.pressing));
      expect(adjustedSetup.tempo, greaterThan(currentSetup.tempo));
    });

    test('should suggest tactical adjustments when winning', () {
      final currentSetup = const tactics.TacticalSetup(
        formation: tactics.Formation.f442,
        attackingMentality: tactics.AttackingMentality.balanced,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 50,
        tempo: 50,
        defensiveLine: 50,
        pressing: 50,
      );

      final adjustedSetup = tacticalSystem.suggestTacticalAdjustment(
        currentSetup: currentSetup,
        currentScore: 2,
        opponentScore: 0,
        minutesRemaining: 10,
        currentPossession: 0.55,
      );

      // Should become more defensive when winning late
      expect(adjustedSetup.attackingMentality, equals(tactics.AttackingMentality.defensive));
      expect(adjustedSetup.defensiveLine, lessThan(currentSetup.defensiveLine));
      expect(adjustedSetup.pressing, lessThan(currentSetup.pressing));
    });

    test('should suggest adjustments for poor possession', () {
      final currentSetup = const tactics.TacticalSetup(
        formation: tactics.Formation.f442,
        attackingMentality: tactics.AttackingMentality.balanced,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 50,
        tempo: 60,
        defensiveLine: 50,
        pressing: 50,
      );

      final adjustedSetup = tacticalSystem.suggestTacticalAdjustment(
        currentSetup: currentSetup,
        currentScore: 0,
        opponentScore: 0,
        minutesRemaining: 60,
        currentPossession: 0.35, // Very poor possession
      );

      // Should switch to counter-attacking style
      expect(adjustedSetup.attackingStyle, equals(tactics.AttackingStyle.counterAttack));
      expect(adjustedSetup.tempo, lessThan(currentSetup.tempo));
    });

    test('should suggest adjustments for dominant possession', () {
      final currentSetup = const tactics.TacticalSetup(
        formation: tactics.Formation.f442,
        attackingMentality: tactics.AttackingMentality.balanced,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 50,
        tempo: 50,
        defensiveLine: 50,
        pressing: 50,
      );

      final adjustedSetup = tacticalSystem.suggestTacticalAdjustment(
        currentSetup: currentSetup,
        currentScore: 0,
        opponentScore: 0,
        minutesRemaining: 60,
        currentPossession: 0.70, // Dominant possession
      );

      // Should become more direct to capitalize
      expect(adjustedSetup.attackingStyle, equals(tactics.AttackingStyle.direct));
      expect(adjustedSetup.tempo, greaterThan(currentSetup.tempo));
    });

    test('should handle all formation position mappings', () {
      for (final formation in tactics.Formation.values) {
        final roles = tacticalSystem.createOptimalRoles(formation, balancedPlayers);
        expect(roles.length, equals(11));
        expect(roles.first.position, equals(tactics.PlayerPosition.goalkeeper));
        
        // Each formation should have valid position assignments
        final positions = roles.map((r) => r.position).toSet();
        expect(positions.contains(tactics.PlayerPosition.goalkeeper), isTrue);
      }
    });

    test('should create appropriate roles for different positions', () {
      final goalkeeper = balancedPlayers[0];
      final striker = balancedPlayers[10];

      final roles442 = tacticalSystem.createOptimalRoles(tactics.Formation.f442, [goalkeeper, striker]);
      
      final gkRole = roles442.first;
      expect(gkRole.position, equals(tactics.PlayerPosition.goalkeeper));
      expect(gkRole.attackingFreedom, lessThan(30));
      expect(gkRole.defensiveWork, greaterThan(80));

      if (roles442.length > 1) {
        final strikerRole = roles442.last;
        expect(strikerRole.position, equals(tactics.PlayerPosition.striker));
        expect(strikerRole.attackingFreedom, greaterThan(80));
        expect(strikerRole.defensiveWork, lessThan(30));
      }
    });

    test('should adjust role instructions based on player attributes', () {
      final superAttacker = Player(
        id: 'super',
        name: 'Super Attacker',
        age: 25,
        position: PlayerPosition.forward,
        technical: 90,
        physical: 80,
        mental: 70,
      );

      final roles = tacticalSystem.createOptimalRoles(tactics.Formation.f442, [balancedPlayers[0], superAttacker]);
      
      if (roles.length > 1) {
        final attackerRole = roles.last;
        // High technical attribute should boost attacking freedom
        expect(attackerRole.attackingFreedom, greaterThan(70));
        // High technical should boost creative freedom
        expect(attackerRole.creativeFreedom, greaterThan(70));
      }
    });

    test('should provide formation familiarity modifiers', () {
      // Test with different formations to ensure familiarity affects chemistry
      final setup442 = tacticalSystem.createDefaultSetup(testTeam);
      final roles442 = tacticalSystem.createOptimalRoles(tactics.Formation.f442, balancedPlayers);
      final chemistry442 = tacticalSystem.calculateTeamChemistry(testTeam, setup442, roles442);

      final setup4141 = const tactics.TacticalSetup(
        formation: tactics.Formation.f4141,
        attackingMentality: tactics.AttackingMentality.balanced,
        defensiveStyle: tactics.DefensiveStyle.zonal,
        attackingStyle: tactics.AttackingStyle.possession,
        width: 50,
        tempo: 50,
        defensiveLine: 50,
        pressing: 50,
      );
      final roles4141 = tacticalSystem.createOptimalRoles(tactics.Formation.f4141, balancedPlayers);
      final chemistry4141 = tacticalSystem.calculateTeamChemistry(testTeam, setup4141, roles4141);

      // 4-4-2 is more familiar than 4-1-4-1, so should have better chemistry
      expect(chemistry442, greaterThanOrEqualTo(chemistry4141));
    });

    test('should handle edge case formations correctly', () {
      // Test that all formations work with tactical modifiers
      for (final formation in tactics.Formation.values) {
        final setup = tactics.TacticalSetup(
          formation: formation,
          attackingMentality: tactics.AttackingMentality.balanced,
          defensiveStyle: tactics.DefensiveStyle.zonal,
          attackingStyle: tactics.AttackingStyle.possession,
          width: 50,
          tempo: 50,
          defensiveLine: 50,
          pressing: 50,
        );

        final modifiers = tacticalSystem.applyTacticalModifiers(
          setup: setup,
          teamChemistry: 70.0,
          managerRating: 70,
          isHomeTeam: true,
        );

        expect(modifiers['attacking'], greaterThan(0.5));
        expect(modifiers['defending'], greaterThan(0.5));
        expect(modifiers['possession'], greaterThan(0.5));
        expect(modifiers['chanceCreation'], greaterThan(0.5));
      }
    });
  });
}
