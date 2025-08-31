import 'package:test/test.dart';
import 'package:tactics_fc_engine/src/models/financial_account.dart';

void main() {
  group('FinancialAccount Tests', () {
    group('Account Construction', () {
      test('should create financial account with required fields', () {
        final account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
        );

        expect(account.teamId, equals('team1'));
        expect(account.balance, equals(50000000));
        expect(account.currency, equals('EUR'));
        expect(account.transactions, isEmpty);
        expect(account.budgetLimits, isEmpty);
      });

      test('should create account with optional parameters', () {
        final transactions = [
          Transaction(
            id: 'tx1',
            amount: 1000000,
            type: TransactionType.transfer,
            description: 'Player transfer',
            date: DateTime(2024, 1, 15),
          ),
        ];

        final budgetLimits = {
          BudgetCategory.transfers: 20000000,
          BudgetCategory.wages: 30000000,
        };

        final account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
          transactions: transactions,
          budgetLimits: budgetLimits,
        );

        expect(account.transactions, hasLength(1));
        expect(account.budgetLimits, hasLength(2));
        expect(account.budgetLimits[BudgetCategory.transfers], equals(20000000));
      });

      test('should throw error for empty team ID', () {
        expect(() => FinancialAccount(
          teamId: '',
          balance: 50000000,
          currency: 'EUR',
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for invalid currency', () {
        expect(() => FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'INVALID',
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Account Operations', () {
      late FinancialAccount account;

      setUp(() {
        account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
        );
      });

      test('should add funds correctly', () {
        final transaction = Transaction(
          id: 'tx1',
          amount: 5000000,
          type: TransactionType.revenue,
          description: 'TV rights',
          date: DateTime.now(),
        );

        final updatedAccount = account.addTransaction(transaction);

        expect(updatedAccount.balance, equals(55000000));
        expect(updatedAccount.transactions, hasLength(1));
        expect(updatedAccount.transactions.first.amount, equals(5000000));
      });

      test('should deduct funds correctly', () {
        final transaction = Transaction(
          id: 'tx1',
          amount: -3000000,
          type: TransactionType.transfer,
          description: 'Player purchase',
          date: DateTime.now(),
        );

        final updatedAccount = account.addTransaction(transaction);

        expect(updatedAccount.balance, equals(47000000));
        expect(updatedAccount.transactions, hasLength(1));
        expect(updatedAccount.transactions.first.amount, equals(-3000000));
      });

      test('should throw error for insufficient funds', () {
        final transaction = Transaction(
          id: 'tx1',
          amount: -60000000, // More than available balance
          type: TransactionType.transfer,
          description: 'Expensive player',
          date: DateTime.now(),
        );

        expect(() => account.addTransaction(transaction), 
               throwsA(isA<InsufficientFundsException>()));
      });

      test('should allow overdraft when enabled', () {
        final accountWithOverdraft = account.copyWith(
          allowOverdraft: true,
          overdraftLimit: 10000000,
        );

        final transaction = Transaction(
          id: 'tx1',
          amount: -55000000, // 5M over balance but within overdraft
          type: TransactionType.transfer,
          description: 'Player purchase',
          date: DateTime.now(),
        );

        final updatedAccount = accountWithOverdraft.addTransaction(transaction);

        expect(updatedAccount.balance, equals(-5000000));
      });

      test('should throw error when exceeding overdraft limit', () {
        final accountWithOverdraft = account.copyWith(
          allowOverdraft: true,
          overdraftLimit: 10000000,
        );

        final transaction = Transaction(
          id: 'tx1',
          amount: -65000000, // 15M over balance, exceeds 10M overdraft
          type: TransactionType.transfer,
          description: 'Very expensive player',
          date: DateTime.now(),
        );

        expect(() => accountWithOverdraft.addTransaction(transaction), 
               throwsA(isA<OverdraftLimitExceededException>()));
      });
    });

    group('Budget Management', () {
      late FinancialAccount account;

      setUp(() {
        account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
          budgetLimits: {
            BudgetCategory.transfers: 20000000,
            BudgetCategory.wages: 30000000,
            BudgetCategory.facilities: 5000000,
          },
        );
      });

      test('should set budget limit correctly', () {
        final updatedAccount = account.setBudgetLimit(
          BudgetCategory.transfers, 
          25000000,
        );

        expect(updatedAccount.budgetLimits[BudgetCategory.transfers], 
               equals(25000000));
      });

      test('should get available budget correctly', () {
        // Add some transfer transactions
        final transferTx = Transaction(
          id: 'tx1',
          amount: -10000000,
          type: TransactionType.transfer,
          description: 'Player purchase',
          date: DateTime.now(),
          category: BudgetCategory.transfers,
        );

        final accountWithTx = account.addTransaction(transferTx);
        final availableBudget = accountWithTx.getAvailableBudget(
          BudgetCategory.transfers,
        );

        expect(availableBudget, equals(10000000)); // 20M limit - 10M spent
      });

      test('should calculate total spending by category', () {
        final transactions = [
          Transaction(
            id: 'tx1',
            amount: -5000000,
            type: TransactionType.transfer,
            description: 'Player A',
            date: DateTime.now(),
            category: BudgetCategory.transfers,
          ),
          Transaction(
            id: 'tx2',
            amount: -3000000,
            type: TransactionType.transfer,
            description: 'Player B',
            date: DateTime.now(),
            category: BudgetCategory.transfers,
          ),
          Transaction(
            id: 'tx3',
            amount: -2000000,
            type: TransactionType.wages,
            description: 'Monthly wages',
            date: DateTime.now(),
            category: BudgetCategory.wages,
          ),
        ];

        var updatedAccount = account;
        for (final tx in transactions) {
          updatedAccount = updatedAccount.addTransaction(tx);
        }

        final transferSpending = updatedAccount.getTotalSpending(
          BudgetCategory.transfers,
        );
        final wageSpending = updatedAccount.getTotalSpending(
          BudgetCategory.wages,
        );

        expect(transferSpending, equals(8000000));
        expect(wageSpending, equals(2000000));
      });

      test('should throw error when exceeding budget limit', () {
        final transaction = Transaction(
          id: 'tx1',
          amount: -25000000, // Exceeds 20M transfer budget
          type: TransactionType.transfer,
          description: 'Expensive player',
          date: DateTime.now(),
          category: BudgetCategory.transfers,
        );

        expect(() => account.addTransaction(transaction), 
               throwsA(isA<BudgetExceededException>()));
      });
    });

    group('Transaction History', () {
      late FinancialAccount account;

      setUp(() {
        final transactions = [
          Transaction(
            id: 'tx1',
            amount: 5000000,
            type: TransactionType.revenue,
            description: 'TV rights',
            date: DateTime(2024, 1, 15),
          ),
          Transaction(
            id: 'tx2',
            amount: -3000000,
            type: TransactionType.transfer,
            description: 'Player purchase',
            date: DateTime(2024, 2, 1),
          ),
          Transaction(
            id: 'tx3',
            amount: -2000000,
            type: TransactionType.wages,
            description: 'Monthly wages',
            date: DateTime(2024, 2, 15),
          ),
        ];

        account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
          transactions: transactions,
        );
      });

      test('should filter transactions by type', () {
        final transferTxs = account.getTransactionsByType(
          TransactionType.transfer,
        );

        expect(transferTxs, hasLength(1));
        expect(transferTxs.first.description, equals('Player purchase'));
      });

      test('should filter transactions by date range', () {
        final februaryTxs = account.getTransactionsByDateRange(
          DateTime(2024, 2, 1),
          DateTime(2024, 2, 28),
        );

        expect(februaryTxs, hasLength(2));
      });

      test('should calculate total revenue', () {
        final totalRevenue = account.getTotalRevenue();
        expect(totalRevenue, equals(5000000));
      });

      test('should calculate total expenses', () {
        final totalExpenses = account.getTotalExpenses();
        expect(totalExpenses, equals(5000000)); // 3M + 2M
      });
    });

    group('Financial Fair Play', () {
      test('should check FFP compliance', () {
        final account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
        );

        // Add revenue and expenses for 3 years
        var updatedAccount = account;
        
        // Year 1: Break even
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx1',
          amount: 100000000,
          type: TransactionType.revenue,
          description: 'Year 1 revenue',
          date: DateTime(2022, 12, 31),
        ));
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx2',
          amount: -100000000,
          type: TransactionType.wages,
          description: 'Year 1 expenses',
          date: DateTime(2022, 12, 31),
        ));

        // Year 2: Small loss
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx3',
          amount: 95000000,
          type: TransactionType.revenue,
          description: 'Year 2 revenue',
          date: DateTime(2023, 12, 31),
        ));
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx4',
          amount: -100000000,
          type: TransactionType.wages,
          description: 'Year 2 expenses',
          date: DateTime(2023, 12, 31),
        ));

        // Year 3: Small profit
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx5',
          amount: 105000000,
          type: TransactionType.revenue,
          description: 'Year 3 revenue',
          date: DateTime(2024, 12, 31),
        ));
        updatedAccount = updatedAccount.addTransaction(Transaction(
          id: 'tx6',
          amount: -100000000,
          type: TransactionType.wages,
          description: 'Year 3 expenses',
          date: DateTime(2024, 12, 31),
        ));

        final ffpStatus = updatedAccount.checkFFPCompliance(
          DateTime(2022, 1, 1),
          DateTime(2024, 12, 31),
        );

        expect(ffpStatus.isCompliant, isTrue);
        expect(ffpStatus.totalLoss, equals(5000000)); // 5M total loss over 3 years
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final account = FinancialAccount(
          teamId: 'team1',
          balance: 50000000,
          currency: 'EUR',
          budgetLimits: {
            BudgetCategory.transfers: 20000000,
          },
        );

        final json = account.toJson();

        expect(json['teamId'], equals('team1'));
        expect(json['balance'], equals(50000000));
        expect(json['currency'], equals('EUR'));
        expect(json['budgetLimits'], isA<Map>());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'teamId': 'team1',
          'balance': 50000000,
          'currency': 'EUR',
          'transactions': [],
          'budgetLimits': {
            'transfers': 20000000,
          },
          'allowOverdraft': false,
          'overdraftLimit': 0,
        };

        final account = FinancialAccount.fromJson(json);

        expect(account.teamId, equals('team1'));
        expect(account.balance, equals(50000000));
        expect(account.currency, equals('EUR'));
        expect(account.budgetLimits[BudgetCategory.transfers], equals(20000000));
      });
    });
  });

  group('Transaction Tests', () {
    test('should create transaction with required fields', () {
      final transaction = Transaction(
        id: 'tx1',
        amount: 1000000,
        type: TransactionType.transfer,
        description: 'Player transfer',
        date: DateTime(2024, 1, 15),
      );

      expect(transaction.id, equals('tx1'));
      expect(transaction.amount, equals(1000000));
      expect(transaction.type, equals(TransactionType.transfer));
      expect(transaction.description, equals('Player transfer'));
      expect(transaction.date, equals(DateTime(2024, 1, 15)));
    });

    test('should throw error for empty transaction ID', () {
      expect(() => Transaction(
        id: '',
        amount: 1000000,
        type: TransactionType.transfer,
        description: 'Player transfer',
        date: DateTime.now(),
      ), throwsA(isA<ArgumentError>()));
    });

    test('should throw error for empty description', () {
      expect(() => Transaction(
        id: 'tx1',
        amount: 1000000,
        type: TransactionType.transfer,
        description: '',
        date: DateTime.now(),
      ), throwsA(isA<ArgumentError>()));
    });
  });
}
