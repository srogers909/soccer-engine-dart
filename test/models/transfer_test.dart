import 'package:test/test.dart';
import 'package:tactics_fc_engine/src/models/transfer.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';
import 'package:tactics_fc_engine/src/models/team.dart';

void main() {
  group('Transfer Tests', () {
    late Player testPlayer;
    late Team sellingTeam;
    late Team buyingTeam;
    
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

      sellingTeam = Team(
        id: 'team1',
        name: 'Selling FC',
        city: 'Selling City',
        foundedYear: 1900,
        players: [testPlayer],
      );

      buyingTeam = Team(
        id: 'team2',
        name: 'Buying FC',
        city: 'Buying City',
        foundedYear: 1910,
      );
    });

    group('Transfer Construction', () {
      test('should create transfer with required fields', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
        );

        expect(transfer.id, equals('transfer1'));
        expect(transfer.playerId, equals('player1'));
        expect(transfer.sellingTeamId, equals('team1'));
        expect(transfer.buyingTeamId, equals('team2'));
        expect(transfer.transferFee, equals(5000000));
        expect(transfer.agreedDate, equals(DateTime(2024, 1, 15)));
        expect(transfer.transferType, equals(TransferType.permanent));
        expect(transfer.status, equals(TransferStatus.agreed));
        expect(transfer.isLoan, isFalse);
      });

      test('should create loan transfer with optional fields', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 0,
          agreedDate: DateTime(2024, 1, 15),
          transferType: TransferType.loan,
          loanDuration: 365,
          loanFee: 500000,
          wageContribution: 75,
          buyBackClause: 8000000,
          sellOnClause: 20,
          addOnClauses: {
            AddOnClause.appearances: 1000000,
            AddOnClause.goals: 500000,
          },
          completionDate: DateTime(2024, 1, 20),
          status: TransferStatus.completed,
        );

        expect(transfer.transferType, equals(TransferType.loan));
        expect(transfer.loanDuration, equals(365));
        expect(transfer.loanFee, equals(500000));
        expect(transfer.wageContribution, equals(75));
        expect(transfer.buyBackClause, equals(8000000));
        expect(transfer.sellOnClause, equals(20));
        expect(transfer.addOnClauses[AddOnClause.appearances], equals(1000000));
        expect(transfer.addOnClauses[AddOnClause.goals], equals(500000));
        expect(transfer.completionDate, equals(DateTime(2024, 1, 20)));
        expect(transfer.status, equals(TransferStatus.completed));
        expect(transfer.isLoan, isTrue);
      });

      test('should throw error for empty transfer ID', () {
        expect(
          () => Transfer(
            id: '',
            playerId: testPlayer.id,
            sellingTeamId: sellingTeam.id,
            buyingTeamId: buyingTeam.id,
            transferFee: 5000000,
            agreedDate: DateTime(2024, 1, 15),
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for empty player ID', () {
        expect(
          () => Transfer(
            id: 'transfer1',
            playerId: '',
            sellingTeamId: sellingTeam.id,
            buyingTeamId: buyingTeam.id,
            transferFee: 5000000,
            agreedDate: DateTime(2024, 1, 15),
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for same selling and buying team', () {
        expect(
          () => Transfer(
            id: 'transfer1',
            playerId: testPlayer.id,
            sellingTeamId: sellingTeam.id,
            buyingTeamId: sellingTeam.id,
            transferFee: 5000000,
            agreedDate: DateTime(2024, 1, 15),
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for negative transfer fee', () {
        expect(
          () => Transfer(
            id: 'transfer1',
            playerId: testPlayer.id,
            sellingTeamId: sellingTeam.id,
            buyingTeamId: buyingTeam.id,
            transferFee: -1000000,
            agreedDate: DateTime(2024, 1, 15),
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for invalid wage contribution', () {
        expect(
          () => Transfer(
            id: 'transfer1',
            playerId: testPlayer.id,
            sellingTeamId: sellingTeam.id,
            buyingTeamId: buyingTeam.id,
            transferFee: 0,
            agreedDate: DateTime(2024, 1, 15),
            wageContribution: 150,
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for invalid sell-on clause', () {
        expect(
          () => Transfer(
            id: 'transfer1',
            playerId: testPlayer.id,
            sellingTeamId: sellingTeam.id,
            buyingTeamId: buyingTeam.id,
            transferFee: 5000000,
            agreedDate: DateTime(2024, 1, 15),
            sellOnClause: 150,
          ),
          throwsArgumentError,
        );
      });
    });

    group('Transfer Calculations', () {
      test('should calculate total cost for permanent transfer', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
          addOnClauses: {
            AddOnClause.appearances: 1000000,
            AddOnClause.goals: 500000,
          },
        );

        // Base fee + potential add-ons
        expect(transfer.totalPotentialCost, equals(6500000));
      });

      test('should calculate total cost for loan transfer', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 0,
          agreedDate: DateTime(2024, 1, 15),
          transferType: TransferType.loan,
          loanFee: 500000,
          wageContribution: 75,
        );

        expect(transfer.totalPotentialCost, equals(500000));
        expect(transfer.isLoan, isTrue);
      });

      test('should check if transfer is expired for loans', () {
        final activeTransfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 0,
          agreedDate: DateTime.now().subtract(const Duration(days: 100)),
          transferType: TransferType.loan,
          loanDuration: 365,
          completionDate: DateTime.now().subtract(const Duration(days: 100)),
        );

        final expiredTransfer = Transfer(
          id: 'transfer2',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 0,
          agreedDate: DateTime.now().subtract(const Duration(days: 400)),
          transferType: TransferType.loan,
          loanDuration: 365,
          completionDate: DateTime.now().subtract(const Duration(days: 400)),
        );

        expect(activeTransfer.isLoanExpired, isFalse);
        expect(expiredTransfer.isLoanExpired, isTrue);
      });

      test('should calculate days remaining for loan', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 0,
          agreedDate: DateTime.now().subtract(const Duration(days: 100)),
          transferType: TransferType.loan,
          loanDuration: 365,
          completionDate: DateTime.now().subtract(const Duration(days: 100)),
        );

        expect(transfer.loanDaysRemaining, equals(265));
      });
    });

    group('Transfer Status Updates', () {
      test('should complete transfer correctly', () {
        final agreedTransfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
          status: TransferStatus.agreed,
        );

        final completedTransfer = agreedTransfer.complete(DateTime(2024, 1, 20));

        expect(completedTransfer.status, equals(TransferStatus.completed));
        expect(completedTransfer.completionDate, equals(DateTime(2024, 1, 20)));
        expect(completedTransfer.id, equals('transfer1'));
      });

      test('should cancel transfer correctly', () {
        final agreedTransfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
          status: TransferStatus.agreed,
        );

        final cancelledTransfer = agreedTransfer.cancel();

        expect(cancelledTransfer.status, equals(TransferStatus.cancelled));
        expect(cancelledTransfer.id, equals('transfer1'));
      });

      test('should throw error when trying to complete already completed transfer', () {
        final completedTransfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
          status: TransferStatus.completed,
          completionDate: DateTime(2024, 1, 20),
        );

        expect(
          () => completedTransfer.complete(DateTime(2024, 1, 25)),
          throwsArgumentError,
        );
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
          addOnClauses: {
            AddOnClause.appearances: 1000000,
          },
        );

        final json = transfer.toJson();

        expect(json['id'], equals('transfer1'));
        expect(json['playerId'], equals('player1'));
        expect(json['sellingTeamId'], equals('team1'));
        expect(json['buyingTeamId'], equals('team2'));
        expect(json['transferFee'], equals(5000000));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'transfer1',
          'playerId': 'player1',
          'sellingTeamId': 'team1',
          'buyingTeamId': 'team2',
          'transferFee': 5000000,
          'agreedDate': '2024-01-15T00:00:00.000',
          'transferType': 'permanent',
          'status': 'agreed',
          'loanDuration': 0,
          'loanFee': 0,
          'wageContribution': 0,
          'buyBackClause': 0,
          'sellOnClause': 0,
          'addOnClauses': <String, dynamic>{},
          'completionDate': null,
        };

        final transfer = Transfer.fromJson(json);

        expect(transfer.id, equals('transfer1'));
        expect(transfer.playerId, equals('player1'));
        expect(transfer.sellingTeamId, equals('team1'));
        expect(transfer.buyingTeamId, equals('team2'));
        expect(transfer.transferFee, equals(5000000));
        expect(transfer.agreedDate, equals(DateTime(2024, 1, 15)));
      });
    });

    group('Equality and Hash', () {
      test('should be equal when IDs match', () {
        final transfer1 = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
        );

        final transfer2 = Transfer(
          id: 'transfer1',
          playerId: 'different_player',
          sellingTeamId: 'different_team1',
          buyingTeamId: 'different_team2',
          transferFee: 10000000,
          agreedDate: DateTime(2024, 2, 15),
        );

        expect(transfer1, equals(transfer2));
        expect(transfer1.hashCode, equals(transfer2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        final transfer1 = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
        );

        final transfer2 = Transfer(
          id: 'transfer2',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
        );

        expect(transfer1, isNot(equals(transfer2)));
      });
    });

    group('String Representation', () {
      test('should return meaningful string representation', () {
        final transfer = Transfer(
          id: 'transfer1',
          playerId: testPlayer.id,
          sellingTeamId: sellingTeam.id,
          buyingTeamId: buyingTeam.id,
          transferFee: 5000000,
          agreedDate: DateTime(2024, 1, 15),
        );

        final stringRep = transfer.toString();
        expect(stringRep, contains('transfer1'));
        expect(stringRep, contains('player1'));
        expect(stringRep, contains('5000000'));
        expect(stringRep, contains('team1'));
        expect(stringRep, contains('team2'));
      });
    });
  });
}
