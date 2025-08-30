import 'package:test/test.dart';
import 'package:soccer_engine/src/models/gameweek.dart';
import 'package:soccer_engine/src/models/match.dart';
import 'package:soccer_engine/src/models/team.dart';

void main() {
  group('Gameweek Model Tests', () {
    late Team homeTeam;
    late Team awayTeam;
    late Team team3;
    late Team team4;
    late Match match1;
    late Match match2;
    late DateTime testDate;
    late Weather testWeather;

    setUp(() {
      testDate = DateTime(2025, 8, 31); // Use tomorrow's date
      
      testWeather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 60.0,
        windSpeed: 10.0,
      );

      final stadium1 = Stadium(
        name: 'Home Stadium',
        capacity: 50000,
        city: 'Home City',
      );

      final stadium2 = Stadium(
        name: 'Away Stadium',
        capacity: 45000,
        city: 'Away City',
      );

      final stadium3 = Stadium(
        name: 'Team 3 Stadium',
        capacity: 40000,
        city: 'City 3',
      );

      final stadium4 = Stadium(
        name: 'Team 4 Stadium',
        capacity: 35000,
        city: 'City 4',
      );

      homeTeam = Team(
        id: 'home-team',
        name: 'Home FC',
        city: 'Home City',
        foundedYear: 1900,
        stadium: stadium1,
      );

      awayTeam = Team(
        id: 'away-team',
        name: 'Away FC',
        city: 'Away City',
        foundedYear: 1905,
        stadium: stadium2,
      );

      team3 = Team(
        id: 'team-3',
        name: 'Team 3 FC',
        city: 'City 3',
        foundedYear: 1910,
        stadium: stadium3,
      );

      team4 = Team(
        id: 'team-4',
        name: 'Team 4 FC',
        city: 'City 4',
        foundedYear: 1915,
        stadium: stadium4,
      );

      match1 = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: testWeather,
        kickoffTime: testDate,
      );

      match2 = Match.create(
        id: 'match-2',
        homeTeam: team3,
        awayTeam: team4,
        weather: testWeather,
        kickoffTime: testDate.add(const Duration(hours: 2)),
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create gameweek with required properties', () {
        // Arrange
        const id = 'gw-123';
        const number = 1;
        const seasonId = 'season-456';

        // Act
        final gameweek = Gameweek(
          id: id,
          number: number,
          seasonId: seasonId,
          scheduledDate: testDate,
        );

        // Assert
        expect(gameweek.id, equals(id));
        expect(gameweek.number, equals(number));
        expect(gameweek.seasonId, equals(seasonId));
        expect(gameweek.scheduledDate, equals(testDate));
        expect(gameweek.matches, isEmpty);
        expect(gameweek.status, equals(GameweekStatus.scheduled)); // Default status
        expect(gameweek.name, isNull);
        expect(gameweek.isSpecial, isFalse);
      });

      test('should create gameweek with custom properties', () {
        // Arrange
        const name = 'Boxing Day Fixtures';
        final matches = [match1, match2];

        // Act
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: matches,
          status: GameweekStatus.inProgress,
          name: name,
          isSpecial: true,
        );

        // Assert
        expect(gameweek.matches.length, equals(2));
        expect(gameweek.status, equals(GameweekStatus.inProgress));
        expect(gameweek.name, equals(name));
        expect(gameweek.isSpecial, isTrue);
      });
    });

    group('Validation', () {
      test('should throw when id is empty', () {
        expect(
          () => Gameweek(
            id: '',
            number: 1,
            seasonId: 'season-456',
            scheduledDate: testDate,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when seasonId is empty', () {
        expect(
          () => Gameweek(
            id: 'gw-123',
            number: 1,
            seasonId: '',
            scheduledDate: testDate,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when number is not positive', () {
        expect(
          () => Gameweek(
            id: 'gw-123',
            number: 0,
            seasonId: 'season-456',
            scheduledDate: testDate,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => Gameweek(
            id: 'gw-123',
            number: -1,
            seasonId: 'season-456',
            scheduledDate: testDate,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when team appears in multiple matches', () {
        // Arrange
        final conflictMatch1 = Match.create(
          id: 'match-1',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: testWeather,
          kickoffTime: testDate,
        );

        final conflictMatch2 = Match.create(
          id: 'match-2',
          homeTeam: homeTeam, // Same team appears again
          awayTeam: team3,
          weather: testWeather,
          kickoffTime: testDate,
        );

        // Act & Assert
        expect(
          () => Gameweek(
            id: 'gw-123',
            number: 1,
            seasonId: 'season-456',
            scheduledDate: testDate,
            matches: [conflictMatch1, conflictMatch2],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Match Management', () {
      test('should add match to gameweek', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act
        final updatedGameweek = gameweek.addMatch(match1);

        // Assert
        expect(updatedGameweek.matches, contains(match1));
        expect(updatedGameweek.matches.length, equals(1));
        expect(gameweek.matches, isEmpty); // Original gameweek unchanged
      });

      test('should remove match from gameweek', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
        );

        // Act
        final updatedGameweek = gameweek.removeMatch(match1.id);

        // Assert
        expect(updatedGameweek.matches, isNot(contains(match1)));
        expect(updatedGameweek.matches, contains(match2));
        expect(updatedGameweek.matches.length, equals(1));
      });

      test('should not add match that creates team conflict', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1],
        );

        final conflictMatch = Match.create(
          id: 'conflict-match',
          homeTeam: homeTeam, // Same team as in match1
          awayTeam: team3,
          weather: testWeather,
          kickoffTime: testDate,
        );

        // Act & Assert
        expect(
          () => gameweek.addMatch(conflictMatch),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Status Management', () {
      test('should update gameweek status', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act
        final updatedGameweek = gameweek.updateStatus(GameweekStatus.completed);

        // Assert
        expect(updatedGameweek.status, equals(GameweekStatus.completed));
        expect(gameweek.status, equals(GameweekStatus.scheduled)); // Original unchanged
      });

      test('should update scheduled date', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        final newDate = testDate.add(const Duration(days: 7));

        // Act
        final updatedGameweek = gameweek.updateScheduledDate(newDate);

        // Assert
        expect(updatedGameweek.scheduledDate, equals(newDate));
        expect(gameweek.scheduledDate, equals(testDate)); // Original unchanged
      });
    });

    group('Match Status Checks', () {
      test('should determine if gameweek is completed', () {
        // Arrange
        final completedMatch1 = match1.copyWith(
          isCompleted: true,
          homeGoals: 2,
          awayGoals: 1,
        );

        final completedMatch2 = match2.copyWith(
          isCompleted: true,
          homeGoals: 0,
          awayGoals: 3,
        );

        final completedGameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [completedMatch1, completedMatch2],
        );

        final incompleteGameweek = Gameweek(
          id: 'gw-456',
          number: 2,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [completedMatch1, match2], // match2 not completed
        );

        final emptyGameweek = Gameweek(
          id: 'gw-789',
          number: 3,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act & Assert
        expect(completedGameweek.isCompleted, isTrue);
        expect(incompleteGameweek.isCompleted, isFalse);
        expect(emptyGameweek.isCompleted, isFalse);
      });

      test('should determine if gameweek has started', () {
        // Arrange
        final startedMatch = match1.copyWith(currentMinute: 15);

        final startedGameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [startedMatch, match2],
        );

        final notStartedGameweek = Gameweek(
          id: 'gw-456',
          number: 2,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2], // Both scheduled
        );

        // Act & Assert
        expect(startedGameweek.hasStarted, isTrue);
        expect(notStartedGameweek.hasStarted, isFalse);
      });

      test('should count matches by status', () {
        // Arrange
        final completedMatch = match1.copyWith(
          isCompleted: true,
          homeGoals: 1,
          awayGoals: 1,
          currentMinute: 90, // Match completed at 90 minutes
        );

        final inProgressMatch = match2.copyWith(currentMinute: 30);

        // Create a separate match that doesn't conflict with existing teams
        final extraMatch = Match.create(
          id: 'extra-match',
          homeTeam: Team(
            id: 'extra-home',
            name: 'Extra Home FC',
            city: 'Extra City',
            foundedYear: 1920,
            stadium: Stadium(
              name: 'Extra Stadium',
              capacity: 30000,
              city: 'Extra City',
            ),
          ),
          awayTeam: Team(
            id: 'extra-away',
            name: 'Extra Away FC',
            city: 'Extra City 2',
            foundedYear: 1925,
            stadium: Stadium(
              name: 'Extra Stadium 2',
              capacity: 25000,
              city: 'Extra City 2',
            ),
          ),
          weather: testWeather,
          kickoffTime: testDate.add(const Duration(hours: 4)),
        );

        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [completedMatch, inProgressMatch, extraMatch], // extraMatch is scheduled
        );

        // Act & Assert
        expect(gameweek.completedMatchesCount, equals(1));
        expect(gameweek.inProgressMatchesCount, equals(1));
        expect(gameweek.scheduledMatchesCount, equals(1));
      });
    });

    group('Team and Match Queries', () {
      test('should get participating teams', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
        );

        // Act
        final teams = gameweek.participatingTeams;

        // Assert
        expect(teams.length, equals(4));
        expect(teams, contains(homeTeam.id));
        expect(teams, contains(awayTeam.id));
        expect(teams, contains(team3.id));
        expect(teams, contains(team4.id));
      });

      test('should get matches for specific team', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
        );

        // Act
        final homeTeamMatches = gameweek.getMatchesForTeam(homeTeam.id);
        final team3Matches = gameweek.getMatchesForTeam(team3.id);
        final nonExistentMatches = gameweek.getMatchesForTeam('non-existent');

        // Assert
        expect(homeTeamMatches.length, equals(1));
        expect(homeTeamMatches.first, equals(match1));
        expect(team3Matches.length, equals(1));
        expect(team3Matches.first, equals(match2));
        expect(nonExistentMatches, isEmpty);
      });

      test('should get match between specific teams', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
        );

        // Act
        final foundMatch = gameweek.getMatchBetweenTeams(homeTeam.id, awayTeam.id);
        final reversedMatch = gameweek.getMatchBetweenTeams(awayTeam.id, homeTeam.id);
        final notFoundMatch = gameweek.getMatchBetweenTeams(homeTeam.id, team3.id);

        // Assert
        expect(foundMatch, equals(match1));
        expect(reversedMatch, equals(match1)); // Should work both ways
        expect(notFoundMatch, isNull);
      });
    });

    group('Gameweek Statistics', () {
      test('should calculate gameweek statistics', () {
        // Arrange
        final matchWithGoals1 = match1.copyWith(
          homeGoals: 2,
          awayGoals: 1,
          isCompleted: true,
          currentMinute: 90, // Match completed at 90 minutes
        );

        final matchWithGoals2 = match2.copyWith(
          homeGoals: 0,
          awayGoals: 3,
          isCompleted: true,
          currentMinute: 90, // Match completed at 90 minutes
        );

        // Create a separate match that doesn't conflict with existing teams
        final extraMatch = Match.create(
          id: 'stats-extra-match',
          homeTeam: Team(
            id: 'stats-home',
            name: 'Stats Home FC',
            city: 'Stats City',
            foundedYear: 1930,
            stadium: Stadium(
              name: 'Stats Stadium',
              capacity: 35000,
              city: 'Stats City',
            ),
          ),
          awayTeam: Team(
            id: 'stats-away',
            name: 'Stats Away FC',
            city: 'Stats City 2',
            foundedYear: 1935,
            stadium: Stadium(
              name: 'Stats Stadium 2',
              capacity: 28000,
              city: 'Stats City 2',
            ),
          ),
          weather: testWeather,
          kickoffTime: testDate.add(const Duration(hours: 6)),
        );

        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [matchWithGoals1, matchWithGoals2, extraMatch], // extraMatch has no goals
        );

        // Act
        final stats = gameweek.statistics;

        // Assert
        expect(stats['totalMatches'], equals(3));
        expect(stats['completedMatches'], equals(2));
        expect(stats['inProgressMatches'], equals(0));
        expect(stats['scheduledMatches'], equals(1));
        expect(stats['participatingTeams'], equals(6)); // 4 original teams + 2 extra teams = 6
        expect(stats['totalGoals'], equals(6)); // 2+1+0+3 = 6
        expect(stats['averageGoals'], equals('2.00')); // 6/3 = 2.00
        expect(stats['isCompleted'], isFalse);
        expect(stats['hasStarted'], isTrue);
      });

      test('should handle empty gameweek statistics', () {
        // Arrange
        final emptyGameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act
        final stats = emptyGameweek.statistics;

        // Assert
        expect(stats['totalMatches'], equals(0));
        expect(stats['completedMatches'], equals(0));
        expect(stats['participatingTeams'], equals(0));
        expect(stats['totalGoals'], equals(0));
        expect(stats['averageGoals'], equals('0.00'));
        expect(stats['isCompleted'], isFalse);
        expect(stats['hasStarted'], isFalse);
      });
    });

    group('Display and Utility Methods', () {
      test('should get display name', () {
        // Arrange
        final namedGameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          name: 'Boxing Day',
        );

        final unnamedGameweek = Gameweek(
          id: 'gw-456',
          number: 5,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act & Assert
        expect(namedGameweek.displayName, equals('Boxing Day'));
        expect(unnamedGameweek.displayName, equals('Gameweek 5'));
      });

      test('should determine if gameweek can start', () {
        // Arrange
        final validGameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
        );

        final emptyGameweek = Gameweek(
          id: 'gw-456',
          number: 2,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        final cancelledGameweek = Gameweek(
          id: 'gw-789',
          number: 3,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1],
          status: GameweekStatus.cancelled,
        );

        // Act & Assert
        expect(validGameweek.canStart, isTrue);
        expect(emptyGameweek.canStart, isFalse);
        expect(cancelledGameweek.canStart, isFalse);
      });

      test('should get earliest and latest match dates', () {
        // Arrange
        final earlyMatch = Match.create(
          id: 'early',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: testWeather,
          kickoffTime: testDate,
        );

        final lateMatch = Match.create(
          id: 'late',
          homeTeam: team3,
          awayTeam: team4,
          weather: testWeather,
          kickoffTime: testDate.add(const Duration(hours: 4)),
        );

        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [lateMatch, earlyMatch], // Intentionally out of order
        );

        final emptyGameweek = Gameweek(
          id: 'gw-456',
          number: 2,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act & Assert
        expect(gameweek.earliestMatchDate, equals(testDate));
        expect(gameweek.latestMatchDate, equals(testDate.add(const Duration(hours: 4))));
        expect(emptyGameweek.earliestMatchDate, isNull);
        expect(emptyGameweek.latestMatchDate, isNull);
      });
    });

    group('Gameweek Status Enum', () {
      test('should have all expected status values', () {
        expect(GameweekStatus.values.length, equals(5));
        expect(GameweekStatus.values, contains(GameweekStatus.scheduled));
        expect(GameweekStatus.values, contains(GameweekStatus.inProgress));
        expect(GameweekStatus.values, contains(GameweekStatus.completed));
        expect(GameweekStatus.values, contains(GameweekStatus.postponed));
        expect(GameweekStatus.values, contains(GameweekStatus.cancelled));
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all properties match', () {
        // Arrange
        final gameweek1 = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1],
        );

        final gameweek2 = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1],
        );

        // Act & Assert
        expect(gameweek1, equals(gameweek2));
        expect(gameweek1.hashCode, equals(gameweek2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final gameweek1 = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        final gameweek2 = Gameweek(
          id: 'gw-456',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
        );

        // Act & Assert
        expect(gameweek1, isNot(equals(gameweek2)));
      });
    });

    group('String Representation', () {
      test('should have proper string representation', () {
        // Arrange
        final gameweek = Gameweek(
          id: 'gw-123',
          number: 1,
          seasonId: 'season-456',
          scheduledDate: testDate,
          matches: [match1, match2],
          status: GameweekStatus.scheduled,
        );

        // Act
        final str = gameweek.toString();

        // Assert
        expect(str, contains('Gameweek'));
        expect(str, contains('gw-123'));
        expect(str, contains('number: 1'));
        expect(str, contains('matches: 2'));
        expect(str, contains('scheduled'));
        expect(str, contains('2025-08-31')); // Date part
      });
    });
  });
}
