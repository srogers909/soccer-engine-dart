import 'package:test/test.dart';
import 'package:soccer_engine/src/systems/formation_tactical_system.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_utilities/src/models/player.dart';
import 'package:soccer_engine/src/models/enhanced_match.dart';
import 'package:soccer_engine/src/models/tactical_analysis.dart';
import 'package:soccer_engine/src/models/match.dart';

void main() {
  group('Formation and Tactical System', () {
    late FormationTacticalSystem tacticalSystem;
    late Team testTeam;

    setUp(() {
      tacticalSystem = FormationTacticalSystem();
      
      final stadium = Stadium(
        name: 'Test Stadium',
        city: 'Test City',
        capacity: 50000,
      );

      testTeam = Team(
        id: 'test-team',
        name: 'Test Team',
        city: 'Test City',
        foundedYear: 2000,
        stadium: stadium,
        formation: Formation.f442,
      );

      testTeam = _addPlayersToTeam(testTeam);
    });

    group('Formation Management', () {
      test('should validate formation compatibility with available players', () {
        final validationResult = tacticalSystem.validateFormation(testTeam, Formation.f433);
        expect(validationResult.isValid, isTrue);
        expect(validationResult.errors, isEmpty);
      });

      test('should detect invalid formation due to insufficient players', () {
        final incompleteTeam = Team(
          id: 'incomplete-team',
          name: 'Incomplete Team',
          city: 'Test City',
          foundedYear: 2000,
          stadium: testTeam.stadium,
          formation: Formation.f442,
        );

        // Add only 5 players
        var team = incompleteTeam;
        for (int i = 1; i <= 5; i++) {
          final player = Player(
            id: 'player-$i',
            name: 'Player $i',
            age: 25,
            position: PlayerPosition.midfielder,
            technical: 70,
            physical: 70,
            mental: 70,
          );
          team = team.addPlayer(player);
        }

        final validationResult = tacticalSystem.validateFormation(team, Formation.f442);
        expect(validationResult.isValid, isFalse);
        expect(validationResult.errors, isNotEmpty);
        expect(validationResult.errors.first, contains('Insufficient players'));
      });

      test('should provide formation recommendations based on team composition', () {
        final recommendations = tacticalSystem.getFormationRecommendations(testTeam);
        
        expect(recommendations, isNotEmpty);
        expect(recommendations.length, greaterThanOrEqualTo(3));
        
        for (final recommendation in recommendations) {
          expect(recommendation.formation, isA<Formation>());
          expect(recommendation.suitabilityScore, greaterThanOrEqualTo(0.0));
          expect(recommendation.suitabilityScore, lessThanOrEqualTo(100.0));
          expect(recommendation.reasons, isNotEmpty);
        }
      });

      test('should calculate formation suitability based on player positions', () {
        // Team with many forwards should prefer attacking formations
        var attackingTeam = testTeam;
        for (int i = 1; i <= 4; i++) {
          final forward = Player(
            id: 'extra-fwd-$i',
            name: 'Extra Forward $i',
            age: 25,
            position: PlayerPosition.forward,
            technical: 85,
            physical: 80,
            mental: 75,
          );
          attackingTeam = attackingTeam.addPlayer(forward);
        }

        final recommendations = tacticalSystem.getFormationRecommendations(attackingTeam);
        final attackingFormations = recommendations.where((r) => 
          r.formation == Formation.f343 || r.formation == Formation.f352);
        
        expect(attackingFormations, isNotEmpty);
      });

      test('should generate optimal starting XI for formation', () {
        final startingXI = tacticalSystem.generateOptimalStartingXI(testTeam, Formation.f433);
        
        expect(startingXI, isNotNull);
        expect(startingXI!.length, equals(11));
        
        // Check position distribution for 4-3-3
        final goalkeepers = startingXI.where((p) => p.position == PlayerPosition.goalkeeper);
        final defenders = startingXI.where((p) => p.position == PlayerPosition.defender);
        final midfielders = startingXI.where((p) => p.position == PlayerPosition.midfielder);
        final forwards = startingXI.where((p) => p.position == PlayerPosition.forward);
        
        expect(goalkeepers.length, equals(1));
        expect(defenders.length, equals(4));
        expect(midfielders.length, equals(3));
        expect(forwards.length, equals(3));
      });

      test('should handle formation changes during match preparation', () {
        final originalFormation = testTeam.formation;
        final newFormation = Formation.f433;
        
        final updatedTeam = tacticalSystem.applyFormationChange(testTeam, newFormation);
        
        expect(updatedTeam.formation, equals(newFormation));
        expect(updatedTeam.formation, isNot(equals(originalFormation)));
        
        // Should auto-generate new starting XI for new formation
        final newStartingXI = tacticalSystem.generateOptimalStartingXI(updatedTeam, newFormation);
        expect(newStartingXI, isNotNull);
        expect(newStartingXI!.length, equals(11));
      });
    });

    group('Tactical Instructions', () {
      test('should create and validate tactical instructions', () {
        final tactics = TeamTactics(
          mentality: TeamMentality.attacking,
          pressing: 80,
          tempo: 75,
          width: 60,
          directness: 70,
        );

        final validation = tacticalSystem.validateTactics(tactics);
        expect(validation.isValid, isTrue);
        expect(validation.errors, isEmpty);
      });

      test('should detect invalid tactical instruction values', () {
        final invalidTactics = TeamTactics(
          mentality: TeamMentality.balanced,
          pressing: 150, // Invalid: over 100
          tempo: -10,    // Invalid: negative
          width: 50,
          directness: 50,
        );

        final validation = tacticalSystem.validateTactics(invalidTactics);
        expect(validation.isValid, isFalse);
        expect(validation.errors, isNotEmpty);
        expect(validation.errors.any((e) => e.contains('pressing')), isTrue);
        expect(validation.errors.any((e) => e.contains('tempo')), isTrue);
      });

      test('should provide tactical presets for different playstyles', () {
        final presets = tacticalSystem.getTacticalPresets();
        
        expect(presets, isNotEmpty);
        expect(presets.length, greaterThanOrEqualTo(5));
        
        final presetNames = presets.keys.toList();
        expect(presetNames, contains('Attacking'));
        expect(presetNames, contains('Defensive'));
        expect(presetNames, contains('Balanced'));
        expect(presetNames, contains('Counter Attack'));
        expect(presetNames, contains('Possession'));
        
        for (final preset in presets.values) {
          expect(preset.pressing, greaterThanOrEqualTo(0));
          expect(preset.pressing, lessThanOrEqualTo(100));
          expect(preset.tempo, greaterThanOrEqualTo(0));
          expect(preset.tempo, lessThanOrEqualTo(100));
        }
      });

      test('should calculate tactical compatibility with formation', () {
        final defensiveFormation = Formation.f541;
        final attackingTactics = TeamTactics(
          mentality: TeamMentality.veryAttacking,
          pressing: 90,
          tempo: 85,
          width: 80,
          directness: 75,
        );

        final compatibility = tacticalSystem.calculateTacticalCompatibility(
          defensiveFormation, 
          attackingTactics
        );
        
        expect(compatibility.score, greaterThanOrEqualTo(0.0));
        expect(compatibility.score, lessThanOrEqualTo(100.0));
        expect(compatibility.warnings, isA<List<String>>());
        
        // Defensive formation with attacking tactics should have warnings
        expect(compatibility.score, lessThan(80.0));
        expect(compatibility.warnings, isNotEmpty);
      });

      test('should suggest tactical adjustments for better compatibility', () {
        final formation = Formation.f343;
        final defensiveTactics = TeamTactics(
          mentality: TeamMentality.veryDefensive,
          pressing: 20,
          tempo: 30,
          width: 40,
          directness: 35,
        );

        final suggestions = tacticalSystem.suggestTacticalAdjustments(
          formation, 
          defensiveTactics
        );
        
        expect(suggestions, isNotEmpty);
        
        for (final suggestion in suggestions) {
          expect(suggestion.parameter, isNotEmpty);
          expect(suggestion.currentValue, isA<num>());
          expect(suggestion.suggestedValue, isA<num>());
          expect(suggestion.reason, isNotEmpty);
        }
      });
    });

    group('In-Match Tactical Changes', () {
      test('should plan tactical changes for different match scenarios', () {
        final scenarios = [
          MatchScenario.losing,
          MatchScenario.winning,
          MatchScenario.drawing,
          MatchScenario.behindByTwo,
          MatchScenario.playerSentOff,
        ];

        for (final scenario in scenarios) {
          final changes = tacticalSystem.planTacticalChanges(testTeam, scenario);
          
          expect(changes, isNotNull);
          expect(changes.targetMinute, greaterThanOrEqualTo(0));
          expect(changes.targetMinute, lessThanOrEqualTo(90));
          expect(changes.newTactics, isNotNull);
          expect(changes.reason, isNotEmpty);
        }
      });

      test('should generate substitution recommendations', () {
        final currentMinute = 65;
        final scenario = MatchScenario.losing;
        
        final substitutions = tacticalSystem.recommendSubstitutions(
          testTeam, 
          currentMinute, 
          scenario
        );
        
        expect(substitutions, isNotEmpty);
        expect(substitutions.length, lessThanOrEqualTo(3)); // Max 3 substitutions
        
        for (final sub in substitutions) {
          expect(sub.playerOut, isNotNull);
          expect(sub.playerIn, isNotNull);
          expect(sub.reason, isNotEmpty);
          expect(sub.priority, greaterThanOrEqualTo(1));
          expect(sub.priority, lessThanOrEqualTo(3));
        }
      });

      test('should adapt tactics based on match momentum', () {
        final highMomentum = MomentumTracker(
          homeMomentum: 80.0,
          awayMomentum: 20.0,
          lastShift: 45,
          shiftEvents: ['High momentum phase'],
        );

        final lowMomentum = MomentumTracker(
          homeMomentum: 20.0,
          awayMomentum: 80.0,
          lastShift: 60,
          shiftEvents: ['Low momentum phase'],
        );

        final highMomentumTactics = tacticalSystem.adaptTacticsToMomentum(
          testTeam, 
          highMomentum, 
          isHomeTeam: true
        );

        final lowMomentumTactics = tacticalSystem.adaptTacticsToMomentum(
          testTeam, 
          lowMomentum, 
          isHomeTeam: true
        );

        // High momentum should suggest more attacking tactics
        expect(highMomentumTactics.suggestedTactics.pressing, 
               greaterThan(lowMomentumTactics.suggestedTactics.pressing));
        expect(highMomentumTactics.suggestedTactics.tempo, 
               greaterThan(lowMomentumTactics.suggestedTactics.tempo));
      });
    });

    group('Advanced Tactical Analysis', () {
      test('should analyze tactical effectiveness against opponent', () {
        final opponentTeam = _createOpponentTeam();
        final myTactics = TeamTactics(
          mentality: TeamMentality.attacking,
          pressing: 75,
          tempo: 70,
          width: 65,
          directness: 60,
        );

        final analysis = tacticalSystem.analyzeTacticalMatchup(
          testTeam, 
          opponentTeam, 
          myTactics
        );

        expect(analysis.overallEffectiveness, greaterThanOrEqualTo(0.0));
        expect(analysis.overallEffectiveness, lessThanOrEqualTo(100.0));
        expect(analysis.strengths, isNotEmpty);
        expect(analysis.weaknesses, isNotEmpty);
        expect(analysis.recommendations, isNotEmpty);
      });

      test('should calculate formation counter-effectiveness', () {
        final myFormation = Formation.f433;
        final opponentFormation = Formation.f541;

        final counterAnalysis = tacticalSystem.analyzeFormationCounter(
          myFormation, 
          opponentFormation
        );

        expect(counterAnalysis.effectiveness, greaterThanOrEqualTo(0.0));
        expect(counterAnalysis.effectiveness, lessThanOrEqualTo(100.0));
        expect(counterAnalysis.advantages, isA<List<String>>());
        expect(counterAnalysis.disadvantages, isA<List<String>>());
        expect(counterAnalysis.suggestions, isA<List<String>>());
      });

      test('should track tactical performance over time', () {
        final tacticalHistory = <TacticalPerformanceRecord>[
          TacticalPerformanceRecord(
            formation: Formation.f442,
            tactics: TeamTactics(
              mentality: TeamMentality.balanced,
              pressing: 50,
              tempo: 50,
              width: 50,
              directness: 50,
            ),
            matchResult: MatchResult.homeWin,
            goalsScored: 2,
            goalsConceded: 1,
            possession: 55.0,
            passAccuracy: 82.0,
          ),
          TacticalPerformanceRecord(
            formation: Formation.f433,
            tactics: TeamTactics(
              mentality: TeamMentality.attacking,
              pressing: 70,
              tempo: 75,
              width: 60,
              directness: 65,
            ),
            matchResult: MatchResult.draw,
            goalsScored: 1,
            goalsConceded: 1,
            possession: 62.0,
            passAccuracy: 78.0,
          ),
        ];

        final analysis = tacticalSystem.analyzePerformanceTrends(tacticalHistory);
        
        expect(analysis.mostEffectiveFormation, isNotNull);
        expect(analysis.averageGoalsScored, greaterThan(0.0));
        expect(analysis.averageGoalsConceded, greaterThanOrEqualTo(0.0));
        expect(analysis.winRate, greaterThanOrEqualTo(0.0));
        expect(analysis.winRate, lessThanOrEqualTo(100.0));
        expect(analysis.recommendations, isNotEmpty);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle empty team gracefully', () {
        final emptyTeam = Team(
          id: 'empty-team',
          name: 'Empty Team',
          city: 'Test City',
          foundedYear: 2000,
          stadium: testTeam.stadium,
          formation: Formation.f442,
        );

        final validation = tacticalSystem.validateFormation(emptyTeam, Formation.f442);
        expect(validation.isValid, isFalse);
        expect(validation.errors, contains('No players available'));

        final startingXI = tacticalSystem.generateOptimalStartingXI(emptyTeam, Formation.f442);
        expect(startingXI, isNull);
      });

      test('should handle invalid formation enum gracefully', () {
        // This tests defensive programming for potential future enum additions
        expect(() => tacticalSystem.validateFormation(testTeam, Formation.f442), 
               returnsNormally);
      });

      test('should validate tactical instruction boundaries', () {
        final extremeTactics = TeamTactics(
          mentality: TeamMentality.veryAttacking,
          pressing: 100,
          tempo: 100,
          width: 100,
          directness: 100,
        );

        final validation = tacticalSystem.validateTactics(extremeTactics);
        expect(validation.isValid, isTrue); // Boundary values should be valid
      });
    });
  });
}

