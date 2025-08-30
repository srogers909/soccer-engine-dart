import 'package:test/test.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_engine/src/models/player.dart';

void main() {
  group('Team Model Tests', () {
    late Player goalkeeper;
    late Player defender;
    late Player midfielder;
    late Player forward;

    setUp(() {
      goalkeeper = Player(
        id: 'gk-001',
        name: 'Test Goalkeeper',
        age: 25,
        position: PlayerPosition.goalkeeper,
        technical: 70,
        physical: 80,
        mental: 85,
      );

      defender = Player(
        id: 'df-001',
        name: 'Test Defender',
        age: 27,
        position: PlayerPosition.defender,
        technical: 65,
        physical: 85,
        mental: 80,
      );

      midfielder = Player(
        id: 'mf-001',
        name: 'Test Midfielder',
        age: 24,
        position: PlayerPosition.midfielder,
        technical: 90,
        physical: 75,
        mental: 85,
      );

      forward = Player(
        id: 'fw-001',
        name: 'Test Forward',
        age: 23,
        position: PlayerPosition.forward,
        technical: 85,
        physical: 80,
        mental: 75,
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create team with required properties', () {
        // Arrange
        const id = 'team-123';
        const name = 'Test FC';
        const city = 'Test City';
        const foundedYear = 1900;

        // Act
        final team = Team(
          id: id,
          name: name,
          city: city,
          foundedYear: foundedYear,
        );

        // Assert
        expect(team.id, equals(id));
        expect(team.name, equals(name));
        expect(team.city, equals(city));
        expect(team.foundedYear, equals(foundedYear));
        expect(team.players, isEmpty);
        expect(team.formation, equals(Formation.f442)); // Default formation
      });

      test('should have default stadium when not specified', () {
        // Act
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        // Assert
        expect(team.stadium, isNotNull);
        expect(team.stadium.name, contains(team.name));
        expect(team.stadium.capacity, greaterThan(0));
      });

      test('should allow custom stadium', () {
        // Arrange
        const stadium = Stadium(
          name: 'Custom Stadium',
          capacity: 80000,
          city: 'Stadium City',
        );

        // Act
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          stadium: stadium,
        );

        // Assert
        expect(team.stadium, equals(stadium));
      });
    });

    group('Validation', () {
      test('should throw when id is empty', () {
        expect(
          () => Team(
            id: '',
            name: 'Test FC',
            city: 'Test City',
            foundedYear: 1900,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when name is empty', () {
        expect(
          () => Team(
            id: 'test-id',
            name: '',
            city: 'Test City',
            foundedYear: 1900,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when city is empty', () {
        expect(
          () => Team(
            id: 'test-id',
            name: 'Test FC',
            city: '',
            foundedYear: 1900,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when founded year is invalid', () {
        expect(
          () => Team(
            id: 'test-id',
            name: 'Test FC',
            city: 'Test City',
            foundedYear: 1800, // Too early
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => Team(
            id: 'test-id',
            name: 'Test FC',
            city: 'Test City',
            foundedYear: 2050, // Future
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Player Management', () {
      test('should add player to squad', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        // Act
        final updatedTeam = team.addPlayer(midfielder);

        // Assert
        expect(updatedTeam.players, contains(midfielder));
        expect(updatedTeam.players.length, equals(1));
        expect(team.players, isEmpty); // Original team unchanged
      });

      test('should remove player from squad', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: [midfielder, forward],
        );

        // Act
        final updatedTeam = team.removePlayer(midfielder.id);

        // Assert
        expect(updatedTeam.players, isNot(contains(midfielder)));
        expect(updatedTeam.players, contains(forward));
        expect(updatedTeam.players.length, equals(1));
      });

      test('should not add duplicate player', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: [midfielder],
        );

        // Act & Assert
        expect(
          () => team.addPlayer(midfielder),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should not exceed maximum squad size', () {
        // Arrange
        final players = List.generate(
          30, // Maximum squad size
          (index) => Player(
            id: 'player-$index',
            name: 'Player $index',
            age: 25,
            position: PlayerPosition.midfielder,
          ),
        );

        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: players,
        );

        final extraPlayer = Player(
          id: 'extra-player',
          name: 'Extra Player',
          age: 25,
          position: PlayerPosition.forward,
        );

        // Act & Assert
        expect(
          () => team.addPlayer(extraPlayer),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Formation Management', () {
      test('should change formation', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        // Act
        final updatedTeam = team.setFormation(Formation.f433);

        // Assert
        expect(updatedTeam.formation, equals(Formation.f433));
        expect(team.formation, equals(Formation.f442)); // Original unchanged
      });

      test('should validate starting XI against formation', () {
        // Arrange
        final players = [
          goalkeeper,
          defender,
          Player(id: 'df2', name: 'Defender 2', age: 26, position: PlayerPosition.defender),
          Player(id: 'df3', name: 'Defender 3', age: 28, position: PlayerPosition.defender),
          Player(id: 'df4', name: 'Defender 4', age: 24, position: PlayerPosition.defender),
          midfielder,
          Player(id: 'mf2', name: 'Midfielder 2', age: 25, position: PlayerPosition.midfielder),
          Player(id: 'mf3', name: 'Midfielder 3', age: 27, position: PlayerPosition.midfielder),
          Player(id: 'mf4', name: 'Midfielder 4', age: 23, position: PlayerPosition.midfielder),
          forward,
          Player(id: 'fw2', name: 'Forward 2', age: 22, position: PlayerPosition.forward),
        ];

        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: players,
        );

        // Act
        final startingXI = players.take(11).toList();
        final updatedTeam = team.setStartingXI(startingXI);

        // Assert
        expect(updatedTeam.startingXI, equals(startingXI));
        expect(updatedTeam.startingXI.length, equals(11));
      });

      test('should throw when starting XI has wrong number of players', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: [midfielder, forward],
        );

        // Act & Assert
        expect(
          () => team.setStartingXI([midfielder, forward]), // Only 2 players
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when starting XI contains player not in squad', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: [midfielder],
        );

        final outsidePlayer = Player(
          id: 'outside',
          name: 'Outside Player',
          age: 25,
          position: PlayerPosition.forward,
        );

        final invalidXI = List.generate(11, (index) => 
          index == 0 ? outsidePlayer : midfielder);

        // Act & Assert
        expect(
          () => team.setStartingXI(invalidXI),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Team Statistics', () {
      test('should calculate overall team rating', () {
        // Arrange
        final players = [goalkeeper, defender, midfielder, forward];
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: players,
        );

        // Act
        final rating = team.overallRating;

        // Assert
        expect(rating, isA<int>());
        expect(rating, greaterThan(0));
        expect(rating, lessThanOrEqualTo(100));
      });

      test('should calculate position-specific strengths', () {
        // Arrange
        final players = [goalkeeper, defender, midfielder, forward];
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: players,
        );

        // Act
        final strengths = team.positionStrengths;

        // Assert
        expect(strengths, contains(PlayerPosition.goalkeeper));
        expect(strengths, contains(PlayerPosition.defender));
        expect(strengths, contains(PlayerPosition.midfielder));
        expect(strengths, contains(PlayerPosition.forward));
        
        for (final position in strengths.keys) {
          expect(strengths[position], greaterThan(0));
          expect(strengths[position], lessThanOrEqualTo(100));
        }
      });

      test('should calculate team chemistry', () {
        // Arrange
        final players = [goalkeeper, defender, midfielder, forward];
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: players,
        );

        // Act
        final chemistry = team.chemistry;

        // Assert
        expect(chemistry, isA<int>());
        expect(chemistry, greaterThanOrEqualTo(0));
        expect(chemistry, lessThanOrEqualTo(100));
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all properties match', () {
        // Arrange
        final team1 = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        final team2 = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        // Act & Assert
        expect(team1, equals(team2));
        expect(team1.hashCode, equals(team2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final team1 = Team(
          id: 'test-id-1',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        final team2 = Team(
          id: 'test-id-2',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
        );

        // Act & Assert
        expect(team1, isNot(equals(team2)));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final team = Team(
          id: 'test-id',
          name: 'Test FC',
          city: 'Test City',
          foundedYear: 1900,
          players: [midfielder],
        );

        // Act
        final json = team.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['name'], equals('Test FC'));
        expect(json['city'], equals('Test City'));
        expect(json['foundedYear'], equals(1900));
        expect(json['players'], isA<List>());
        expect(json['formation'], equals('f442'));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'name': 'Test FC',
          'city': 'Test City',
          'foundedYear': 1900,
          'players': [midfielder.toJson()],
          'formation': 'f433',
          'stadium': {
            'name': 'Test Stadium',
            'capacity': 50000,
            'city': 'Test City',
          },
          'startingXI': [],
          'morale': 75,
        };

        // Act
        final team = Team.fromJson(json);

        // Assert
        expect(team.id, equals('test-id'));
        expect(team.name, equals('Test FC'));
        expect(team.city, equals('Test City'));
        expect(team.foundedYear, equals(1900));
        expect(team.players.length, equals(1));
        expect(team.formation, equals(Formation.f433));
        expect(team.morale, equals(75));
      });
    });
  });
}
