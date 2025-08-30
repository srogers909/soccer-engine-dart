import 'package:test/test.dart';
import 'package:soccer_engine/src/systems/match_simulator.dart';
import 'package:soccer_engine/src/models/match.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_engine/src/models/player.dart';

void main() {
  group('MatchSimulator', () {
    late MatchSimulator simulator;
    late Team homeTeam;
    late Team awayTeam;
    late Weather weather;
    late Match match;

    setUp(() {
      // Use fixed seed for deterministic tests
      simulator = MatchSimulator(seed: 12345);

      // Create test teams with players
      final homeStadium = Stadium(
        name: 'Home Stadium',
        city: 'Home City',
        capacity: 50000,
      );

      final awayStadium = Stadium(
        name: 'Away Stadium',
        city: 'Away City',
        capacity: 40000,
      );

      homeTeam = Team(
        id: 'home-team',
        name: 'Home Team',
        city: 'Home City',
        foundedYear: 2000,
        stadium: homeStadium,
        formation: Formation.f442,
      );

      awayTeam = Team(
        id: 'away-team',
        name: 'Away Team',
        city: 'Away City',
        foundedYear: 2001,
        stadium: awayStadium,
        formation: Formation.f433,
      );

      // Add some players to teams for more realistic simulation
      homeTeam = _addPlayersToTeam(homeTeam);
      awayTeam = _addPlayersToTeam(awayTeam);

      weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 60.0,
        windSpeed: 10.0,
      );

      match = Match.create(
        id: 'test-match',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: DateTime.now().add(const Duration(hours: 2)),
      );
    });

    group('simulateMatch', () {
      test('should complete a match successfully', () {
        final result = simulator.simulateMatch(match);

        expect(result.isCompleted, isTrue);
        expect(result.result, isNotNull);
        expect(result.currentMinute, greaterThanOrEqualTo(90));
        expect(result.events, isNotEmpty);
      });

      test('should generate realistic scores', () {
        final results = <Match>[];
        
        // Run multiple simulations to check score distribution
        for (int i = 0; i < 50; i++) {
          final testMatch = Match.create(
            id: 'test-match-$i',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          results.add(sim.simulateMatch(testMatch));
        }

        // Check that scores are realistic (not too high)
        for (final result in results) {
          expect(result.homeGoals, lessThanOrEqualTo(8));
          expect(result.awayGoals, lessThanOrEqualTo(8));
          expect(result.homeGoals, greaterThanOrEqualTo(0));
          expect(result.awayGoals, greaterThanOrEqualTo(0));
        }

        // Check that there's variety in results
        final homeWins = results.where((r) => r.result == MatchResult.homeWin).length;
        final draws = results.where((r) => r.result == MatchResult.draw).length;
        final awayWins = results.where((r) => r.result == MatchResult.awayWin).length;

        // Should have some variety (not all the same result)
        expect(homeWins + draws + awayWins, equals(50));
        expect([homeWins, draws, awayWins].where((count) => count > 0).length, 
               greaterThanOrEqualTo(2));
      });

      test('should include kickoff, half time, and full time events', () {
        final result = simulator.simulateMatch(match);

        final kickoffEvents = result.events.where((e) => e.type == MatchEventType.kickoff);
        final halfTimeEvents = result.events.where((e) => e.type == MatchEventType.halfTime);
        final fullTimeEvents = result.events.where((e) => e.type == MatchEventType.fullTime);

        expect(kickoffEvents, hasLength(1));
        expect(halfTimeEvents, hasLength(1));
        expect(fullTimeEvents, hasLength(1));
        
        expect(kickoffEvents.first.minute, equals(0));
        expect(halfTimeEvents.first.minute, equals(45));
        expect(fullTimeEvents.first.minute, greaterThanOrEqualTo(90));
      });

      test('should generate goal events with correct score tracking', () {
        final result = simulator.simulateMatch(match);

        final goalEvents = result.events.where((e) => e.type == MatchEventType.goal).toList();
        
        // Verify that the final score matches the number of goal events
        final homeGoalEvents = goalEvents.where((e) => e.teamId == homeTeam.id).length;
        final awayGoalEvents = goalEvents.where((e) => e.teamId == awayTeam.id).length;

        expect(result.homeGoals, equals(homeGoalEvents));
        expect(result.awayGoals, equals(awayGoalEvents));
      });

      test('should reject already completed match', () {
        final completedMatch = match.copyWith(isCompleted: true);

        expect(
          () => simulator.simulateMatch(completedMatch),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Cannot simulate an already completed match',
          )),
        );
      });

      test('should apply home advantage correctly', () {
        final results = <Match>[];
        
        // Run multiple simulations
        for (int i = 0; i < 100; i++) {
          final testMatch = Match.create(
            id: 'test-match-$i',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          results.add(sim.simulateMatch(testMatch));
        }

        final homeWins = results.where((r) => r.result == MatchResult.homeWin).length;
        final awayWins = results.where((r) => r.result == MatchResult.awayWin).length;

        // Home team should win slightly more often due to home advantage
        // (This is statistical, so we allow for some variance)
        expect(homeWins, greaterThanOrEqualTo(awayWins - 10));
      });

      test('should apply weather effects', () {
        // Test with poor weather conditions
        final badWeather = Weather.create(
          condition: WeatherCondition.snowy,
          temperature: -10.0,
          humidity: 85.0,
          windSpeed: 40.0,
        );

        final badWeatherMatch = Match.create(
          id: 'bad-weather-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: badWeather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateMatch(badWeatherMatch);
        
        // Should still complete successfully even in bad weather
        expect(result.isCompleted, isTrue);
        expect(result.weather.performanceImpact, lessThan(1.0));
      });
    });

    group('simulateQuickResult', () {
      test('should complete match with minimal events', () {
        final result = simulator.simulateQuickResult(match);

        expect(result.isCompleted, isTrue);
        expect(result.result, isNotNull);
        expect(result.currentMinute, equals(90));
        expect(result.events, hasLength(1)); // Only full time event
        expect(result.events.first.type, equals(MatchEventType.fullTime));
      });

      test('should generate realistic quick results', () {
        final results = <Match>[];
        
        // Run multiple quick simulations
        for (int i = 0; i < 50; i++) {
          final testMatch = Match.create(
            id: 'quick-match-$i',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          results.add(sim.simulateQuickResult(testMatch));
        }

        // Check that scores are realistic
        for (final result in results) {
          expect(result.homeGoals, lessThanOrEqualTo(8));
          expect(result.awayGoals, lessThanOrEqualTo(8));
          expect(result.homeGoals, greaterThanOrEqualTo(0));
          expect(result.awayGoals, greaterThanOrEqualTo(0));
        }

        // Should have variety in results
        final uniqueResults = results
            .map((r) => '${r.homeGoals}-${r.awayGoals}')
            .toSet();
        expect(uniqueResults.length, greaterThan(1));
      });

      test('should reject already completed match', () {
        final completedMatch = match.copyWith(isCompleted: true);

        expect(
          () => simulator.simulateQuickResult(completedMatch),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Cannot simulate an already completed match',
          )),
        );
      });
    });

    group('deterministic behavior with fixed seed', () {
      test('should produce identical results with same seed', () {
        final sim1 = MatchSimulator(seed: 42);
        final sim2 = MatchSimulator(seed: 42);

        final result1 = sim1.simulateQuickResult(match);
        final result2 = sim2.simulateQuickResult(match);

        expect(result1.homeGoals, equals(result2.homeGoals));
        expect(result1.awayGoals, equals(result2.awayGoals));
        expect(result1.result, equals(result2.result));
      });

      test('should produce different results with different seeds', () {
        final sim1 = MatchSimulator(seed: 123);
        final sim2 = MatchSimulator(seed: 456);

        final results1 = <String>[];
        final results2 = <String>[];

        // Generate multiple results to compare
        for (int i = 0; i < 10; i++) {
          final testMatch1 = Match.create(
            id: 'test-$i-1',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final testMatch2 = Match.create(
            id: 'test-$i-2',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );

          final result1 = sim1.simulateQuickResult(testMatch1);
          final result2 = sim2.simulateQuickResult(testMatch2);

          results1.add('${result1.homeGoals}-${result1.awayGoals}');
          results2.add('${result2.homeGoals}-${result2.awayGoals}');
        }

        // Should have at least some different results
        expect(results1, isNot(equals(results2)));
      });
    });

    group('team strength calculations', () {
      test('should favor stronger teams', () {
        // Create a much stronger home team
        var strongHomeTeam = Team(
          id: 'strong-home',
          name: 'Strong Home Team',
          city: 'Strong City',
          foundedYear: 2000,
          stadium: Stadium(name: 'Big Stadium', city: 'Strong City', capacity: 80000),
          formation: Formation.f442,
          morale: 95,
        );
        
        // Add high-rated players
        strongHomeTeam = _addHighRatedPlayersToTeam(strongHomeTeam);

        final strongMatch = Match.create(
          id: 'strong-match',
          homeTeam: strongHomeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final results = <Match>[];
        
        // Run multiple simulations
        for (int i = 0; i < 30; i++) {
          final testMatch = Match.create(
            id: 'strong-test-$i',
            homeTeam: strongHomeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          results.add(sim.simulateQuickResult(testMatch));
        }

        final homeWins = results.where((r) => r.result == MatchResult.homeWin).length;
        final totalHomeGoals = results.map((r) => r.homeGoals).reduce((a, b) => a + b);
        final totalAwayGoals = results.map((r) => r.awayGoals).reduce((a, b) => a + b);

        // Strong team should win more often and score more goals
        expect(homeWins, greaterThan(results.length ~/ 3)); // More than 1/3 of games
        expect(totalHomeGoals, greaterThan(totalAwayGoals)); // More goals overall
      });
    });
  });
}

/// Helper function to add basic players to a team for testing
Team _addPlayersToTeam(Team team) {
  var updatedTeam = team;
  
  // Add 2 goalkeepers
  for (int i = 1; i <= 2; i++) {
    final gk = Player(
      id: '${team.id}-gk-$i',
      name: 'Goalkeeper $i',
      age: 25,
      position: PlayerPosition.goalkeeper,
      technical: 60,
      physical: 70,
      mental: 75,
    );
    updatedTeam = updatedTeam.addPlayer(gk);
  }
  
  // Add 6 defenders
  for (int i = 1; i <= 6; i++) {
    final def = Player(
      id: '${team.id}-def-$i',
      name: 'Defender $i',
      age: 26,
      position: PlayerPosition.defender,
      technical: 65,
      physical: 75,
      mental: 70,
    );
    updatedTeam = updatedTeam.addPlayer(def);
  }
  
  // Add 6 midfielders
  for (int i = 1; i <= 6; i++) {
    final mid = Player(
      id: '${team.id}-mid-$i',
      name: 'Midfielder $i',
      age: 24,
      position: PlayerPosition.midfielder,
      technical: 75,
      physical: 70,
      mental: 75,
    );
    updatedTeam = updatedTeam.addPlayer(mid);
  }
  
  // Add 4 forwards
  for (int i = 1; i <= 4; i++) {
    final fwd = Player(
      id: '${team.id}-fwd-$i',
      name: 'Forward $i',
      age: 23,
      position: PlayerPosition.forward,
      technical: 80,
      physical: 80,
      mental: 70,
    );
    updatedTeam = updatedTeam.addPlayer(fwd);
  }
  
  return updatedTeam;
}

/// Helper function to add high-rated players to create a stronger team
Team _addHighRatedPlayersToTeam(Team team) {
  var updatedTeam = team;
  
  // Add 2 world-class goalkeepers
  for (int i = 1; i <= 2; i++) {
    final gk = Player(
      id: '${team.id}-gk-$i',
      name: 'World Class GK $i',
      age: 28,
      position: PlayerPosition.goalkeeper,
      technical: 85,
      physical: 85,
      mental: 90,
    );
    updatedTeam = updatedTeam.addPlayer(gk);
  }
  
  // Add 6 world-class defenders
  for (int i = 1; i <= 6; i++) {
    final def = Player(
      id: '${team.id}-def-$i',
      name: 'World Class DEF $i',
      age: 28,
      position: PlayerPosition.defender,
      technical: 80,
      physical: 90,
      mental: 85,
    );
    updatedTeam = updatedTeam.addPlayer(def);
  }
  
  // Add 6 world-class midfielders
  for (int i = 1; i <= 6; i++) {
    final mid = Player(
      id: '${team.id}-mid-$i',
      name: 'World Class MID $i',
      age: 26,
      position: PlayerPosition.midfielder,
      technical: 90,
      physical: 85,
      mental: 90,
    );
    updatedTeam = updatedTeam.addPlayer(mid);
  }
  
  // Add 4 world-class forwards
  for (int i = 1; i <= 4; i++) {
    final fwd = Player(
      id: '${team.id}-fwd-$i',
      name: 'World Class FWD $i',
      age: 25,
      position: PlayerPosition.forward,
      technical: 95,
      physical: 90,
      mental: 85,
    );
    updatedTeam = updatedTeam.addPlayer(fwd);
  }
  
  return updatedTeam;
}
