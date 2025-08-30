import 'package:test/test.dart';
import 'package:soccer_engine/src/models/league.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_engine/src/models/player.dart';

void main() {
  group('League Model Tests', () {
    late Team team1;
    late Team team2;
    late Team team3;
    late Team team4;

    setUp(() {
      // Create test players for teams
      final players1 = List.generate(
        16,
        (index) => Player(
          id: 'team1-player-$index',
          name: 'Team1 Player $index',
          age: 20 + (index % 15),
          position: PlayerPosition.values[index % 4],
          technical: 60 + (index % 20),
          physical: 65 + (index % 20),
          mental: 70 + (index % 20),
        ),
      );

      final players2 = List.generate(
        18,
        (index) => Player(
          id: 'team2-player-$index',
          name: 'Team2 Player $index',
          age: 20 + (index % 15),
          position: PlayerPosition.values[index % 4],
          technical: 65 + (index % 20),
          physical: 70 + (index % 20),
          mental: 75 + (index % 20),
        ),
      );

      team1 = Team(
        id: 'team-001',
        name: 'Arsenal FC',
        city: 'London',
        foundedYear: 1886,
        players: players1,
      );

      team2 = Team(
        id: 'team-002',
        name: 'Chelsea FC',
        city: 'London',
        foundedYear: 1905,
        players: players2,
      );

      team3 = Team(
        id: 'team-003',
        name: 'Liverpool FC',
        city: 'Liverpool',
        foundedYear: 1892,
      );

      team4 = Team(
        id: 'team-004',
        name: 'Manchester United FC',
        city: 'Manchester',
        foundedYear: 1878,
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create league with required properties', () {
        // Arrange
        const id = 'league-123';
        const name = 'Premier League';
        const country = 'England';

        // Act
        final league = League(
          id: id,
          name: name,
          country: country,
        );

        // Assert
        expect(league.id, equals(id));
        expect(league.name, equals(name));
        expect(league.country, equals(country));
        expect(league.tier, equals(LeagueTier.tier1)); // Default tier
        expect(league.format, equals(LeagueFormat.roundRobin)); // Default format
        expect(league.teams, isEmpty);
        expect(league.rules, isNotNull);
        expect(league.foundedYear, equals(DateTime.now().year)); // Default to current year
        expect(league.maxTeams, equals(20));
        expect(league.minTeams, equals(8));
      });

      test('should create league with custom properties', () {
        // Arrange
        const customRules = LeagueRules(
          promotionSpots: 3,
          relegationSpots: 4,
          pointsForWin: 3,
        );

        // Create enough teams to meet minimum requirement
        final manyTeams = List.generate(
          10,
          (index) => Team(
            id: 'team-${index + 1}',
            name: 'Team ${index + 1}',
            city: 'City ${index + 1}',
            foundedYear: 1900,
          ),
        );

        // Act
        final league = League(
          id: 'league-123',
          name: 'Championship',
          country: 'England',
          tier: LeagueTier.tier2,
          format: LeagueFormat.singleRoundRobin,
          teams: manyTeams,
          rules: customRules,
          foundedYear: 1992,
          maxTeams: 24,
          minTeams: 10,
        );

        // Assert
        expect(league.tier, equals(LeagueTier.tier2));
        expect(league.format, equals(LeagueFormat.singleRoundRobin));
        expect(league.teams.length, equals(10));
        expect(league.rules, equals(customRules));
        expect(league.foundedYear, equals(1992));
        expect(league.maxTeams, equals(24));
        expect(league.minTeams, equals(10));
      });
    });

    group('Validation', () {
      test('should throw when id is empty', () {
        expect(
          () => League(
            id: '',
            name: 'Premier League',
            country: 'England',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when name is empty', () {
        expect(
          () => League(
            id: 'league-123',
            name: '',
            country: 'England',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when country is empty', () {
        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when maxTeams is less than minTeams', () {
        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            maxTeams: 10,
            minTeams: 15,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when founded year is invalid', () {
        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            foundedYear: 1800, // Too early
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            foundedYear: 2050, // Future
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when too many teams provided', () {
        final manyTeams = List.generate(
          25, // More than default maxTeams (20)
          (index) => Team(
            id: 'team-$index',
            name: 'Team $index',
            city: 'City $index',
            foundedYear: 1900,
          ),
        );

        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            teams: manyTeams,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when too few teams for competitive play', () {
        final fewTeams = [team1, team2]; // Less than minTeams (8)

        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            teams: fewTeams,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when round-robin format has odd number of teams', () {
        final oddTeams = [team1, team2, team3]; // 3 teams (odd)

        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            format: LeagueFormat.roundRobin,
            teams: oddTeams,
            minTeams: 3, // Allow minimum for this test
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when duplicate teams are provided', () {
        final duplicateTeams = [team1, team2, team1]; // team1 appears twice

        expect(
          () => League(
            id: 'league-123',
            name: 'Premier League',
            country: 'England',
            teams: duplicateTeams,
            minTeams: 3,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Team Management', () {
      test('should add team to league', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4],
          minTeams: 4,
          format: LeagueFormat.singleRoundRobin, // Avoid even number requirement
        );

        final newTeam = Team(
          id: 'team-005',
          name: 'Manchester City FC',
          city: 'Manchester',
          foundedYear: 1880,
        );

        // Act
        final updatedLeague = league.addTeam(newTeam);

        // Assert
        expect(updatedLeague.teams, contains(newTeam));
        expect(updatedLeague.teams.length, equals(5));
        expect(league.teams.length, equals(4)); // Original league unchanged
      });

      test('should remove team from league', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4, 
            Team(id: 'team-005', name: 'Team 5', city: 'City 5', foundedYear: 1900)],
          minTeams: 4,
          format: LeagueFormat.singleRoundRobin, // Avoid even number requirement
        );

        // Act
        final updatedLeague = league.removeTeam(team1.id);

        // Assert
        expect(updatedLeague.teams, isNot(contains(team1)));
        expect(updatedLeague.teams, contains(team2));
        expect(updatedLeague.teams.length, equals(4));
      });

      test('should not add duplicate team', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4],
          minTeams: 4,
        );

        // Act & Assert
        expect(
          () => league.addTeam(team1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should not exceed maximum team capacity', () {
        // Arrange
        final maxTeams = List.generate(
          20, // Maximum capacity
          (index) => Team(
            id: 'team-$index',
            name: 'Team $index',
            city: 'City $index',
            foundedYear: 1900,
          ),
        );

        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: maxTeams,
          minTeams: 8,
        );

        final extraTeam = Team(
          id: 'extra-team',
          name: 'Extra Team',
          city: 'Extra City',
          foundedYear: 1900,
        );

        // Act & Assert
        expect(
          () => league.addTeam(extraTeam),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should not remove team below minimum', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4], // Exactly minTeams
          minTeams: 4,
        );

        // Act & Assert
        expect(
          () => league.removeTeam(team1.id),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should maintain even teams for round-robin when adding', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          format: LeagueFormat.roundRobin,
          teams: [team1, team2, team3, team4], // Even number
          minTeams: 4,
        );

        final oddTeam = Team(
          id: 'team-005',
          name: 'Odd Team',
          city: 'Odd City',
          foundedYear: 1900,
        );

        // Act & Assert
        expect(
          () => league.addTeam(oddTeam), // Would make it odd
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should get team by id', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4],
          minTeams: 4,
        );

        // Act
        final foundTeam = league.getTeam(team2.id);
        final notFoundTeam = league.getTeam('non-existent');

        // Assert
        expect(foundTeam, equals(team2));
        expect(notFoundTeam, isNull);
      });
    });

    group('League Rules Management', () {
      test('should update league rules', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
        );

        const newRules = LeagueRules(
          promotionSpots: 4,
          relegationSpots: 2,
          playoffSpots: 6,
          pointsForWin: 3,
        );

        // Act
        final updatedLeague = league.updateRules(newRules);

        // Assert
        expect(updatedLeague.rules, equals(newRules));
        expect(league.rules, isNot(equals(newRules))); // Original unchanged
      });
    });

    group('League Status Checks', () {
      test('should determine if league is competitive', () {
        // Arrange
        final competitiveLeague = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2, team3, team4], // Meets minTeams
          minTeams: 4,
        );

        final nonCompetitiveLeague = League(
          id: 'league-456',
          name: 'Small League',
          country: 'England',
          teams: [], // No teams
        );

        // Act & Assert
        expect(competitiveLeague.isCompetitive, isTrue);
        expect(nonCompetitiveLeague.isCompetitive, isFalse);
      });

      test('should determine if league can start season', () {
        // Arrange
        final readyLeague = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          format: LeagueFormat.roundRobin,
          teams: [team1, team2, team3, team4], // Even number, meets minimum
          minTeams: 4,
        );

        final oddTeamsLeague = League(
          id: 'league-456',
          name: 'Odd League',
          country: 'England',
          format: LeagueFormat.singleRoundRobin, // Use single round robin for odd teams
          teams: [team1, team2, team3], // Odd number
          minTeams: 3,
        );

        final emptyLeague = League(
          id: 'league-789',
          name: 'Empty League',
          country: 'England',
        );

        // Act & Assert
        expect(readyLeague.canStartSeason, isTrue);
        expect(oddTeamsLeague.canStartSeason, isFalse);
        expect(emptyLeague.canStartSeason, isFalse);
      });

      test('should calculate required gameweeks', () {
        // Arrange
        final roundRobinLeague = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          format: LeagueFormat.roundRobin,
          teams: [team1, team2, team3, team4], // 4 teams
          minTeams: 4,
        );

        final singleRobinLeague = League(
          id: 'league-456',
          name: 'Single League',
          country: 'England',
          format: LeagueFormat.singleRoundRobin,
          teams: [team1, team2, team3, team4], // 4 teams
          minTeams: 4,
        );

        // Act & Assert
        expect(roundRobinLeague.requiredGameweeks, equals(6)); // (4-1) * 2
        expect(singleRobinLeague.requiredGameweeks, equals(3)); // 4-1
      });
    });

    group('League Statistics', () {
      test('should calculate league statistics', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          teams: [team1, team2], // team1 has 16 players, team2 has 18 players
          minTeams: 2,
        );

        // Act
        final stats = league.statistics;

        // Assert
        expect(stats['totalTeams'], equals(2));
        expect(stats['totalPlayers'], equals(34)); // 16 + 18
        expect(stats['averageSquadSize'], equals('17.0')); // 34 / 2
        expect(stats['averageOverallRating'], isA<String>());
        expect(stats['isCompetitive'], isTrue);
        expect(stats['canStartSeason'], isTrue);
        expect(stats['requiredGameweeks'], equals(2)); // (2-1) * 2
      });

      test('should handle empty league statistics', () {
        // Arrange
        final emptyLeague = League(
          id: 'league-123',
          name: 'Empty League',
          country: 'England',
        );

        // Act
        final stats = emptyLeague.statistics;

        // Assert
        expect(stats['totalTeams'], equals(0));
        expect(stats['totalPlayers'], equals(0));
        expect(stats['averageSquadSize'], equals('0.0'));
        expect(stats['averageOverallRating'], equals('0.0'));
        expect(stats['isCompetitive'], isFalse);
        expect(stats['canStartSeason'], isFalse);
      });
    });

    group('League Tiers', () {
      test('should have correct tier display names', () {
        expect(LeagueTier.tier1.displayName, equals('1st Tier'));
        expect(LeagueTier.tier2.displayName, equals('2nd Tier'));
        expect(LeagueTier.tier3.displayName, equals('3rd Tier'));
        expect(LeagueTier.tier4.displayName, equals('4th Tier'));
        expect(LeagueTier.tier5Plus.displayName, equals('5th+ Tier'));
      });
    });

    group('League Rules', () {
      test('should create league rules with defaults', () {
        // Act
        const rules = LeagueRules();

        // Assert
        expect(rules.promotionSpots, equals(2));
        expect(rules.relegationSpots, equals(3));
        expect(rules.playoffSpots, equals(4));
        expect(rules.pointsForWin, equals(3));
        expect(rules.pointsForDraw, equals(1));
        expect(rules.pointsForLoss, equals(0));
        expect(rules.useGoalDifference, isTrue);
        expect(rules.useHeadToHead, isFalse);
      });

      test('should create league rules with custom values', () {
        // Act
        const rules = LeagueRules(
          promotionSpots: 3,
          relegationSpots: 4,
          playoffSpots: 6,
          pointsForWin: 3,
          pointsForDraw: 1,
          pointsForLoss: 0,
          useGoalDifference: false,
          useHeadToHead: true,
        );

        // Assert
        expect(rules.promotionSpots, equals(3));
        expect(rules.relegationSpots, equals(4));
        expect(rules.playoffSpots, equals(6));
        expect(rules.useGoalDifference, isFalse);
        expect(rules.useHeadToHead, isTrue);
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all properties match', () {
        // Arrange
        final league1 = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          foundedYear: 1992,
        );

        final league2 = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          foundedYear: 1992,
        );

        // Act & Assert
        expect(league1, equals(league2));
        expect(league1.hashCode, equals(league2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final league1 = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
        );

        final league2 = League(
          id: 'league-456',
          name: 'Premier League',
          country: 'England',
        );

        // Act & Assert
        expect(league1, isNot(equals(league2)));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          tier: LeagueTier.tier1,
          format: LeagueFormat.roundRobin,
          foundedYear: 1992,
          teams: [], // Empty teams for simplicity
        );

        // Act
        final json = league.toJson();

        // Assert
        expect(json['id'], equals('league-123'));
        expect(json['name'], equals('Premier League'));
        expect(json['country'], equals('England'));
        expect(json['tier'], equals('tier1'));
        expect(json['format'], equals('roundRobin'));
        expect(json['foundedYear'], equals(1992));
        expect(json['teams'], isA<List>());
        expect(json['rules'], isA<Map>());
        expect(json['maxTeams'], equals(20));
        expect(json['minTeams'], equals(8));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'league-123',
          'name': 'Premier League',
          'country': 'England',
          'tier': 'tier1',
          'format': 'roundRobin',
          'foundedYear': 1992,
          'teams': [], // Empty teams for simplicity
          'rules': {
            'promotionSpots': 2,
            'relegationSpots': 3,
            'playoffSpots': 4,
            'pointsForWin': 3,
            'pointsForDraw': 1,
            'pointsForLoss': 0,
            'useGoalDifference': true,
            'useHeadToHead': false,
          },
          'maxTeams': 20,
          'minTeams': 8,
        };

        // Act
        final league = League.fromJson(json);

        // Assert
        expect(league.id, equals('league-123'));
        expect(league.name, equals('Premier League'));
        expect(league.country, equals('England'));
        expect(league.tier, equals(LeagueTier.tier1));
        expect(league.format, equals(LeagueFormat.roundRobin));
        expect(league.foundedYear, equals(1992));
        expect(league.teams.length, equals(0));
        expect(league.rules.promotionSpots, equals(2));
        expect(league.maxTeams, equals(20));
        expect(league.minTeams, equals(8));
      });
    });

    group('String Representation', () {
      test('should have proper string representation', () {
        // Arrange
        final league = League(
          id: 'league-123',
          name: 'Premier League',
          country: 'England',
          tier: LeagueTier.tier1,
          format: LeagueFormat.roundRobin,
          teams: [team1, team2],
          minTeams: 2,
        );

        // Act
        final str = league.toString();

        // Assert
        expect(str, contains('League'));
        expect(str, contains('league-123'));
        expect(str, contains('Premier League'));
        expect(str, contains('England'));
        expect(str, contains('teams: 2'));
        expect(str, contains('1st Tier'));
        expect(str, contains('roundRobin'));
      });
    });
  });
}
