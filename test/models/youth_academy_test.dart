import 'package:test/test.dart';
import '../../lib/src/models/youth_academy.dart';
import '../../lib/src/models/youth_player.dart';
import 'package:soccer_utilities/src/models/player.dart';

void main() {
  group('YouthAcademy Model Tests', () {
    group('Constructor and Basic Properties', () {
      test('should create youth academy with required properties', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 75,
          coachingStaff: 80,
          reputation: 60,
          capacity: 50,
          yearlyBudget: 1000000,
        );

        expect(academy.id, equals('academy1'));
        expect(academy.name, equals('Test Academy'));
        expect(academy.facilities, equals(75));
        expect(academy.coachingStaff, equals(80));
        expect(academy.reputation, equals(60));
        expect(academy.capacity, equals(50));
        expect(academy.yearlyBudget, equals(1000000));
        expect(academy.focusAreas, isEmpty);
        expect(academy.youthPlayers, isEmpty);
        expect(academy.scouts, isEmpty);
      });

      test('should use default values when optional parameters not provided', () {
        final academy = YouthAcademy(
          id: 'academy2',
          name: 'Default Academy',
        );

        expect(academy.facilities, equals(50));
        expect(academy.coachingStaff, equals(50));
        expect(academy.reputation, equals(50));
        expect(academy.capacity, equals(30));
        expect(academy.yearlyBudget, equals(500000));
        expect(academy.focusAreas, isEmpty);
        expect(academy.youthPlayers, isEmpty);
        expect(academy.scouts, isEmpty);
      });
    });

    group('Validation', () {
      test('should throw when id is empty', () {
        expect(
          () => YouthAcademy(
            id: '',
            name: 'Test Academy',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when name is empty', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when facilities rating is invalid', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            facilities: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            facilities: 101,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when coaching staff rating is invalid', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            coachingStaff: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            coachingStaff: 101,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when reputation is invalid', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            reputation: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            reputation: 101,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when capacity is invalid', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            capacity: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            capacity: 101,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when yearly budget is negative', () {
        expect(
          () => YouthAcademy(
            id: 'academy1',
            name: 'Test Academy',
            yearlyBudget: -1,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Youth Player Management', () {
      late YouthAcademy academy;
      late YouthPlayer youthPlayer;

      setUp(() {
        academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          capacity: 30,
        );

        youthPlayer = YouthPlayer(
          id: 'youth1',
          name: 'Test Youth',
          age: 16,
          position: PlayerPosition.midfielder,
          potential: 85,
          developmentRate: 7,
          academyJoinDate: DateTime(2024, 1, 1),
        );
      });

      test('should add youth player successfully', () {
        final updatedAcademy = academy.addYouthPlayer(youthPlayer);

        expect(updatedAcademy.youthPlayers.length, equals(1));
        expect(updatedAcademy.youthPlayers.first.id, equals('youth1'));
        expect(updatedAcademy.currentCapacity, equals(1));
      });

      test('should throw when adding duplicate youth player', () {
        final academyWithPlayer = academy.addYouthPlayer(youthPlayer);

        expect(
          () => academyWithPlayer.addYouthPlayer(youthPlayer),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when academy is at capacity', () {
        final smallAcademy = YouthAcademy(
          id: 'small',
          name: 'Small Academy',
          capacity: 1,
        );

        final academyWithPlayer = smallAcademy.addYouthPlayer(youthPlayer);

        final anotherPlayer = YouthPlayer(
          id: 'youth2',
          name: 'Another Youth',
          age: 17,
          position: PlayerPosition.forward,
          potential: 80,
          developmentRate: 6,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        expect(
          () => academyWithPlayer.addYouthPlayer(anotherPlayer),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should remove youth player successfully', () {
        final academyWithPlayer = academy.addYouthPlayer(youthPlayer);
        final updatedAcademy = academyWithPlayer.removeYouthPlayer('youth1');

        expect(updatedAcademy.youthPlayers.length, equals(0));
        expect(updatedAcademy.currentCapacity, equals(0));
      });

      test('should not throw when removing non-existent player', () {
        expect(
          () => academy.removeYouthPlayer('nonexistent'),
          returnsNormally,
        );
      });

      test('should get youth players by position', () {
        final midfielder = youthPlayer;
        final forward = YouthPlayer(
          id: 'youth2',
          name: 'Forward Youth',
          age: 17,
          position: PlayerPosition.forward,
          potential: 80,
          developmentRate: 6,
          academyJoinDate: DateTime(2024, 1, 1),
        );

        final academyWithPlayers = academy
            .addYouthPlayer(midfielder)
            .addYouthPlayer(forward);

        final midfielders = academyWithPlayers.getYouthPlayersByPosition(PlayerPosition.midfielder);
        final forwards = academyWithPlayers.getYouthPlayersByPosition(PlayerPosition.forward);

        expect(midfielders.length, equals(1));
        expect(midfielders.first.id, equals('youth1'));
        expect(forwards.length, equals(1));
        expect(forwards.first.id, equals('youth2'));
      });
    });

    group('Scout Management', () {
      late YouthAcademy academy;
      late Scout scout;

      setUp(() {
        academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
        );

        scout = Scout(
          id: 'scout1',
          name: 'Test Scout',
          ability: 75,
          networkQuality: 80,
          specialization: ScoutSpecialization.technical,
          region: ScoutRegion.domestic,
          cost: 50000,
        );
      });

      test('should add scout successfully', () {
        final updatedAcademy = academy.addScout(scout);

        expect(updatedAcademy.scouts.length, equals(1));
        expect(updatedAcademy.scouts.first.id, equals('scout1'));
        expect(updatedAcademy.totalScoutCosts, equals(50000));
      });

      test('should throw when adding duplicate scout', () {
        final academyWithScout = academy.addScout(scout);

        expect(
          () => academyWithScout.addScout(scout),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should remove scout successfully', () {
        final academyWithScout = academy.addScout(scout);
        final updatedAcademy = academyWithScout.removeScout('scout1');

        expect(updatedAcademy.scouts.length, equals(0));
        expect(updatedAcademy.totalScoutCosts, equals(0));
      });

      test('should calculate total scout costs correctly', () {
        final scout2 = Scout(
          id: 'scout2',
          name: 'Scout 2',
          ability: 70,
          networkQuality: 75,
          specialization: ScoutSpecialization.physical,
          region: ScoutRegion.international,
          cost: 75000,
        );

        final academyWithScouts = academy
            .addScout(scout)
            .addScout(scout2);

        expect(academyWithScouts.totalScoutCosts, equals(125000));
      });
    });

    group('Focus Areas Management', () {
      test('should add focus area successfully', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
        );

        final updatedAcademy = academy.addFocusArea(TrainingFocus.technical);

        expect(updatedAcademy.focusAreas.length, equals(1));
        expect(updatedAcademy.focusAreas.first, equals(TrainingFocus.technical));
      });

      test('should not add duplicate focus areas', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          focusAreas: [TrainingFocus.technical],
        );

        final updatedAcademy = academy.addFocusArea(TrainingFocus.technical);

        expect(updatedAcademy.focusAreas.length, equals(1));
      });

      test('should remove focus area successfully', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          focusAreas: [TrainingFocus.technical, TrainingFocus.physical],
        );

        final updatedAcademy = academy.removeFocusArea(TrainingFocus.technical);

        expect(updatedAcademy.focusAreas.length, equals(1));
        expect(updatedAcademy.focusAreas.first, equals(TrainingFocus.physical));
      });
    });

    group('Academy Quality Calculations', () {
      test('should calculate overall quality correctly', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 80,
          coachingStaff: 75,
          reputation: 70,
        );

        final expectedQuality = ((80 + 75 + 70) / 3).round();
        expect(academy.overallQuality, equals(expectedQuality));
      });

      test('should calculate development effectiveness', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 80,
          coachingStaff: 90,
        );

        final effectiveness = academy.developmentEffectiveness;
        expect(effectiveness, greaterThan(0.0));
        expect(effectiveness, lessThanOrEqualTo(2.0));
      });

      test('should calculate scouting effectiveness', () {
        final scout1 = Scout(
          id: 'scout1',
          name: 'Scout 1',
          ability: 80,
          networkQuality: 75,
          specialization: ScoutSpecialization.technical,
          region: ScoutRegion.domestic,
          cost: 50000,
        );

        final scout2 = Scout(
          id: 'scout2',
          name: 'Scout 2',
          ability: 70,
          networkQuality: 85,
          specialization: ScoutSpecialization.mental,
          region: ScoutRegion.international,
          cost: 60000,
        );

        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          reputation: 75,
          scouts: [scout1, scout2],
        );

        final effectiveness = academy.scoutingEffectiveness;
        expect(effectiveness, greaterThan(0.0));
        expect(effectiveness, lessThanOrEqualTo(2.0));
      });
    });

    group('Budget Management', () {
      test('should calculate operational costs correctly', () {
        final scout = Scout(
          id: 'scout1',
          name: 'Test Scout',
          ability: 75,
          networkQuality: 80,
          specialization: ScoutSpecialization.technical,
          region: ScoutRegion.domestic,
          cost: 50000,
        );

        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 80,
          capacity: 40,
          scouts: [scout],
        );

        final operationalCosts = academy.calculateOperationalCosts();

        // Should include facility maintenance, scout costs, and base youth player costs
        expect(operationalCosts, greaterThan(0));
        expect(operationalCosts, greaterThan(50000)); // At least scout cost
      });

      test('should upgrade facilities correctly', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 60,
        );

        final upgradeCost = academy.calculateFacilityUpgradeCost(75);
        final upgradedAcademy = academy.upgradeFacilities(75);

        expect(upgradeCost, greaterThan(0));
        expect(upgradedAcademy.facilities, equals(75));
      });

      test('should throw when downgrading facilities', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'Test Academy',
          facilities: 80,
        );

        expect(
          () => academy.upgradeFacilities(70),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'JSON Academy',
          facilities: 80,
          coachingStaff: 75,
          reputation: 70,
          capacity: 40,
          yearlyBudget: 800000,
          focusAreas: [TrainingFocus.technical],
        );

        final json = academy.toJson();

        expect(json['id'], equals('academy1'));
        expect(json['name'], equals('JSON Academy'));
        expect(json['facilities'], equals(80));
        expect(json['coachingStaff'], equals(75));
        expect(json['reputation'], equals(70));
        expect(json['capacity'], equals(40));
        expect(json['yearlyBudget'], equals(800000));
        expect(json['focusAreas'], isA<List>());
        expect(json['youthPlayers'], isA<List>());
        expect(json['scouts'], isA<List>());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'academy1',
          'name': 'JSON Academy',
          'facilities': 80,
          'coachingStaff': 75,
          'reputation': 70,
          'capacity': 40,
          'yearlyBudget': 800000,
          'focusAreas': ['technical'],
          'youthPlayers': [],
          'scouts': [],
        };

        final academy = YouthAcademy.fromJson(json);

        expect(academy.id, equals('academy1'));
        expect(academy.name, equals('JSON Academy'));
        expect(academy.facilities, equals(80));
        expect(academy.coachingStaff, equals(75));
        expect(academy.reputation, equals(70));
        expect(academy.capacity, equals(40));
        expect(academy.yearlyBudget, equals(800000));
        expect(academy.focusAreas, contains(TrainingFocus.technical));
        expect(academy.youthPlayers, isEmpty);
        expect(academy.scouts, isEmpty);
      });
    });

    group('Equality and String Representation', () {
      test('should implement equality correctly', () {
        final academy1 = YouthAcademy(
          id: 'academy1',
          name: 'Equal Academy',
          facilities: 75,
        );

        final academy2 = YouthAcademy(
          id: 'academy1',
          name: 'Equal Academy',
          facilities: 75,
        );

        expect(academy1, equals(academy2));
        expect(academy1.hashCode, equals(academy2.hashCode));
      });

      test('should have meaningful string representation', () {
        final academy = YouthAcademy(
          id: 'academy1',
          name: 'String Academy',
          facilities: 75,
          capacity: 30,
        );

        final str = academy.toString();
        expect(str, contains('String Academy'));
        expect(str, contains('academy1'));
        expect(str, contains('75'));
        expect(str, contains('30'));
      });
    });
  });
}
