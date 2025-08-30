import 'package:test/test.dart';
import 'package:soccer_engine/src/models/contract.dart';
import 'package:soccer_utilities/src/models/player.dart';

void main() {
  group('Contract Tests', () {
    late Player testPlayer;
    
    setUp(() {
      testPlayer = Player(
        id: 'player1',
        name: 'Test Player',
        age: 25,
        position: PlayerPosition.midfielder,
        technical: 75,
        physical: 70,
        mental: 80,
      );
    });

    group('Contract Construction', () {
      test('should create contract with required fields', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        expect(contract.id, equals('contract1'));
        expect(contract.playerId, equals('player1'));
        expect(contract.teamId, equals('team1'));
        expect(contract.startDate, equals(DateTime(2024, 1, 1)));
        expect(contract.endDate, equals(DateTime(2026, 1, 1)));
        expect(contract.weeklySalary, equals(50000));
        expect(contract.contractType, equals(ContractType.playing));
        expect(contract.isActive, isTrue);
      });

      test('should create contract with optional fields', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
          contractType: ContractType.youth,
          signingBonus: 100000,
          releaseClause: 5000000,
          loyaltyBonus: 200000,
          performanceBonuses: {
            PerformanceBonus.goalBonus: 10000,
            PerformanceBonus.assistBonus: 5000,
          },
          isActive: false,
        );

        expect(contract.contractType, equals(ContractType.youth));
        expect(contract.signingBonus, equals(100000));
        expect(contract.releaseClause, equals(5000000));
        expect(contract.loyaltyBonus, equals(200000));
        expect(contract.performanceBonuses[PerformanceBonus.goalBonus], equals(10000));
        expect(contract.performanceBonuses[PerformanceBonus.assistBonus], equals(5000));
        expect(contract.isActive, isFalse);
      });

      test('should throw error for empty contract ID', () {
        expect(
          () => Contract(
            id: '',
            playerId: testPlayer.id,
            teamId: 'team1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: 50000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for empty player ID', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: '',
            teamId: 'team1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: 50000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for empty team ID', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: testPlayer.id,
            teamId: '',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: 50000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error when end date is before start date', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: testPlayer.id,
            teamId: 'team1',
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2024, 1, 1),
            weeklySalary: 50000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for negative weekly salary', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: testPlayer.id,
            teamId: 'team1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: -1000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for negative signing bonus', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: testPlayer.id,
            teamId: 'team1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: 50000,
            signingBonus: -10000,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for negative release clause', () {
        expect(
          () => Contract(
            id: 'contract1',
            playerId: testPlayer.id,
            teamId: 'team1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2026, 1, 1),
            weeklySalary: 50000,
            releaseClause: -1000000,
          ),
          throwsArgumentError,
        );
      });
    });

    group('Contract Calculations', () {
      test('should calculate duration in years correctly', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        expect(contract.durationInYears, equals(2));
      });

      test('should calculate duration for partial years', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 7, 1),
          weeklySalary: 50000,
        );

        expect(contract.durationInYears, equals(0));
      });

      test('should calculate annual salary correctly', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        expect(contract.annualSalary, equals(2600000)); // 50000 * 52
      });

      test('should calculate total contract value correctly', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
          signingBonus: 100000,
          loyaltyBonus: 200000,
        );

        // 2 years * 2,600,000 + 100,000 + 200,000 = 5,500,000
        expect(contract.totalValue, equals(5500000));
      });

      test('should check if contract is expired', () {
        final activeContract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now().add(const Duration(days: 365)),
          weeklySalary: 50000,
        );

        final expiredContract = Contract(
          id: 'contract2',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime.now().subtract(const Duration(days: 730)),
          endDate: DateTime.now().subtract(const Duration(days: 365)),
          weeklySalary: 50000,
        );

        expect(activeContract.isExpired, isFalse);
        expect(expiredContract.isExpired, isTrue);
      });

      test('should calculate days remaining correctly', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now().add(const Duration(days: 100)),
          weeklySalary: 50000,
        );

        expect(contract.daysRemaining, equals(100));
      });

      test('should return 0 days remaining for expired contract', () {
        final expiredContract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime.now().subtract(const Duration(days: 730)),
          endDate: DateTime.now().subtract(const Duration(days: 365)),
          weeklySalary: 50000,
        );

        expect(expiredContract.daysRemaining, equals(0));
      });
    });

    group('Contract Modifications', () {
      test('should extend contract correctly', () {
        final originalContract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        final extendedContract = originalContract.extendContract(
          newEndDate: DateTime(2028, 1, 1),
          newWeeklySalary: 60000,
        );

        expect(extendedContract.endDate, equals(DateTime(2028, 1, 1)));
        expect(extendedContract.weeklySalary, equals(60000));
        expect(extendedContract.id, equals('contract1'));
        expect(extendedContract.playerId, equals(testPlayer.id));
      });

      test('should throw error when extending with earlier end date', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        expect(
          () => contract.extendContract(
            newEndDate: DateTime(2025, 1, 1),
            newWeeklySalary: 60000,
          ),
          throwsArgumentError,
        );
      });

      test('should terminate contract correctly', () {
        final activeContract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
          isActive: true,
        );

        final terminatedContract = activeContract.terminate();

        expect(terminatedContract.isActive, isFalse);
        expect(terminatedContract.id, equals('contract1'));
        expect(terminatedContract.playerId, equals(testPlayer.id));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
          signingBonus: 100000,
          releaseClause: 5000000,
        );

        final json = contract.toJson();

        expect(json['id'], equals('contract1'));
        expect(json['playerId'], equals('player1'));
        expect(json['teamId'], equals('team1'));
        expect(json['weeklySalary'], equals(50000));
        expect(json['signingBonus'], equals(100000));
        expect(json['releaseClause'], equals(5000000));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'contract1',
          'playerId': 'player1',
          'teamId': 'team1',
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2026-01-01T00:00:00.000',
          'weeklySalary': 50000,
          'contractType': 'playing',
          'signingBonus': 100000,
          'releaseClause': 5000000,
          'loyaltyBonus': 0,
          'performanceBonuses': <String, dynamic>{},
          'isActive': true,
        };

        final contract = Contract.fromJson(json);

        expect(contract.id, equals('contract1'));
        expect(contract.playerId, equals('player1'));
        expect(contract.teamId, equals('team1'));
        expect(contract.startDate, equals(DateTime(2024, 1, 1)));
        expect(contract.endDate, equals(DateTime(2026, 1, 1)));
        expect(contract.weeklySalary, equals(50000));
        expect(contract.signingBonus, equals(100000));
        expect(contract.releaseClause, equals(5000000));
      });
    });

    group('Equality and Hash', () {
      test('should be equal when IDs match', () {
        final contract1 = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        final contract2 = Contract(
          id: 'contract1',
          playerId: 'different_player',
          teamId: 'different_team',
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2027, 1, 1),
          weeklySalary: 75000,
        );

        expect(contract1, equals(contract2));
        expect(contract1.hashCode, equals(contract2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        final contract1 = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        final contract2 = Contract(
          id: 'contract2',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        expect(contract1, isNot(equals(contract2)));
      });
    });

    group('String Representation', () {
      test('should return meaningful string representation', () {
        final contract = Contract(
          id: 'contract1',
          playerId: testPlayer.id,
          teamId: 'team1',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2026, 1, 1),
          weeklySalary: 50000,
        );

        final stringRep = contract.toString();
        expect(stringRep, contains('contract1'));
        expect(stringRep, contains('player1'));
        expect(stringRep, contains('50000'));
        expect(stringRep, contains('2024-01-01'));
        expect(stringRep, contains('2026-01-01'));
      });
    });
  });
}
