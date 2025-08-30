import 'package:test/test.dart';
import '../../lib/src/systems/game_state.dart';
import '../../lib/src/models/league.dart';
import '../../lib/src/models/team.dart';
import '../helpers/test_data_builders.dart';

void main() {
  group('GameState', () {
    late League testLeague;
    late Team playerTeam;

    setUp(() {
      testLeague = TestDataBuilders.createTestLeague(teamCount: 4);
      playerTeam = testLeague.teams.first;
    });

    group('initialization', () {
      test('should create valid GameState with required parameters', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        expect(gameState.league, equals(testLeague));
        expect(gameState.playerTeamId, equals(playerTeam.id));
        expect(gameState.currentDate, equals(DateTime(2024, 8, 1)));
        expect(gameState.currentDay, equals(1));
        expect(gameState.currentSeason, equals(1));
      });

      test('should initialize with valid player team from league', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        expect(gameState.playerTeam, equals(playerTeam));
      });

      test('should throw error when player team not found in league', () {
        expect(
          () => GameState(
            league: testLeague,
            playerTeamId: 'non-existent-team',
            currentDate: DateTime(2024, 8, 1),
            currentDay: 1,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when current day is less than 1', () {
        expect(
          () => GameState(
            league: testLeague,
            playerTeamId: playerTeam.id,
            currentDate: DateTime(2024, 8, 1),
            currentDay: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('factory constructors', () {
      test('should initialize new game state correctly', () {
        final gameState = GameState.initialize(
          league: testLeague,
          playerTeamId: playerTeam.id,
          startDate: DateTime(2024, 8, 1),
        );

        expect(gameState.league, equals(testLeague));
        expect(gameState.playerTeamId, equals(playerTeam.id));
        expect(gameState.currentDate, equals(DateTime(2024, 8, 1)));
        expect(gameState.currentDay, equals(1));
        expect(gameState.currentSeason, equals(1));
      });

      test('should create from save data correctly', () {
        final saveData = {
          'league': testLeague.toJson(),
          'playerTeamId': playerTeam.id,
          'currentDate': DateTime(2024, 8, 15).toIso8601String(),
          'currentDay': 15,
          'currentSeason': 1,
        };

        final gameState = GameState.fromSaveData(saveData);

        expect(gameState.playerTeamId, equals(playerTeam.id));
        expect(gameState.currentDate, equals(DateTime(2024, 8, 15)));
        expect(gameState.currentDay, equals(15));
        expect(gameState.currentSeason, equals(1));
      });
    });

    group('computed properties', () {
      test('should return correct day of week', () {
        // August 1, 2024 is a Thursday
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1), // Thursday
          currentDay: 1,
        );

        expect(gameState.dayOfWeek, equals('Thursday'));
      });

      test('should calculate correct week number', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 15,
        );

        expect(gameState.currentWeek, equals(3)); // Day 15 = Week 3
      });

      test('should determine if it is match day', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 3), // Saturday
          currentDay: 3,
        );

        // Mock having a match on this date
        expect(gameState.isMatchDay, isFalse); // No matches scheduled yet
      });
    });

    group('state mutations', () {
      test('should advance day correctly', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        final nextState = gameState.advanceDay();

        expect(nextState.currentDay, equals(2));
        expect(nextState.currentDate, equals(DateTime(2024, 8, 2)));
        expect(nextState.currentSeason, equals(1));
      });

      test('should advance to next season correctly', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 365, // End of season
        );

        final nextState = gameState.advanceToNextSeason();

        expect(nextState.currentSeason, equals(2));
        expect(nextState.currentDay, equals(1));
        expect(nextState.currentDate.year, equals(2025));
      });

      test('should update league correctly', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        final newLeague = TestDataBuilders.createTestLeague(
          id: 'updated-league',
          teamCount: 6,
        );

        final updatedState = gameState.updateLeague(newLeague);

        expect(updatedState.league, equals(newLeague));
        expect(updatedState.currentDay, equals(1));
        expect(updatedState.currentDate, equals(DateTime(2024, 8, 1)));
      });
    });

    group('serialization', () {
      test('should serialize to JSON correctly', () {
        final gameState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        final json = gameState.toJson();

        expect(json['playerTeamId'], equals(playerTeam.id));
        expect(json['currentDate'], equals(DateTime(2024, 8, 1).toIso8601String()));
        expect(json['currentDay'], equals(1));
        expect(json['currentSeason'], equals(1));
        expect(json['league'], isA<Map<String, dynamic>>());
      });

      test('should deserialize from JSON correctly', () {
        final originalState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        final json = originalState.toJson();
        final deserializedState = GameState.fromJson(json);

        expect(deserializedState.playerTeamId, equals(originalState.playerTeamId));
        expect(deserializedState.currentDate, equals(originalState.currentDate));
        expect(deserializedState.currentDay, equals(originalState.currentDay));
        expect(deserializedState.currentSeason, equals(originalState.currentSeason));
      });
    });

    group('validation', () {
      test('should validate game state integrity', () {
        final validState = GameState(
          league: testLeague,
          playerTeamId: playerTeam.id,
          currentDate: DateTime(2024, 8, 1),
          currentDay: 1,
        );

        expect(validState.isValid, isTrue);
      });

      test('should detect invalid state when player team missing', () {
        final invalidLeague = League(
          id: 'empty-league',
          name: 'Empty League',
          country: 'Test',
          teams: [], // No teams
        );

        expect(
          () => GameState(
            league: invalidLeague,
            playerTeamId: 'missing-team',
            currentDate: DateTime(2024, 8, 1),
            currentDay: 1,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
