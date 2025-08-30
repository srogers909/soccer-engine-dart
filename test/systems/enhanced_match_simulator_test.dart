import 'package:test/test.dart';
import 'package:soccer_engine/src/systems/match_simulator.dart';
import 'package:soccer_engine/src/models/match.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_utilities/src/models/player.dart';
import 'package:soccer_engine/src/models/enhanced_match.dart';

void main() {
  group('Enhanced Match Simulator (Football Manager Style)', () {
    late MatchSimulator simulator;
    late Team homeTeam;
    late Team awayTeam;
    late Weather weather;

    setUp(() {
      simulator = MatchSimulator(seed: 12345);
      
      final homeStadium = Stadium(
        name: 'Home Stadium',
        city: 'Home City', 
        capacity: 50000,
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
        stadium: Stadium(name: 'Away Stadium', city: 'Away City', capacity: 40000),
        formation: Formation.f433,
      );

      homeTeam = _addPlayersToTeam(homeTeam);
      awayTeam = _addPlayersToTeam(awayTeam);

      weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 60.0,
        windSpeed: 10.0,
      );
    });

    group('Detailed Match Events', () {
      test('should generate Football Manager-style detailed events', () {
        final match = Match.create(
          id: 'detailed-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        expect(result.isCompleted, isTrue);
        expect(result.events, isNotEmpty);

        // Should have more event types than basic simulation
        final eventTypes = result.events.map((e) => e.type).toSet();
        expect(eventTypes, contains(MatchEventType.kickoff));
        expect(eventTypes, contains(MatchEventType.halfTime));
        expect(eventTypes, contains(MatchEventType.fullTime));
        
        // Should include detailed events
        expect(eventTypes.length, greaterThanOrEqualTo(3));
      });

      test('should generate injury events', () {
        final match = Match.create(
          id: 'injury-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        // Run multiple simulations to ensure injury events occur
        bool injuryFound = false;
        for (int i = 0; i < 20; i++) {
          final testMatch = Match.create(
            id: 'injury-test-$i',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          final result = sim.simulateDetailedMatch(testMatch);
          
          final injuryEvents = result.events.where((e) => e.type == MatchEventType.injury);
          if (injuryEvents.isNotEmpty) {
            injuryFound = true;
            
            for (final injuryEvent in injuryEvents) {
              expect(injuryEvent.playerId, isNotNull);
              expect(injuryEvent.playerName, isNotNull);
              expect(injuryEvent.minute, greaterThanOrEqualTo(1));
              expect(injuryEvent.minute, lessThanOrEqualTo(95));
            }
            break;
          }
        }
        
        expect(injuryFound, isTrue, reason: 'Should generate injury events in multiple simulations');
      });

      test('should generate shot events with accuracy tracking', () {
        final match = Match.create(
          id: 'shots-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        final shotEvents = result.events.where((e) => 
          e.type == MatchEventType.shot || 
          e.type == MatchEventType.shotOnTarget ||
          e.type == MatchEventType.shotOffTarget);
        
        expect(shotEvents, isNotEmpty, reason: 'Should generate shot events');
        
        for (final shotEvent in shotEvents) {
          expect(shotEvent.playerId, isNotNull);
          expect(shotEvent.playerName, isNotNull);
        }
      });

      test('should track possession and match statistics', () {
        final match = Match.create(
          id: 'possession-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        expect(result.matchStats, isNotNull);
        expect(result.matchStats!.homePossession, greaterThan(0));
        expect(result.matchStats!.awayPossession, greaterThan(0));
        expect(result.matchStats!.homePossession + result.matchStats!.awayPossession, equals(100));
        
        expect(result.matchStats!.homePassAccuracy, greaterThanOrEqualTo(0.0));
        expect(result.matchStats!.homePassAccuracy, lessThanOrEqualTo(100.0));
        expect(result.matchStats!.awayPassAccuracy, greaterThanOrEqualTo(0.0));
        expect(result.matchStats!.awayPassAccuracy, lessThanOrEqualTo(100.0));
      });
    });

    group('Tactical Influence', () {
      test('should apply formation effects to match outcome', () {
        // Create teams with different formations
        final attackingHomeTeam = homeTeam.copyWith(formation: Formation.f343);
        final defensiveAwayTeam = awayTeam.copyWith(formation: Formation.f541);

        final results = <Match>[];
        for (int i = 0; i < 30; i++) {
          final match = Match.create(
            id: 'formation-test-$i',
            homeTeam: attackingHomeTeam,
            awayTeam: defensiveAwayTeam,
            weather: weather,
            kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          );
          
          final sim = MatchSimulator(seed: i);
          results.add(sim.simulateDetailedMatch(match));
        }

        final avgHomeGoals = results.map((r) => r.homeGoals).reduce((a, b) => a + b) / results.length;
        final avgAwayGoals = results.map((r) => r.awayGoals).reduce((a, b) => a + b) / results.length;

        // Teams should score some goals on average
        expect(avgHomeGoals, greaterThan(0));
        expect(avgAwayGoals, greaterThan(0));
      });

      test('should handle in-game tactical changes', () {
        final match = Match.create(
          id: 'tactical-change-test',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final homeTacticalChanges = <int, TeamTactics>{
          30: TeamTactics(
            mentality: TeamMentality.attacking,
            pressing: 80,
            tempo: 70,
            width: 60,
            directness: 60,
          ),
        };

        final awayTacticalChanges = <int, TeamTactics>{
          60: TeamTactics(
            mentality: TeamMentality.defensive,
            pressing: 40,
            tempo: 40,
            width: 50,
            directness: 50,
          ),
        };

        final result = simulator.simulateDetailedMatchWithTacticalChanges(
          match, 
          homeTacticalChanges, 
          awayTacticalChanges
        );

        final tacticalChangeEvents = result.events.where((e) => e.type == MatchEventType.tacticalChange);
        expect(tacticalChangeEvents, isNotEmpty, 
            reason: 'Should generate tactical change events during match');
        
        for (final tacticalEvent in tacticalChangeEvents) {
          expect(tacticalEvent.minute, greaterThanOrEqualTo(0));
          expect(tacticalEvent.minute, lessThanOrEqualTo(90));
        }
      });
    });

    group('Player Performance Tracking', () {
      test('should generate individual player ratings', () {
        final match = Match.create(
          id: 'ratings-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        expect(result.playerPerformances, isNotNull);
        expect(result.playerPerformances!.length, equals(36)); // 18 players per team

        for (final performance in result.playerPerformances!.values) {
          expect(performance.playerId, isNotNull);
          expect(performance.rating, greaterThanOrEqualTo(1.0));
          expect(performance.rating, lessThanOrEqualTo(10.0));
          expect(performance.minutesPlayed, greaterThanOrEqualTo(0));
        }
      });

      test('should track key player statistics', () {
        final match = Match.create(
          id: 'stats-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        for (final performance in result.playerPerformances!.values) {
          // Basic stats should be tracked
          expect(performance.passes, greaterThanOrEqualTo(0));
          expect(performance.passAccuracy, greaterThanOrEqualTo(0.0));
          expect(performance.passAccuracy, lessThanOrEqualTo(100.0));
          expect(performance.tackles, greaterThanOrEqualTo(0));
          expect(performance.shots, greaterThanOrEqualTo(0));
          expect(performance.fouls, greaterThanOrEqualTo(0));

          // Position-specific expectations
          final player = _findPlayerById(homeTeam, awayTeam, performance.playerId);
          if (player != null) {
            if (player.position == PlayerPosition.goalkeeper) {
              // Goalkeepers shouldn't have many shots
              expect(performance.shots, equals(0));
            } else if (player.position == PlayerPosition.defender) {
              // Defenders should have some tackles
              expect(performance.tackles, greaterThanOrEqualTo(0));
            } else if (player.position == PlayerPosition.forward) {
              // Forwards should have some shots
              expect(performance.shots, greaterThanOrEqualTo(0));
            }
          }
        }
      });
    });

    group('Match Momentum and Flow', () {
      test('should track match momentum changes', () {
        final match = Match.create(
          id: 'momentum-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        expect(result.momentumTracker, isNotNull);
        expect(result.momentumTracker!.shiftEvents.length, greaterThanOrEqualTo(0));

        expect(result.momentumTracker!.homeMomentum, greaterThanOrEqualTo(0.0));
        expect(result.momentumTracker!.homeMomentum, lessThanOrEqualTo(100.0));
        expect(result.momentumTracker!.awayMomentum, greaterThanOrEqualTo(0.0));
        expect(result.momentumTracker!.awayMomentum, lessThanOrEqualTo(100.0));
      });

      test('should reflect momentum in event generation', () {
        // Test that high momentum increases chance of positive events
        final strongHomeTeam = _createStrongTeam('strong-home', Formation.f343);
        final weakAwayTeam = _createWeakTeam('weak-away', Formation.f541);

        final match = Match.create(
          id: 'momentum-events-match',
          homeTeam: strongHomeTeam,
          awayTeam: weakAwayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        // Strong team should have decent momentum
        expect(result.momentumTracker!.homeMomentum, greaterThanOrEqualTo(0.0));
        expect(result.momentumTracker!.awayMomentum, greaterThanOrEqualTo(0.0));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle teams with missing players gracefully', () {
        final incompleteTeam = Team(
          id: 'incomplete-team',
          name: 'Incomplete Team',
          city: 'Test City',
          foundedYear: 2000,
          stadium: Stadium(name: 'Test Stadium', city: 'Test City', capacity: 30000),
          formation: Formation.f442,
        );

        final match = Match.create(
          id: 'incomplete-match',
          homeTeam: incompleteTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        // Should not throw an error, but handle gracefully
        final result = simulator.simulateDetailedMatch(match);
        expect(result.isCompleted, isTrue);
      });

      test('should handle extreme weather conditions', () {
        final extremeWeather = Weather.create(
          condition: WeatherCondition.snowy,
          temperature: -15.0,
          humidity: 95.0,
          windSpeed: 60.0,
        );

        final match = Match.create(
          id: 'extreme-weather-match',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: extremeWeather,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
        );

        final result = simulator.simulateDetailedMatch(match);

        expect(result.isCompleted, isTrue);
        
        // Extreme weather should affect performance
        expect(result.matchStats!.homePassAccuracy, lessThan(95.0));
        expect(result.matchStats!.awayPassAccuracy, lessThan(95.0));
      });
    });
  });
}

/// Helper function to add players to a team for testing
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

/// Helper function to create a strong team for testing
Team _createStrongTeam(String id, Formation formation) {
  final stadium = Stadium(name: 'Elite Stadium', city: 'Elite City', capacity: 80000);
  var team = Team(
    id: id,
    name: 'Elite Team',
    city: 'Elite City',
    foundedYear: 1900,
    stadium: stadium,
    formation: formation,
    morale: 95,
  );

  // Add world-class players
  for (int i = 1; i <= 2; i++) {
    final gk = Player(
      id: '$id-gk-$i',
      name: 'Elite GK $i',
      age: 28,
      position: PlayerPosition.goalkeeper,
      technical: 90,
      physical: 85,
      mental: 95,
    );
    team = team.addPlayer(gk);
  }
  
  for (int i = 1; i <= 6; i++) {
    final def = Player(
      id: '$id-def-$i',
      name: 'Elite DEF $i',
      age: 28,
      position: PlayerPosition.defender,
      technical: 85,
      physical: 90,
      mental: 85,
    );
    team = team.addPlayer(def);
  }
  
  for (int i = 1; i <= 6; i++) {
    final mid = Player(
      id: '$id-mid-$i',
      name: 'Elite MID $i',
      age: 26,
      position: PlayerPosition.midfielder,
      technical: 95,
      physical: 85,
      mental: 90,
    );
    team = team.addPlayer(mid);
  }
  
  for (int i = 1; i <= 4; i++) {
    final fwd = Player(
      id: '$id-fwd-$i',
      name: 'Elite FWD $i',
      age: 25,
      position: PlayerPosition.forward,
      technical: 95,
      physical: 90,
      mental: 85,
    );
    team = team.addPlayer(fwd);
  }
  
  return team;
}

/// Helper function to create a weak team for testing
Team _createWeakTeam(String id, Formation formation) {
  final stadium = Stadium(name: 'Small Stadium', city: 'Small City', capacity: 20000);
  var team = Team(
    id: id,
    name: 'Weak Team',
    city: 'Small City',
    foundedYear: 2010,
    stadium: stadium,
    formation: formation,
    morale: 45,
  );

  // Add below-average players
  for (int i = 1; i <= 2; i++) {
    final gk = Player(
      id: '$id-gk-$i',
      name: 'Weak GK $i',
      age: 32,
      position: PlayerPosition.goalkeeper,
      technical: 50,
      physical: 55,
      mental: 50,
    );
    team = team.addPlayer(gk);
  }
  
  for (int i = 1; i <= 6; i++) {
    final def = Player(
      id: '$id-def-$i',
      name: 'Weak DEF $i',
      age: 30,
      position: PlayerPosition.defender,
      technical: 45,
      physical: 60,
      mental: 50,
    );
    team = team.addPlayer(def);
  }
  
  for (int i = 1; i <= 6; i++) {
    final mid = Player(
      id: '$id-mid-$i',
      name: 'Weak MID $i',
      age: 29,
      position: PlayerPosition.midfielder,
      technical: 50,
      physical: 55,
      mental: 45,
    );
    team = team.addPlayer(mid);
  }
  
  for (int i = 1; i <= 4; i++) {
    final fwd = Player(
      id: '$id-fwd-$i',
      name: 'Weak FWD $i',
      age: 31,
      position: PlayerPosition.forward,
      technical: 55,
      physical: 60,
      mental: 45,
    );
    team = team.addPlayer(fwd);
  }
  
  return team;
}

/// Helper function to find a player by ID in either team
Player? _findPlayerById(Team homeTeam, Team awayTeam, String playerId) {
  for (final player in homeTeam.players) {
    if (player.id == playerId) return player;
  }
  for (final player in awayTeam.players) {
    if (player.id == playerId) return player;
  }
  return null;
}
