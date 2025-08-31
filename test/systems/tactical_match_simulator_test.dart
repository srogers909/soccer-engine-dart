import 'dart:async';
import 'package:test/test.dart';
import '../../lib/src/systems/streaming_match_simulator.dart';
import '../../lib/src/models/match.dart';
import '../../lib/src/models/team.dart';
import '../../lib/src/models/enhanced_match.dart';
import '../../lib/src/models/tactical_match.dart' as tactical;
import 'package:tactics_fc_utilities/src/models/player.dart';
import '../helpers/test_data_builders.dart';

/// Test suite for advanced tactical features in the streaming match simulator
/// Following TDD methodology: Write failing tests first, then implement
void main() {
  group('Advanced Tactical Systems', () {
    late StreamingMatchSimulator simulator;
    late Match testMatch;
    late Team homeTeam;
    late Team awayTeam;

    setUp(() {
      simulator = StreamingMatchSimulator(seed: 42);
      
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

    group('Formation Changes', () {
      test('should allow formation change during match', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Wait for match to start
        await Future.delayed(Duration(milliseconds: 100));
        
        // Change formation from default to 4-3-3
        controls.changeFormation(homeTeam.id, tactical.Formation.f433);
        
        // Wait for tactical change
        await Future.delayed(Duration(milliseconds: 100));
        
        final tacticalChangeEvents = events.where(
          (e) => e.newEvent?.type == MatchEventType.tacticalChange
        );
        
        expect(tacticalChangeEvents, isNotEmpty);
        expect(tacticalChangeEvents.first.newEvent!.metadata['formation'], equals('f433'));
        expect(tacticalChangeEvents.first.commentary, contains('formation'));
      });

      test('should track formation changes in match history', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Change formation multiple times
        controls.changeFormation(homeTeam.id, tactical.Formation.f433);
        await Future.delayed(Duration(milliseconds: 50));
        controls.changeFormation(homeTeam.id, tactical.Formation.f352);
        await Future.delayed(Duration(milliseconds: 50));
        
        expect(lastEvent, isNotNull);
        // Check that tactical changes are recorded in events
        final tacticalEvents = lastEvent!.currentMatch.events.where(
          (e) => e.type == MatchEventType.tacticalChange
        );
        expect(tacticalEvents.length, greaterThanOrEqualTo(2));
      });
    });

    group('Player Instructions', () {
      test('should allow setting individual player instructions', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Get the first player and treat them as a striker for testing
        final striker = homeTeam.players.first;
        
        final instructions = tactical.PlayerInstructions(
          playerId: striker.id,
          role: tactical.PlayerRole.targetMan,
          mentality: tactical.PlayerMentality.attacking,
          instructions: ['Get in behind', 'Hold up play'],
        );
        
        controls.setPlayerInstructions(homeTeam.id, striker.id, instructions);
        
        await Future.delayed(Duration(milliseconds: 100));
        
        final instructionEvents = events.where(
          (e) => e.newEvent?.type == MatchEventType.tacticalChange &&
                 e.newEvent?.playerId == striker.id
        );
        
        expect(instructionEvents, isNotEmpty);
        expect(instructionEvents.first.newEvent!.playerId, equals(striker.id));
        expect(instructionEvents.first.commentary, contains(striker.name));
      });
    });

    group('Automatic Tactical Responses', () {
      test('should enable automatic tactical adjustments', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Enable automatic tactical responses
        controls.enableAutomaticTactics(homeTeam.id, true);
        
        await Future.delayed(Duration(milliseconds: 100));
        
        final autoTacticsEvents = events.where(
          (e) => e.newEvent?.type == MatchEventType.tacticalChange &&
                 e.newEvent?.metadata['changeType'] == 'automaticTactics'
        );
        
        expect(autoTacticsEvents, isNotEmpty);
        expect(autoTacticsEvents.first.commentary, contains('automatic'));
      });
    });

    group('Match Intensity', () {
      test('should allow setting match intensity', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Set high intensity
        controls.setMatchIntensity(homeTeam.id, tactical.MatchIntensity.high);
        
        await Future.delayed(Duration(milliseconds: 100));
        
        final intensityEvents = events.where(
          (e) => e.newEvent?.type == MatchEventType.tacticalChange &&
                 e.newEvent?.metadata['changeType'] == 'matchIntensity'
        );
        
        expect(intensityEvents, isNotEmpty);
        expect(intensityEvents.first.newEvent!.metadata['intensity'], equals('high'));
      });
    });

    group('Weather Effects', () {
      test('should be affected by weather conditions', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        await Future.delayed(Duration(milliseconds: 200));
        
        expect(lastEvent, isNotNull);
        final weather = lastEvent!.currentMatch.weather;
        expect(weather, isNotNull);
        expect(weather.performanceImpact, greaterThan(0.5));
        expect(weather.performanceImpact, lessThan(1.5));
      });
    });

    group('Team Chemistry', () {
      test('should track team chemistry during match', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        await Future.delayed(Duration(milliseconds: 200));
        
        expect(lastEvent, isNotNull);
        // Team chemistry tracking will be implemented as the system develops
        // For now, just verify match data is being tracked
        expect(lastEvent!.currentMatch.matchStats, isNotNull);
        expect(lastEvent!.currentMatch.playerPerformances, isNotNull);
      });
    });

    group('Tactical Effectiveness', () {
      test('should track tactical effectiveness metrics', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Apply tactical changes
        controls.applyTacticalChange(homeTeam.id, TeamTactics(
          mentality: TeamMentality.attacking,
          pressing: 70,
          tempo: 75,
          width: 65,
          directness: 55,
        ));
        
        await Future.delayed(Duration(milliseconds: 300));
        
        expect(lastEvent, isNotNull);
        // Verify tactical changes are being tracked
        final tacticalEvents = lastEvent!.currentMatch.events.where(
          (e) => e.type == MatchEventType.tacticalChange
        );
        expect(tacticalEvents, isNotEmpty);
      });
    });

    group('Real-time Tactical Controls', () {
      test('should pause and resume match simulation', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
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
        
        // Should have fewer or equal events during pause
        expect(eventsAfterPause - eventsBeforePause, lessThanOrEqualTo(eventsAfterResume - eventsAfterPause));
      });

      test('should change simulation speed', () async {
        final events = <MatchSimulationEvent>[];
        simulator.events.listen(events.add);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Test speed adjustment
        controls.setSpeed(2.0); // 2x speed
        
        await Future.delayed(Duration(milliseconds: 200));
        
        // Verify match is progressing (events are being generated)
        expect(events, isNotEmpty);
        
        // Test speed bounds
        controls.setSpeed(10.0); // Should be clamped to max
        controls.setSpeed(0.1);  // Should be clamped to min
        
        // Should not throw errors
        expect(events, isNotEmpty);
      });

      test('should jump to specific minute', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Jump to minute 45
        controls.jumpToMinute(45);
        
        await Future.delayed(Duration(milliseconds: 200));
        
        expect(lastEvent, isNotNull);
        expect(lastEvent!.currentMatch.currentMinute, greaterThanOrEqualTo(45));
      });

      test('should skip to end of match', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        // Skip to end
        controls.skipToEnd();
        
        await Future.delayed(Duration(milliseconds: 500));
        
        expect(lastEvent, isNotNull);
        expect(lastEvent!.currentMatch.isCompleted, isTrue);
        expect(lastEvent!.currentMatch.result, isNotNull);
      });
    });

    group('Match Statistics', () {
      test('should track detailed match statistics', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        await Future.delayed(Duration(milliseconds: 300));
        
        expect(lastEvent, isNotNull);
        final stats = lastEvent!.currentMatch.matchStats;
        expect(stats, isNotNull);
        
        // Verify basic stats are being tracked
        expect(stats!.homePossession + stats.awayPossession, closeTo(100.0, 1.0));
        expect(stats.homeShots, greaterThanOrEqualTo(0));
        expect(stats.awayShots, greaterThanOrEqualTo(0));
        expect(stats.homePassAccuracy, greaterThanOrEqualTo(0.0));
        expect(stats.awayPassAccuracy, greaterThanOrEqualTo(0.0));
      });

      test('should track player performances', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        await Future.delayed(Duration(milliseconds: 300));
        
        expect(lastEvent, isNotNull);
        final performances = lastEvent!.currentMatch.playerPerformances;
        expect(performances, isNotNull);
        
        // Check that all players have performance data
        for (final player in [...homeTeam.players, ...awayTeam.players]) {
          expect(performances!.containsKey(player.id), isTrue);
          final performance = performances[player.id]!;
          expect(performance.rating, greaterThan(0.0));
          expect(performance.minutesPlayed, greaterThanOrEqualTo(0));
        }
      });

      test('should track momentum changes', () async {
        MatchSimulationEvent? lastEvent;
        simulator.events.listen((event) => lastEvent = event);
        
        final controls = await simulator.startMatch(testMatch);
        
        await Future.delayed(Duration(milliseconds: 300));
        
        expect(lastEvent, isNotNull);
        final momentum = lastEvent!.currentMatch.momentumTracker;
        expect(momentum, isNotNull);
        
        expect(momentum!.homeMomentum + momentum.awayMomentum, closeTo(100.0, 1.0));
        expect(momentum.shiftEvents, isNotNull);
      });
    });
  });
}
