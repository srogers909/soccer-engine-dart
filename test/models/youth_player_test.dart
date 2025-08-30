import 'package:test/test.dart';
import '../../lib/src/models/youth_player.dart';
import '../../lib/src/models/player.dart';

void main() {
  group('YouthPlayer Model Tests', () {
    group('Constructor and Basic Properties', () {
      test('should create youth player with required properties', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Young Talent',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 7,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        expect(youthPlayer.id, equals('youth1'));
        expect(youthPlayer.name, equals('Young Talent'));
        expect(youthPlayer.age, equals(16));
        expect(youthPlayer.position, equals(PlayerPosition.midfielder));
        expect(youthPlayer.potential, equals(85));
        expect(youthPlayer.developmentRate, equals(7));
        expect(youthPlayer.academyJoinDate, equals(DateTime(2024, 1, 1)));
        expect(youthPlayer.graduationEligible, isFalse);
        expect(youthPlayer.specialties, isEmpty);
        expect(youthPlayer.mentalMaturity, equals(50));
      });

      test('should use default values when optional parameters not provided', () {
        final youthPlayer = YouthPlayer(
          id: 'youth2',
          name: 'Default Youth',
          age: 17,
          position: PlayerPosition.forward,
          potential: 75,
          developmentRate: 5,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        expect(youthPlayer.technical, equals(30)); // Lower than senior default
        expect(youthPlayer.physical, equals(30));
        expect(youthPlayer.mental, equals(30));
        expect(youthPlayer.form, equals(7));
        expect(youthPlayer.fitness, equals(100));
        expect(youthPlayer.graduationEligible, isFalse);
        expect(youthPlayer.specialties, isEmpty);
        expect(youthPlayer.mentalMaturity, equals(50));
      });
    });

    group('Validation', () {
      test('should throw when potential is less than current overall rating', () {
        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Invalid Youth',
            age: 16,
            position: PlayerPosition.midfielder,
            potential: 40, // Less than default technical+physical+mental average
            developmentRate: 5,
            academyJoinDate: DateTime(2024, 1, 1),
            technical: 50,
            physical: 50,
            mental: 50,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when development rate is invalid', () {
        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Invalid Youth',
            age: 16,
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 0, // Invalid
            academyJoinDate: DateTime(2024, 1, 1),
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Invalid Youth',
            age: 16,
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 11, // Invalid
            academyJoinDate: DateTime(2024, 1, 1),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when age is outside youth range', () {
        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Too Young',
            age: 13, // Too young
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 5,
            academyJoinDate: DateTime(2024, 1, 1),
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Too Old',
            age: 19, // Too old for youth
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 5,
            academyJoinDate: DateTime(2024, 1, 1),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when mental maturity is invalid', () {
        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Invalid Maturity',
            age: 16,
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 5,
            academyJoinDate: DateTime(2024, 1, 1),
            mentalMaturity: -1,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthPlayer(
            id: 'youth1',
            name: 'Invalid Maturity',
            age: 16,
            position: PlayerPosition.midfielder,
            potential: 80,
            developmentRate: 5,
            academyJoinDate: DateTime(2024, 1, 1),
            mentalMaturity: 101,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Development Methods', () {
      test('should develop player attributes correctly', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Developing Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          technical: 40,
          physical: 35,
          mental: 30,
        );

        final developed = youthPlayer.developPlayer(
          technicalGain: 3,
          physicalGain: 2,
          mentalGain: 4,
        );

        expect(developed.technical, equals(43));
        expect(developed.physical, equals(37));
        expect(developed.mental, equals(34));
        expect(developed.potential, equals(85)); // Should remain same
      });

      test('should not exceed potential when developing', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Near Potential Youth',
          age: 18,
          position: PlayerPosition.midfielder,
          potential: 75,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          technical: 74,
          physical: 74,
          mental: 74,
        );

        final developed = youthPlayer.developPlayer(
          technicalGain: 5,
          physicalGain: 5,
          mentalGain: 5,
        );

        expect(developed.technical, equals(75)); // Capped at potential
        expect(developed.physical, equals(75));
        expect(developed.mental, equals(75));
      });

      test('should update graduation eligibility', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Graduating Youth',
          age: 17,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          mentalMaturity: 60,
        );

        final updated = youthPlayer.updateGraduationEligibility(true);
        expect(updated.graduationEligible, isTrue);
        expect(updated.id, equals(youthPlayer.id)); // Other properties unchanged
      });

      test('should update mental maturity', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Maturing Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          mentalMaturity: 40,
        );

        final matured = youthPlayer.updateMentalMaturity(55);
        expect(matured.mentalMaturity, equals(55));
        expect(matured.id, equals(youthPlayer.id)); // Other properties unchanged
      });
    });

    group('Conversion to Senior Player', () {
      test('should convert to senior player correctly', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Ready for Senior',
          age: 18,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          technical: 65,
          physical: 60,
          mental: 55,
          form: 8,
          fitness: 95,
          graduationEligible: true,
        );

        final seniorPlayer = youthPlayer.toSeniorPlayer();

        expect(seniorPlayer.id, equals('youth1'));
        expect(seniorPlayer.name, equals('Ready for Senior'));
        expect(seniorPlayer.age, equals(18));
        expect(seniorPlayer.position, equals(PlayerPosition.midfielder));
        expect(seniorPlayer.technical, equals(65));
        expect(seniorPlayer.physical, equals(60));
        expect(seniorPlayer.mental, equals(55));
        expect(seniorPlayer.form, equals(8));
        expect(seniorPlayer.fitness, equals(95));
      });
    });

    group('Specialties Management', () {
      test('should add specialty correctly', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Specialized Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        final specialized = youthPlayer.addSpecialty(YouthSpecialty.pace);
        expect(specialized.specialties, contains(YouthSpecialty.pace));
        expect(specialized.specialties.length, equals(1));
      });

      test('should not add duplicate specialties', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Specialized Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          specialties: [YouthSpecialty.pace],
        );

        final specialized = youthPlayer.addSpecialty(YouthSpecialty.pace);
        expect(specialized.specialties.length, equals(1));
      });

      test('should remove specialty correctly', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Specialized Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          specialties: [YouthSpecialty.pace, YouthSpecialty.technical],
        );

        final updated = youthPlayer.removeSpecialty(YouthSpecialty.pace);
        expect(updated.specialties, isNot(contains(YouthSpecialty.pace)));
        expect(updated.specialties, contains(YouthSpecialty.technical));
        expect(updated.specialties.length, equals(1));
      });
    });

    group('Time in Academy', () {
      test('should calculate time in academy correctly', () {
        final joinDate = DateTime(2024, 1, 1);
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Academy Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: joinDate,
        );

        final timeInAcademy = youthPlayer.timeInAcademy(DateTime(2024, 7, 1));
        expect(timeInAcademy.inDays, equals(181)); // Approximately 6 months
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'JSON Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          technical: 45,
          physical: 40,
          mental: 35,
          specialties: [YouthSpecialty.pace],
          graduationEligible: true,
          mentalMaturity: 65,
        );

        final json = youthPlayer.toJson();

        expect(json['id'], equals('youth1'));
        expect(json['name'], equals('JSON Youth'));
        expect(json['age'], equals(16));
        expect(json['position'], equals('midfielder'));
        expect(json['potential'], equals(85));
        expect(json['developmentRate'], equals(8));
        expect(json['academyJoinDate'], isA<String>());
        expect(json['technical'], equals(45));
        expect(json['physical'], equals(40));
        expect(json['mental'], equals(35));
        expect(json['graduationEligible'], isTrue);
        expect(json['mentalMaturity'], equals(65));
        expect(json['specialties'], isA<List>());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'youth1',
          'name': 'JSON Youth',
          'age': 16,
          'position': 'midfielder',
          'potential': 85,
          'developmentRate': 8,
          'academyJoinDate': '2024-01-01T00:00:00.000',
          'technical': 45,
          'physical': 40,
          'mental': 35,
          'form': 7,
          'fitness': 100,
          'graduationEligible': true,
          'mentalMaturity': 65,
          'specialties': ['pace']
        };

        final youthPlayer = YouthPlayer.fromJson(json);

        expect(youthPlayer.id, equals('youth1'));
        expect(youthPlayer.name, equals('JSON Youth'));
        expect(youthPlayer.age, equals(16));
        expect(youthPlayer.position, equals(PlayerPosition.midfielder));
        expect(youthPlayer.potential, equals(85));
        expect(youthPlayer.developmentRate, equals(8));
        expect(youthPlayer.academyJoinDate, equals(DateTime(2024, 1, 1)));
        expect(youthPlayer.technical, equals(45));
        expect(youthPlayer.physical, equals(40));
        expect(youthPlayer.mental, equals(35));
        expect(youthPlayer.graduationEligible, isTrue);
        expect(youthPlayer.mentalMaturity, equals(65));
        expect(youthPlayer.specialties, contains(YouthSpecialty.pace));
      });
    });

    group('Equality and String Representation', () {
      test('should implement equality correctly', () {
        final youthPlayer1 = YouthPlayer(
          id: 'youth1',
          name: 'Equal Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        final youthPlayer2 = YouthPlayer(
          id: 'youth1',
          name: 'Equal Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        expect(youthPlayer1, equals(youthPlayer2));
        expect(youthPlayer1.hashCode, equals(youthPlayer2.hashCode));
      });

      test('should have meaningful string representation', () {
        final youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'String Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 8,
          academyJoinDate: DateTime(2024, 1, 1),
          technical: 45,
          physical: 40,
          mental: 35,
        );

        final str = youthPlayer.toString();
        expect(str, contains('String Youth'));
        expect(str, contains('youth1'));
        expect(str, contains('16'));
        expect(str, contains('midfielder'));
        expect(str, contains('85')); // potential
      });
    });
  });
}
