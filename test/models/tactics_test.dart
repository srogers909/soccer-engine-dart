import 'dart:convert';
import 'package:test/test.dart';
import '../../lib/src/models/tactics.dart';

void main() {
  group('Formation Tests', () {
    test('should have correct JSON values', () {
      expect(Formation.f442.toString(), contains('f442'));
      expect(Formation.f433.toString(), contains('f433'));
      expect(Formation.f352.toString(), contains('f352'));
    });
  });

  group('AttackingMentality Tests', () {
    test('should have correct JSON values', () {
      expect(AttackingMentality.ultraDefensive.toString(), contains('ultraDefensive'));
      expect(AttackingMentality.balanced.toString(), contains('balanced'));
      expect(AttackingMentality.ultraAttacking.toString(), contains('ultraAttacking'));
    });
  });

  group('TacticalSetup Tests', () {
    late TacticalSetup validSetup;

    setUp(() {
      validSetup = const TacticalSetup(
        formation: Formation.f442,
        attackingMentality: AttackingMentality.balanced,
        defensiveStyle: DefensiveStyle.zonal,
        attackingStyle: AttackingStyle.possession,
        width: 50,
        tempo: 60,
        defensiveLine: 55,
        pressing: 45,
      );
    });

    test('should create valid tactical setup', () {
      expect(validSetup.formation, equals(Formation.f442));
      expect(validSetup.attackingMentality, equals(AttackingMentality.balanced));
      expect(validSetup.defensiveStyle, equals(DefensiveStyle.zonal));
      expect(validSetup.attackingStyle, equals(AttackingStyle.possession));
      expect(validSetup.width, equals(50));
      expect(validSetup.tempo, equals(60));
      expect(validSetup.defensiveLine, equals(55));
      expect(validSetup.pressing, equals(45));
    });

    test('should validate tactical setup parameters', () {
      expect(validSetup.isValid, isTrue);

      // Test invalid width
      final invalidWidth = validSetup.copyWith(width: 0);
      expect(invalidWidth.isValid, isFalse);

      final invalidWidth2 = validSetup.copyWith(width: 101);
      expect(invalidWidth2.isValid, isFalse);

      // Test invalid tempo
      final invalidTempo = validSetup.copyWith(tempo: 0);
      expect(invalidTempo.isValid, isFalse);

      // Test invalid defensive line
      final invalidLine = validSetup.copyWith(defensiveLine: 101);
      expect(invalidLine.isValid, isFalse);

      // Test invalid pressing
      final invalidPressing = validSetup.copyWith(pressing: 0);
      expect(invalidPressing.isValid, isFalse);
    });

    test('should convert attacking mentality to numerical value', () {
      expect(validSetup.copyWith(attackingMentality: AttackingMentality.ultraDefensive).attackingMentalityValue, equals(1));
      expect(validSetup.copyWith(attackingMentality: AttackingMentality.defensive).attackingMentalityValue, equals(2));
      expect(validSetup.copyWith(attackingMentality: AttackingMentality.balanced).attackingMentalityValue, equals(3));
      expect(validSetup.copyWith(attackingMentality: AttackingMentality.attacking).attackingMentalityValue, equals(4));
      expect(validSetup.copyWith(attackingMentality: AttackingMentality.ultraAttacking).attackingMentalityValue, equals(5));
    });

    test('should calculate tactical effectiveness correctly', () {
      // Test with good chemistry and manager
      double effectiveness = validSetup.calculateTacticalEffectiveness(
        teamChemistry: 80,
        managerRating: 75,
      );
      expect(effectiveness, greaterThan(0.8));
      expect(effectiveness, lessThanOrEqualTo(1.2));

      // Test with poor chemistry and manager
      effectiveness = validSetup.calculateTacticalEffectiveness(
        teamChemistry: 20,
        managerRating: 30,
      );
      expect(effectiveness, greaterThanOrEqualTo(0.8));
      expect(effectiveness, lessThan(1.0));

      // Test with excellent chemistry and manager
      effectiveness = validSetup.calculateTacticalEffectiveness(
        teamChemistry: 100,
        managerRating: 100,
      );
      expect(effectiveness, greaterThan(1.0));
      expect(effectiveness, lessThanOrEqualTo(1.2));
    });

    test('should penalize tactical imbalances', () {
      // Ultra attacking with low defensive line
      final imbalanced1 = validSetup.copyWith(
        attackingMentality: AttackingMentality.ultraAttacking,
        defensiveLine: 20,
      );
      final effectiveness1 = imbalanced1.calculateTacticalEffectiveness(
        teamChemistry: 80,
        managerRating: 80,
      );

      // Balanced setup for comparison
      final balanced = validSetup;
      final effectiveness2 = balanced.calculateTacticalEffectiveness(
        teamChemistry: 80,
        managerRating: 80,
      );

      expect(effectiveness1, lessThan(effectiveness2));

      // Ultra defensive with high pressing
      final imbalanced2 = validSetup.copyWith(
        attackingMentality: AttackingMentality.ultraDefensive,
        pressing: 80,
      );
      final effectiveness3 = imbalanced2.calculateTacticalEffectiveness(
        teamChemistry: 80,
        managerRating: 80,
      );

      expect(effectiveness3, lessThan(effectiveness2));
    });

    test('should return minimum effectiveness for invalid setup', () {
      final invalid = validSetup.copyWith(width: 0);
      final effectiveness = invalid.calculateTacticalEffectiveness(
        teamChemistry: 100,
        managerRating: 100,
      );
      expect(effectiveness, equals(0.8));
    });

    test('should create copy with updated values', () {
      final updated = validSetup.copyWith(
        formation: Formation.f433,
        width: 80,
        tempo: 90,
      );

      expect(updated.formation, equals(Formation.f433));
      expect(updated.width, equals(80));
      expect(updated.tempo, equals(90));
      expect(updated.attackingMentality, equals(validSetup.attackingMentality));
      expect(updated.defensiveStyle, equals(validSetup.defensiveStyle));
    });

    test('should support JSON serialization', () {
      final json = validSetup.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['formation'], equals('4-4-2'));
      expect(json['attackingMentality'], equals('balanced'));
      expect(json['width'], equals(50));

      final restored = TacticalSetup.fromJson(json);
      expect(restored, equals(validSetup));
    });

    test('should support equality comparison', () {
      final setup1 = validSetup;
      final setup2 = const TacticalSetup(
        formation: Formation.f442,
        attackingMentality: AttackingMentality.balanced,
        defensiveStyle: DefensiveStyle.zonal,
        attackingStyle: AttackingStyle.possession,
        width: 50,
        tempo: 60,
        defensiveLine: 55,
        pressing: 45,
      );
      final setup3 = validSetup.copyWith(width: 60);

      expect(setup1, equals(setup2));
      expect(setup1, isNot(equals(setup3)));
      expect(setup1.hashCode, equals(setup2.hashCode));
      expect(setup1.hashCode, isNot(equals(setup3.hashCode)));
    });

    test('should have meaningful string representation', () {
      final str = validSetup.toString();
      expect(str, contains('TacticalSetup'));
      expect(str, contains('f442'));
      expect(str, contains('balanced'));
      expect(str, contains('50'));
    });
  });

  group('PlayerRole Tests', () {
    late PlayerRole validRole;

    setUp(() {
      validRole = const PlayerRole(
        position: PlayerPosition.centreMidfielder,
        attackingFreedom: 60,
        defensiveWork: 70,
        width: 50,
        creativeFreedom: 65,
      );
    });

    test('should create valid player role', () {
      expect(validRole.position, equals(PlayerPosition.centreMidfielder));
      expect(validRole.attackingFreedom, equals(60));
      expect(validRole.defensiveWork, equals(70));
      expect(validRole.width, equals(50));
      expect(validRole.creativeFreedom, equals(65));
    });

    test('should validate player role parameters', () {
      expect(validRole.isValid, isTrue);

      // Test invalid parameters
      final invalidAttacking = validRole.copyWith(attackingFreedom: 0);
      expect(invalidAttacking.isValid, isFalse);

      final invalidDefensive = validRole.copyWith(defensiveWork: 101);
      expect(invalidDefensive.isValid, isFalse);

      final invalidWidth = validRole.copyWith(width: 0);
      expect(invalidWidth.isValid, isFalse);

      final invalidCreative = validRole.copyWith(creativeFreedom: 101);
      expect(invalidCreative.isValid, isFalse);
    });

    test('should calculate role suitability for goalkeeper', () {
      final gkRole = validRole.copyWith(position: PlayerPosition.goalkeeper);
      
      // Good technical goalkeeper
      double suitability = gkRole.calculateRoleSuitability(
        playerAttacking: 30,
        playerDefending: 40,
        playerTechnical: 90,
        playerPhysical: 60,
      );
      expect(suitability, greaterThan(0.8));

      // Poor technical goalkeeper
      suitability = gkRole.calculateRoleSuitability(
        playerAttacking: 30,
        playerDefending: 40,
        playerTechnical: 30,
        playerPhysical: 60,
      );
      expect(suitability, lessThan(0.5));
    });

    test('should calculate role suitability for defender', () {
      final cbRole = validRole.copyWith(position: PlayerPosition.centreBack);
      
      // Good defending and physical center back
      double suitability = cbRole.calculateRoleSuitability(
        playerAttacking: 30,
        playerDefending: 85,
        playerTechnical: 60,
        playerPhysical: 80,
      );
      expect(suitability, greaterThan(0.7));

      // Poor defending center back
      suitability = cbRole.calculateRoleSuitability(
        playerAttacking: 30,
        playerDefending: 40,
        playerTechnical: 60,
        playerPhysical: 50,
      );
      expect(suitability, lessThan(0.6));
    });

    test('should calculate role suitability for midfielder', () {
      final cmRole = validRole.copyWith(position: PlayerPosition.centreMidfielder);
      
      // Well-balanced midfielder
      double suitability = cmRole.calculateRoleSuitability(
        playerAttacking: 70,
        playerDefending: 70,
        playerTechnical: 80,
        playerPhysical: 60,
      );
      expect(suitability, greaterThan(0.6));

      // Poorly balanced midfielder
      suitability = cmRole.calculateRoleSuitability(
        playerAttacking: 30,
        playerDefending: 30,
        playerTechnical: 30,
        playerPhysical: 30,
      );
      expect(suitability, lessThan(0.4));
    });

    test('should calculate role suitability for striker', () {
      final strikerRole = validRole.copyWith(position: PlayerPosition.striker);
      
      // Good attacking striker
      double suitability = strikerRole.calculateRoleSuitability(
        playerAttacking: 90,
        playerDefending: 30,
        playerTechnical: 75,
        playerPhysical: 70,
      );
      expect(suitability, greaterThan(0.7));

      // Poor attacking striker
      suitability = strikerRole.calculateRoleSuitability(
        playerAttacking: 40,
        playerDefending: 30,
        playerTechnical: 50,
        playerPhysical: 70,
      );
      expect(suitability, lessThan(0.5));
    });

    test('should penalize role mismatches', () {
      final highAttackingRole = validRole.copyWith(attackingFreedom: 80);
      
      // Player with low attacking but high attacking freedom role
      double suitability = highAttackingRole.calculateRoleSuitability(
        playerAttacking: 40,
        playerDefending: 70,
        playerTechnical: 60,
        playerPhysical: 60,
      );

      // Same player with lower attacking freedom role
      final lowAttackingRole = validRole.copyWith(attackingFreedom: 40);
      double suitability2 = lowAttackingRole.calculateRoleSuitability(
        playerAttacking: 40,
        playerDefending: 70,
        playerTechnical: 60,
        playerPhysical: 60,
      );

      expect(suitability, lessThan(suitability2));

      // Test defensive work mismatch
      final highDefensiveRole = validRole.copyWith(defensiveWork: 80);
      
      suitability = highDefensiveRole.calculateRoleSuitability(
        playerAttacking: 60,
        playerDefending: 40,
        playerTechnical: 60,
        playerPhysical: 60,
      );

      final lowDefensiveRole = validRole.copyWith(defensiveWork: 40);
      suitability2 = lowDefensiveRole.calculateRoleSuitability(
        playerAttacking: 60,
        playerDefending: 40,
        playerTechnical: 60,
        playerPhysical: 60,
      );

      expect(suitability, lessThan(suitability2));
    });

    test('should return default suitability for invalid role', () {
      final invalid = validRole.copyWith(attackingFreedom: 0);
      final suitability = invalid.calculateRoleSuitability(
        playerAttacking: 80,
        playerDefending: 80,
        playerTechnical: 80,
        playerPhysical: 80,
      );
      expect(suitability, equals(0.5));
    });

    test('should create copy with updated values', () {
      final updated = validRole.copyWith(
        position: PlayerPosition.striker,
        attackingFreedom: 90,
        defensiveWork: 30,
      );

      expect(updated.position, equals(PlayerPosition.striker));
      expect(updated.attackingFreedom, equals(90));
      expect(updated.defensiveWork, equals(30));
      expect(updated.width, equals(validRole.width));
      expect(updated.creativeFreedom, equals(validRole.creativeFreedom));
    });

    test('should support JSON serialization', () {
      final json = validRole.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['position'], equals('centre-midfielder'));
      expect(json['attackingFreedom'], equals(60));
      expect(json['defensiveWork'], equals(70));

      final restored = PlayerRole.fromJson(json);
      expect(restored, equals(validRole));
    });

    test('should support equality comparison', () {
      final role1 = validRole;
      final role2 = const PlayerRole(
        position: PlayerPosition.centreMidfielder,
        attackingFreedom: 60,
        defensiveWork: 70,
        width: 50,
        creativeFreedom: 65,
      );
      final role3 = validRole.copyWith(attackingFreedom: 80);

      expect(role1, equals(role2));
      expect(role1, isNot(equals(role3)));
      expect(role1.hashCode, equals(role2.hashCode));
      expect(role1.hashCode, isNot(equals(role3.hashCode)));
    });

    test('should have meaningful string representation', () {
      final str = validRole.toString();
      expect(str, contains('PlayerRole'));
      expect(str, contains('centreMidfielder'));
      expect(str, contains('60'));
      expect(str, contains('70'));
    });
  });

  group('PlayerPosition Tests', () {
    test('should cover all essential football positions', () {
      expect(PlayerPosition.values, contains(PlayerPosition.goalkeeper));
      expect(PlayerPosition.values, contains(PlayerPosition.centreBack));
      expect(PlayerPosition.values, contains(PlayerPosition.leftBack));
      expect(PlayerPosition.values, contains(PlayerPosition.rightBack));
      expect(PlayerPosition.values, contains(PlayerPosition.wingBack));
      expect(PlayerPosition.values, contains(PlayerPosition.defensiveMidfielder));
      expect(PlayerPosition.values, contains(PlayerPosition.centreMidfielder));
      expect(PlayerPosition.values, contains(PlayerPosition.attackingMidfielder));
      expect(PlayerPosition.values, contains(PlayerPosition.leftWinger));
      expect(PlayerPosition.values, contains(PlayerPosition.rightWinger));
      expect(PlayerPosition.values, contains(PlayerPosition.striker));
    });
  });

  group('Edge Cases and Integration Tests', () {
    test('should handle extreme tactical setups', () {
      final extremeSetup = const TacticalSetup(
        formation: Formation.f532,
        attackingMentality: AttackingMentality.ultraAttacking,
        defensiveStyle: DefensiveStyle.highPress,
        attackingStyle: AttackingStyle.counterAttack,
        width: 100,
        tempo: 100,
        defensiveLine: 100,
        pressing: 100,
      );

      expect(extremeSetup.isValid, isTrue);
      
      final effectiveness = extremeSetup.calculateTacticalEffectiveness(
        teamChemistry: 50,
        managerRating: 50,
      );
      expect(effectiveness, greaterThanOrEqualTo(0.8));
      expect(effectiveness, lessThanOrEqualTo(1.2));
    });

    test('should handle all formation types', () {
      for (final formation in Formation.values) {
        final setup = TacticalSetup(
          formation: formation,
          attackingMentality: AttackingMentality.balanced,
          defensiveStyle: DefensiveStyle.zonal,
          attackingStyle: AttackingStyle.possession,
          width: 50,
          tempo: 50,
          defensiveLine: 50,
          pressing: 50,
        );
        expect(setup.isValid, isTrue);
      }
    });

    test('should handle all position types in player roles', () {
      for (final position in PlayerPosition.values) {
        final role = PlayerRole(
          position: position,
          attackingFreedom: 50,
          defensiveWork: 50,
          width: 50,
          creativeFreedom: 50,
        );
        
        expect(role.isValid, isTrue);
        
        final suitability = role.calculateRoleSuitability(
          playerAttacking: 60,
          playerDefending: 60,
          playerTechnical: 60,
          playerPhysical: 60,
        );
        
        expect(suitability, greaterThan(0.0));
        expect(suitability, lessThanOrEqualTo(1.0));
      }
    });
  });
}