/// Helper function to add a full squad to a team for testing
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
  
  // Add 8 defenders  
  for (int i = 1; i <= 8; i++) {
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
  
  // Add 8 midfielders
  for (int i = 1; i <= 8; i++) {
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
  
  // Add 6 forwards
  for (int i = 1; i <= 6; i++) {
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

/// Helper function to create an opponent team for testing
Team _createOpponentTeam() {
  final stadium = Stadium(
    name: 'Opponent Stadium',
    city: 'Opponent City',
    capacity: 40000,
  );

  var team = Team(
    id: 'opponent-team',
    name: 'Opponent Team',
    city: 'Opponent City',
    foundedYear: 1995,
    stadium: stadium,
    formation: Formation.f541,
    morale: 70,
  );

  // Add defensive-minded players
  for (int i = 1; i <= 2; i++) {
    final gk = Player(
      id: 'opp-gk-$i',
      name: 'Opp GK $i',
      age: 28,
      position: PlayerPosition.goalkeeper,
      technical: 65,
      physical: 75,
      mental: 80,
    );
    team = team.addPlayer(gk);
  }
  
  for (int i = 1; i <= 8; i++) {
    final def = Player(
      id: 'opp-def-$i',
      name: 'Opp DEF $i',
      age: 27,
      position: PlayerPosition.defender,
      technical: 60,
      physical: 85,
      mental: 75,
    );
    team = team.addPlayer(def);
  }
  
  for (int i = 1; i <= 6; i++) {
    final mid = Player(
      id: 'opp-mid-$i',
      name: 'Opp MID $i',
      age: 26,
      position: PlayerPosition.midfielder,
      technical: 70,
      physical: 75,
      mental: 70,
    );
    team = team.addPlayer(mid);
  }
  
  for (int i = 1; i <= 4; i++) {
    final fwd = Player(
      id: 'opp-fwd-$i',
      name: 'Opp FWD $i',
      age: 25,
      position: PlayerPosition.forward,
      technical: 75,
      physical: 80,
      mental: 65,
    );
    team = team.addPlayer(fwd);
  }
  
  return team;
}
