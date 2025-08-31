import 'dart:async';
import 'package:test/test.dart';
import '../../lib/src/systems/streaming_match_simulator.dart';
import '../../lib/src/models/match.dart';
import '../../lib/src/models/team.dart';
import '../../lib/src/models/enhanced_match.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';
import '../helpers/test_data_builders.dart';

void main() {
  group('StreamingMatchSimulator', () {
    late StreamingMatchSimulator simulator;
    late Match testMatch;
    late Team homeTeam;
    late Team awayTeam;

    setUp(() {
      simulator = StreamingMatchSimulator(seed: 42); // Fixed seed for predictable tests
      
      // Create test teams with players
      homeTeam = TestDataBuilders.createTestTeam(
        id: 'home_team',
        name: 'Home FC',
        playerCount: 11,
      );
      
      awayTeam = TestDataBuilders.createTestTeam(
        id: 'away_team', 
        name: 'Away United',
        playerCount: 11,
      );

      testMatch = TestDataBuilders.createTestMatch(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );
    });

    tearDown(() {
      simulator.dispose();
    });

    group('Initialization', () {
      test('should create simulator with default settings', () {
        expect(simulator, isNotNull);
        expect(simulator.events, isNotNull);
      });

      test('should start match and return controls', () async {
        final controls = await simulator.startMatch(testMatch);
        
        expect(controls, isNotNull);
        expect(controls.commands, isNotNull);
      });

      test('should throw error when starting already completed match', () async {
        final completedMatch = testMatch.copyWith(isCompleted: true);
        
        expect(
          () => simulator.startMatch(completedMatch),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when starting second match', () async {
        await simulator.startMatch(testMatch);
        
        expect(
          () => simulator.startMatch(testMatch),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Event Streaming', () {
      test('should emit kickoff event when match starts', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        await simulator.startMatch(testMatch);
        
        // Wait for initial events
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(events, isNotEmpty);
        expect(events.first.newEvent?.type, equals(MatchEventType.kickoff));
        expect(events.first.commentary, contains('underway'));
      });

      test('should emit periodic match updates', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        await simulator.startMatch(testMatch);
        
        // Wait for several simulation cycles
        await Future.delayed(Duration(milliseconds: 500));
        
        expect(events.length, greaterThan(1));
        expect(events.any((e) => e.currentMatch.currentMinute > 0), isTrue);
      });

      test('should track match statistics during simulation', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        await simulator.startMatch(testMatch);
        
        // Wait for some simulation
        await Future.delayed(Duration(milliseconds: 300));
        
        expect(lastEvent, isNotNull);
        expect(lastEvent!.currentMatch.matchStats, isNotNull);
        expect(lastEvent!.currentMatch.playerPerformances, isNotNull);
        expect(lastEvent!.currentMatch.momentumTracker, isNotNull);
      });
    });

    group('Match Controls', () {
      late MatchSimulationControls controls;

      setUp(() async {
        controls = await simulator.startMatch(testMatch);
      });

      test('should pause and resume match', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        // Let match run briefly
        await Future.delayed(Duration(milliseconds: 100));
        final eventsBeforePause = events.length;
        
        // Pause the match
        controls.pause();
        await Future.delayed(Duration(milliseconds: 100));
        final eventsAfterPause = events.length;
        
        // Resume the match
        controls.resume();
        await Future.delayed(Duration(milliseconds: 100));
        final eventsAfterResume = events.length;
        
        // Should have no new events while paused
        expect(eventsAfterPause, equals(eventsBeforePause));
        // Should have new events after resume
        expect(eventsAfterResume, greaterThan(eventsAfterPause));
      });

      test('should change simulation speed', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        // Test different speeds
        controls.setSpeed(4.0); // 4x speed
        await Future.delayed(Duration(milliseconds: 200));
        
        expect(events, isNotEmpty);
        // At 4x speed, should progress faster
        expect(events.last.currentMatch.currentMinute, greaterThan(0));
      });

      test('should apply tactical changes', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final newTactics = TeamTactics(
          mentality: TeamMentality.attacking,
          pressing: 80,
          tempo: 70,
          width: 60,
          directness: 50,
        );
        
        controls.applyTacticalChange(homeTeam.id, newTactics);
        
        // Wait for tactical change event
        await Future.delayed(Duration(milliseconds: 100));
        
        final tacticalEvents = events.where(
          (e) => e.newEvent?.type == MatchEventType.tacticalChange
        );
        
        expect(tacticalEvents, isNotEmpty);
        expect(tacticalEvents.first.commentary, contains('tactical'));
      });

      test('should skip to end of match', () async {
        MatchSimulationEvent? finalEvent;
        simulator.events.listen((event) {
          if (event.currentMatch.isCompleted) {
            finalEvent = event;
          }
        });
        
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        expect(finalEvent, isNotNull);
        expect(finalEvent!.currentMatch.isCompleted, isTrue);
        expect(finalEvent!.currentMatch.result, isNotNull);
      });
    });

    group('Event Generation', () {
      test('should generate goal events with proper metadata', () async {
        final goalEvents = <MatchSimulationEvent>[];
        simulator.events.listen((event) {
          if (event.newEvent?.type == MatchEventType.goal) {
            goalEvents.add(event);
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        if (goalEvents.isNotEmpty) {
          final goalEvent = goalEvents.first;
          expect(goalEvent.newEvent!.metadata, contains('scoringTeam'));
          expect(goalEvent.newEvent!.metadata, contains('homeScore'));
          expect(goalEvent.newEvent!.metadata, contains('awayScore'));
          expect(goalEvent.commentary, contains('GOAL'));
        }
      });

      test('should generate cards with player information', () async {
        final cardEvents = <MatchSimulationEvent>[];
        simulator.events.listen((event) {
          if (event.newEvent?.type == MatchEventType.yellowCard ||
              event.newEvent?.type == MatchEventType.redCard) {
            cardEvents.add(event);
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        if (cardEvents.isNotEmpty) {
          final cardEvent = cardEvents.first;
          expect(cardEvent.newEvent!.playerId, isNotNull);
          expect(cardEvent.newEvent!.playerName, isNotNull);
          expect(cardEvent.commentary, isNotEmpty);
        }
      });

      test('should generate half-time and full-time events', () async {
        final keyEvents = <MatchSimulationEvent>[];
        simulator.events.listen((event) {
          if (event.newEvent?.type == MatchEventType.halfTime ||
              event.newEvent?.type == MatchEventType.fullTime) {
            keyEvents.add(event);
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        // Should have at least full-time event
        expect(keyEvents.any((e) => e.newEvent!.type == MatchEventType.fullTime), isTrue);
      });
    });

    group('Player Performance Tracking', () {
      test('should update player ratings during match', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Let match run for a while
        await Future.delayed(Duration(milliseconds: 500));
        
        expect(lastEvent, isNotNull);
        final performances = lastEvent!.currentMatch.playerPerformances;
        expect(performances, isNotNull);
        
        // All players should have performance data
        final allPlayers = [...homeTeam.players, ...awayTeam.players];
        for (final player in allPlayers) {
          expect(performances![player.id], isNotNull);
          expect(performances[player.id]!.minutesPlayed, greaterThanOrEqualTo(0));
          expect(performances[player.id]!.rating, greaterThanOrEqualTo(1.0));
          expect(performances[player.id]!.rating, lessThanOrEqualTo(10.0));
        }
      });

      test('should track shot statistics', () async {
        final shotEvents = <MatchSimulationEvent>[];
        simulator.events.listen((event) {
          if (event.newEvent?.type == MatchEventType.shotOnTarget ||
              event.newEvent?.type == MatchEventType.shotOffTarget) {
            shotEvents.add(event);
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        if (shotEvents.isNotEmpty) {
          final stats = shotEvents.last.currentMatch.matchStats;
          expect(stats, isNotNull);
          expect(stats!.homeShots + stats.awayShots, greaterThanOrEqualTo(shotEvents.length));
        }
      });
    });

    group('Momentum Tracking', () {
      test('should update momentum during significant events', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        await simulator.startMatch(testMatch);
        
        // Let match run
        await Future.delayed(Duration(milliseconds: 500));
        
        expect(lastEvent, isNotNull);
        final momentum = lastEvent!.currentMatch.momentumTracker;
        expect(momentum, isNotNull);
        expect(momentum!.homeMomentum + momentum.awayMomentum, equals(100.0));
      });

      test('should emit momentum shift events', () async {
        final momentumEvents = <MatchSimulationEvent>[];
        simulator.events.listen((event) {
          if (event.newEvent?.type == MatchEventType.momentumShift) {
            momentumEvents.add(event);
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        // Momentum shifts may or may not occur, but if they do, they should be valid
        for (final event in momentumEvents) {
          expect(event.commentary, contains('momentum'));
        }
      });
    });

    group('Match Statistics', () {
      test('should maintain possession totals of 100%', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        expect(lastEvent, isNotNull);
        final stats = lastEvent!.currentMatch.matchStats;
        expect(stats, isNotNull);
        expect(stats!.homePossession + stats.awayPossession, closeTo(100.0, 0.1));
      });

      test('should track shots on target vs total shots', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for match completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        expect(lastEvent, isNotNull);
        final stats = lastEvent!.currentMatch.matchStats;
        expect(stats, isNotNull);
        
        // Shots on target should not exceed total shots
        expect(stats!.homeShotsOnTarget, lessThanOrEqualTo(stats.homeShots));
        expect(stats.awayShotsOnTarget, lessThanOrEqualTo(stats.awayShots));
      });
    });

    group('Error Handling', () {
      test('should handle disposal during active simulation', () async {
        await simulator.startMatch(testMatch);
        
        // Should not throw when disposing active simulator
        expect(() => simulator.dispose(), returnsNormally);
      });

      test('should validate speed limits', () async {
        final controls = await simulator.startMatch(testMatch);
        
        // Test extreme speed values
        controls.setSpeed(-1.0); // Should be clamped to minimum
        controls.setSpeed(100.0); // Should be clamped to maximum
        
        // Should not throw errors
        await Future.delayed(Duration(milliseconds: 100));
      });

      test('should handle invalid tactical changes gracefully', () async {
        final controls = await simulator.startMatch(testMatch);
        
        // Try to apply tactics to non-existent team
        expect(
          () => controls.applyTacticalChange('invalid_team_id', TeamTactics(
            mentality: TeamMentality.balanced,
            pressing: 50,
            tempo: 50,
            width: 50,
            directness: 50,
          )),
          returnsNormally,
        );
      });
    });

    group('Match Completion', () {
      test('should complete match with valid result', () async {
        MatchSimulationEvent? finalEvent;
        simulator.events.listen((event) {
          if (event.currentMatch.isCompleted) {
            finalEvent = event;
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        expect(finalEvent, isNotNull);
        expect(finalEvent!.currentMatch.isCompleted, isTrue);
        expect(finalEvent!.currentMatch.result, isIn([
          MatchResult.homeWin,
          MatchResult.awayWin,
          MatchResult.draw,
        ]));
        expect(finalEvent!.newEvent?.type, equals(MatchEventType.fullTime));
      });

      test('should have realistic final statistics', () async {
        MatchSimulationEvent? finalEvent;
        simulator.events.listen((event) {
          if (event.currentMatch.isCompleted) {
            finalEvent = event;
          }
        });
        
        final controls = await simulator.startMatch(testMatch);
        controls.skipToEnd();
        
        // Wait for completion
        await Future.delayed(Duration(milliseconds: 1000));
        
        expect(finalEvent, isNotNull);
        final match = finalEvent!.currentMatch;
        
        // Goals should be reasonable
        expect(match.homeGoals, lessThanOrEqualTo(10));
        expect(match.awayGoals, lessThanOrEqualTo(10));
        
        // Match should have progressed through time
        expect(match.currentMinute, greaterThanOrEqualTo(90));
        expect(match.currentMinute, lessThanOrEqualTo(120));
        
        // Should have some events
        expect(match.events.length, greaterThan(2)); // At least kickoff and full-time
      });
    });
  });

  group('MatchSimulationControls', () {
    test('should dispose properly', () {
      final controls = MatchSimulationControls();
      
      expect(() => controls.dispose(), returnsNormally);
      
      // Should still be able to call methods after disposal
      expect(() => controls.pause(), returnsNormally);
      expect(() => controls.resume(), returnsNormally);
    });
  });

  group('MatchSimulationEvent', () {
    test('should have proper string representation', () {
      final match = TestDataBuilders.createTestMatch();
      final event = MatchSimulationEvent(
        currentMatch: match.copyWith(currentMinute: 45),
        commentary: 'Test commentary',
      );
      
      expect(event.toString(), contains('45'));
    });

    test('should handle null values properly', () {
      final match = TestDataBuilders.createTestMatch();
      final event = MatchSimulationEvent(
        currentMatch: match,
        newEvent: null,
        commentary: null,
      );
      
      expect(event.newEvent, isNull);
      expect(event.commentary, isNull);
      expect(event.metadata, isEmpty);
    });
  });
}
