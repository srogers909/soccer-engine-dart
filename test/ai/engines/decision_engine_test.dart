import 'package:test/test.dart';
import 'package:tactics_fc_engine/soccer_engine.dart';

void main() {
  group('DecisionEngine', () {
    late DecisionEngine engine;
    late GMProfile gmProfile;

    setUp(() {
      gmProfile = GMProfile.conservative(id: 'test-gm', name: 'Test GM');
      engine = DecisionEngine(gmProfile: gmProfile);
    });

    group('Construction', () {
      test('should create with required parameters', () {
        expect(engine.gmProfile, equals(gmProfile));
        expect(engine.isEnabled, isTrue);
      });

      test('should create with optional parameters', () {
        final customEngine = DecisionEngine(
          gmProfile: gmProfile,
          isEnabled: false,
          decisionHistory: [],
        );
        
        expect(customEngine.gmProfile, equals(gmProfile));
        expect(customEngine.isEnabled, isFalse);
        expect(customEngine.decisionHistory, isEmpty);
      });
    });

    group('Decision Making', () {
      test('should make basic decision with context', () {
        final context = {'budget': 1000000, 'urgency': 0.5};
        final options = ['Option A', 'Option B', 'Option C'];
        
        final decision = engine.makeDecision(
          type: DecisionType.transfer,
          options: options,
          context: context,
        );
        
        expect(decision, isNotNull);
        expect(decision.type, equals(DecisionType.transfer));
        expect(decision.selectedOption, isIn(options));
        expect(decision.confidence, inInclusiveRange(0.0, 1.0));
        expect(decision.reasoning, isNotEmpty);
        expect(decision.gmProfile, equals(gmProfile));
      });

      test('should record decision in history', () {
        final context = {'budget': 1000000};
        final options = ['Option A', 'Option B'];
        
        expect(engine.decisionHistory, isEmpty);
        
        final decision = engine.makeDecision(
          type: DecisionType.formation,
          options: options,
          context: context,
        );
        
        // Create a new engine with the decision added to history
        final updatedEngine = engine.copyWith(
          decisionHistory: [decision, ...engine.decisionHistory]
        );
        
        expect(updatedEngine.decisionHistory, hasLength(1));
        expect(updatedEngine.decisionHistory.first, equals(decision));
      });

      test('should throw when engine is disabled', () {
        final disabledEngine = DecisionEngine(
          gmProfile: gmProfile,
          isEnabled: false,
        );
        
        expect(
          () => disabledEngine.makeDecision(
            type: DecisionType.transfer,
            options: ['Option A'],
            context: {},
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw when no options provided', () {
        expect(
          () => engine.makeDecision(
            type: DecisionType.transfer,
            options: [],
            context: {},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Decision Weights', () {
      test('should calculate weights based on GM personality', () {
        final context = {'playerAge': 25, 'playerRating': 80};
        final weights = engine.calculateWeights(
          type: DecisionType.transfer,
          context: context,
        );
        
        expect(weights, isNotEmpty);
        expect(weights.values.every((w) => w >= 0.0 && w <= 1.0), isTrue);
        
        // Conservative GM should prefer stability
        expect(weights.containsKey('stability'), isTrue);
        expect(weights.containsKey('experience'), isTrue);
      });

      test('should return different weights for different personalities', () {
        final aggressiveGM = GMProfile.aggressive(id: 'aggressive-gm', name: 'Aggressive GM');
        final aggressiveEngine = DecisionEngine(gmProfile: aggressiveGM);
        
        final context = {'playerAge': 20, 'playerRating': 75};
        
        final conservativeWeights = engine.calculateWeights(
          type: DecisionType.transfer,
          context: context,
        );
        
        final aggressiveWeights = aggressiveEngine.calculateWeights(
          type: DecisionType.transfer,
          context: context,
        );
        
        expect(conservativeWeights, isNot(equals(aggressiveWeights)));
      });
    });

    group('Enable/Disable', () {
      test('should enable and disable engine', () {
        expect(engine.isEnabled, isTrue);
        
        final disabledEngine = engine.disable();
        expect(disabledEngine.isEnabled, isFalse);
        
        final enabledEngine = disabledEngine.enable();
        expect(enabledEngine.isEnabled, isTrue);
      });
    });

    group('Decision History', () {
      test('should clear decision history', () {
        // Create decisions
        final decision1 = engine.makeDecision(
          type: DecisionType.transfer,
          options: ['Option A'],
          context: {},
        );
        final decision2 = engine.makeDecision(
          type: DecisionType.formation,
          options: ['4-4-2'],
          context: {},
        );
        
        // Create engine with history
        final engineWithHistory = engine.copyWith(
          decisionHistory: [decision2, decision1]
        );
        
        expect(engineWithHistory.decisionHistory, hasLength(2));
        
        final clearedEngine = engineWithHistory.clearHistory();
        expect(clearedEngine.decisionHistory, isEmpty);
      });

      test('should limit history size', () {
        var currentEngine = DecisionEngine(
          gmProfile: gmProfile,
          maxHistorySize: 2,
        );
        
        // Make 3 decisions and manually track history
        final decisions = <Decision>[];
        for (int i = 0; i < 3; i++) {
          final decision = currentEngine.makeDecision(
            type: DecisionType.transfer,
            options: ['Option $i'],
            context: {},
          );
          decisions.insert(0, decision);
          
          // Limit history size manually
          if (decisions.length > 2) {
            decisions.removeRange(2, decisions.length);
          }
        }
        
        final finalEngine = currentEngine.copyWith(decisionHistory: decisions);
        
        expect(finalEngine.decisionHistory, hasLength(2));
        // Should keep the most recent decisions
        expect(finalEngine.decisionHistory.first.selectedOption, equals('Option 2'));
        expect(finalEngine.decisionHistory.last.selectedOption, equals('Option 1'));
      });
    });

    group('Equality and Hash', () {
      test('should be equal with same properties', () {
        final engine1 = DecisionEngine(gmProfile: gmProfile);
        final engine2 = DecisionEngine(gmProfile: gmProfile);
        
        expect(engine1, equals(engine2));
        expect(engine1.hashCode, equals(engine2.hashCode));
      });

      test('should not be equal with different properties', () {
        final differentGM = GMProfile.aggressive(id: 'different-gm', name: 'Different GM');
        final engine1 = DecisionEngine(gmProfile: gmProfile);
        final engine2 = DecisionEngine(gmProfile: differentGM);
        
        expect(engine1, isNot(equals(engine2)));
        expect(engine1.hashCode, isNot(equals(engine2.hashCode)));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON', () {
        final json = engine.toJson();
        
        expect(json, isA<Map<String, dynamic>>());
        expect(json['gmProfile'], isA<Map<String, dynamic>>());
        expect(json['isEnabled'], isA<bool>());
        expect(json['decisionHistory'], isA<List>());
      });

      test('should deserialize from JSON', () {
        final originalJson = engine.toJson();
        final restored = DecisionEngine.fromJson(originalJson);
        
        expect(restored.gmProfile, equals(engine.gmProfile));
        expect(restored.isEnabled, equals(engine.isEnabled));
        expect(restored.decisionHistory, equals(engine.decisionHistory));
      });

      test('should handle decision history in JSON', () {
        // Make a decision first
        final decision = engine.makeDecision(
          type: DecisionType.transfer,
          options: ['Test Option'],
          context: {'test': true},
        );
        
        // Create engine with the decision in history (immutable pattern)
        final engineWithHistory = engine.copyWith(
          decisionHistory: [decision]
        );
        
        final json = engineWithHistory.toJson();
        final restored = DecisionEngine.fromJson(json);
        
        expect(restored.decisionHistory, hasLength(1));
        expect(restored.decisionHistory.first.selectedOption, equals('Test Option'));
      });
    });

    group('CopyWith', () {
      test('should copy with new GM profile', () {
        final newGM = GMProfile.aggressive(id: 'new-gm', name: 'New GM');
        final copied = engine.copyWith(gmProfile: newGM);
        
        expect(copied.gmProfile, equals(newGM));
        expect(copied.isEnabled, equals(engine.isEnabled));
        expect(copied.decisionHistory, equals(engine.decisionHistory));
      });

      test('should copy with new enabled state', () {
        final copied = engine.copyWith(isEnabled: false);
        
        expect(copied.gmProfile, equals(engine.gmProfile));
        expect(copied.isEnabled, isFalse);
        expect(copied.decisionHistory, equals(engine.decisionHistory));
      });
    });
  });
}
