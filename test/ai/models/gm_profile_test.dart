import 'package:test/test.dart';
import 'package:tactics_fc_engine/src/ai/models/gm_profile.dart';

void main() {
  group('GMProfile Tests', () {
    group('GM Profile Construction', () {
      test('should create GM profile with required fields', () {
        final profile = GMProfile(
          id: 'gm1',
          name: 'Carlo Ancelotti',
          personality: GMPersonality.balanced,
        );

        expect(profile.id, equals('gm1'));
        expect(profile.name, equals('Carlo Ancelotti'));
        expect(profile.personality, equals(GMPersonality.balanced));
        expect(profile.riskTolerance, equals(0.5)); // Default value
        expect(profile.youthFocus, equals(0.5)); // Default value
        expect(profile.tacticalFocus, equals(0.5)); // Default value
      });

      test('should create aggressive GM profile with custom weights', () {
        final profile = GMProfile(
          id: 'gm2',
          name: 'Jose Mourinho',
          personality: GMPersonality.aggressive,
          riskTolerance: 0.8,
          youthFocus: 0.2,
          tacticalFocus: 0.9,
          transferBudgetRatio: 0.7,
          wageBudgetRatio: 0.6,
        );

        expect(profile.personality, equals(GMPersonality.aggressive));
        expect(profile.riskTolerance, equals(0.8));
        expect(profile.youthFocus, equals(0.2));
        expect(profile.tacticalFocus, equals(0.9));
        expect(profile.transferBudgetRatio, equals(0.7));
        expect(profile.wageBudgetRatio, equals(0.6));
      });

      test('should throw error for empty GM ID', () {
        expect(() => GMProfile(
          id: '',
          name: 'Test Manager',
          personality: GMPersonality.balanced,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for empty GM name', () {
        expect(() => GMProfile(
          id: 'gm1',
          name: '',
          personality: GMPersonality.balanced,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for invalid risk tolerance', () {
        expect(() => GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.balanced,
          riskTolerance: 1.5, // Invalid: > 1.0
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for negative youth focus', () {
        expect(() => GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.balanced,
          youthFocus: -0.1, // Invalid: < 0.0
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('GM Personality Presets', () {
      test('should create conservative GM with correct defaults', () {
        final profile = GMProfile.conservative(
          id: 'gm1',
          name: 'Conservative Manager',
        );

        expect(profile.personality, equals(GMPersonality.conservative));
        expect(profile.riskTolerance, equals(0.2));
        expect(profile.youthFocus, equals(0.7));
        expect(profile.tacticalFocus, equals(0.3));
        expect(profile.transferBudgetRatio, equals(0.4));
      });

      test('should create aggressive GM with correct defaults', () {
        final profile = GMProfile.aggressive(
          id: 'gm2',
          name: 'Aggressive Manager',
        );

        expect(profile.personality, equals(GMPersonality.aggressive));
        expect(profile.riskTolerance, equals(0.8));
        expect(profile.youthFocus, equals(0.2));
        expect(profile.tacticalFocus, equals(0.4));
        expect(profile.transferBudgetRatio, equals(0.8));
      });

      test('should create youth-focused GM with correct defaults', () {
        final profile = GMProfile.youthFocused(
          id: 'gm3',
          name: 'Youth Coach',
        );

        expect(profile.personality, equals(GMPersonality.youthFocused));
        expect(profile.riskTolerance, equals(0.4));
        expect(profile.youthFocus, equals(0.9));
        expect(profile.tacticalFocus, equals(0.6));
        expect(profile.transferBudgetRatio, equals(0.3));
      });

      test('should create tactical GM with correct defaults', () {
        final profile = GMProfile.tactical(
          id: 'gm4',
          name: 'Tactical Genius',
        );

        expect(profile.personality, equals(GMPersonality.tactical));
        expect(profile.riskTolerance, equals(0.5));
        expect(profile.youthFocus, equals(0.4));
        expect(profile.tacticalFocus, equals(0.9));
        expect(profile.transferBudgetRatio, equals(0.5));
      });
    });

    group('Decision Weight Calculations', () {
      test('should calculate player preference weight correctly', () {
        final profile = GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.youthFocused,
          youthFocus: 0.8,
        );

        // Young player should get high weight
        final youngWeight = profile.getPlayerPreferenceWeight(
          age: 19,
          rating: 70,
          isYouthPlayer: true,
        );
        expect(youngWeight, greaterThan(0.7));

        // Older player should get lower weight
        final oldWeight = profile.getPlayerPreferenceWeight(
          age: 32,
          rating: 85,
          isYouthPlayer: false,
        );
        expect(oldWeight, lessThan(0.6));
      });

      test('should calculate transfer urgency weight correctly', () {
        final profile = GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.aggressive,
          riskTolerance: 0.8,
        );

        // High squad need should increase urgency
        final highUrgency = profile.getTransferUrgencyWeight(
          squadNeed: 0.9,
          timeRemaining: 0.2, // Little time left
        );
        expect(highUrgency, greaterThan(0.7));

        // Low squad need should decrease urgency
        final lowUrgency = profile.getTransferUrgencyWeight(
          squadNeed: 0.2,
          timeRemaining: 0.8, // Plenty of time
        );
        expect(lowUrgency, lessThan(0.4));
      });

      test('should calculate formation preference weight correctly', () {
        final profile = GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.tactical,
          tacticalFocus: 0.9,
        );

        // Should prefer formations that match tactical focus
        final preferenceWeight = profile.getFormationPreferenceWeight(
          formation: '4-3-3',
          availablePlayers: 18,
        );
        expect(preferenceWeight, greaterThan(0.0));
        expect(preferenceWeight, lessThanOrEqualTo(1.0));
      });
    });

    group('Budget Allocation', () {
      test('should allocate budget according to personality', () {
        final conservativeProfile = GMProfile.conservative(
          id: 'gm1',
          name: 'Conservative Manager',
        );

        final totalBudget = 50000000;
        final allocation = conservativeProfile.getBudgetAllocation(totalBudget);

        expect(allocation.transferBudget, equals(20000000)); // 40% of total
        expect(allocation.wageBudget, equals(25000000)); // 50% of total
        expect(allocation.youthBudget, equals(3750000)); // 7.5% of total
        expect(allocation.facilitiesBudget, equals(1250000)); // 2.5% of total
      });

      test('should allocate budget differently for aggressive personality', () {
        final aggressiveProfile = GMProfile.aggressive(
          id: 'gm2',
          name: 'Aggressive Manager',
        );

        final totalBudget = 50000000;
        final allocation = aggressiveProfile.getBudgetAllocation(totalBudget);

        expect(allocation.transferBudget, equals(40000000)); // 80% of total
        expect(allocation.wageBudget, equals(7500000)); // 15% of total
        expect(allocation.youthBudget, equals(1250000)); // 2.5% of total
        expect(allocation.facilitiesBudget, equals(1250000)); // 2.5% of total
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final profile = GMProfile(
          id: 'gm1',
          name: 'Test Manager',
          personality: GMPersonality.balanced,
          riskTolerance: 0.6,
        );

        final json = profile.toJson();

        expect(json['id'], equals('gm1'));
        expect(json['name'], equals('Test Manager'));
        expect(json['personality'], equals('balanced'));
        expect(json['riskTolerance'], equals(0.6));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'gm1',
          'name': 'Test Manager',
          'personality': 'aggressive',
          'riskTolerance': 0.8,
          'youthFocus': 0.3,
          'tacticalFocus': 0.7,
          'transferBudgetRatio': 0.6,
          'wageBudgetRatio': 0.4,
        };

        final profile = GMProfile.fromJson(json);

        expect(profile.id, equals('gm1'));
        expect(profile.name, equals('Test Manager'));
        expect(profile.personality, equals(GMPersonality.aggressive));
        expect(profile.riskTolerance, equals(0.8));
        expect(profile.youthFocus, equals(0.3));
        expect(profile.tacticalFocus, equals(0.7));
      });
    });

    group('Equality and Hash', () {
      test('should be equal when IDs match', () {
        final profile1 = GMProfile(
          id: 'gm1',
          name: 'Manager A',
          personality: GMPersonality.balanced,
        );

        final profile2 = GMProfile(
          id: 'gm1',
          name: 'Manager B', // Different name
          personality: GMPersonality.aggressive, // Different personality
        );

        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        final profile1 = GMProfile(
          id: 'gm1',
          name: 'Same Manager',
          personality: GMPersonality.balanced,
        );

        final profile2 = GMProfile(
          id: 'gm2',
          name: 'Same Manager',
          personality: GMPersonality.balanced,
        );

        expect(profile1, isNot(equals(profile2)));
      });
    });

    group('Copy With Functionality', () {
      test('should create copy with updated values', () {
        final original = GMProfile(
          id: 'gm1',
          name: 'Original Manager',
          personality: GMPersonality.balanced,
          riskTolerance: 0.5,
        );

        final updated = original.copyWith(
          name: 'Updated Manager',
          riskTolerance: 0.7,
        );

        expect(updated.id, equals('gm1')); // Same
        expect(updated.name, equals('Updated Manager')); // Changed
        expect(updated.personality, equals(GMPersonality.balanced)); // Same
        expect(updated.riskTolerance, equals(0.7)); // Changed
      });
    });
  });
}
