import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'financial_account.g.dart';

/// Types of financial transactions
enum TransactionType {
  @JsonValue('transfer')
  transfer,
  @JsonValue('wages')
  wages,
  @JsonValue('revenue')
  revenue,
  @JsonValue('facilities')
  facilities,
  @JsonValue('other')
  other,
}

/// Budget categories for financial planning
enum BudgetCategory {
  @JsonValue('transfers')
  transfers,
  @JsonValue('wages')
  wages,
  @JsonValue('facilities')
  facilities,
  @JsonValue('youth')
  youth,
  @JsonValue('marketing')
  marketing,
  @JsonValue('other')
  other,
}

/// Exception thrown when insufficient funds are available
class InsufficientFundsException implements Exception {
  final String message;
  const InsufficientFundsException(this.message);
  
  @override
  String toString() => 'InsufficientFundsException: $message';
}

/// Exception thrown when overdraft limit is exceeded
class OverdraftLimitExceededException implements Exception {
  final String message;
  const OverdraftLimitExceededException(this.message);
  
  @override
  String toString() => 'OverdraftLimitExceededException: $message';
}

/// Exception thrown when budget limit is exceeded
class BudgetExceededException implements Exception {
  final String message;
  const BudgetExceededException(this.message);
  
  @override
  String toString() => 'BudgetExceededException: $message';
}

/// Financial Fair Play compliance status
@JsonSerializable()
class FFPStatus extends Equatable {
  /// Whether the team is FFP compliant
  final bool isCompliant;
  
  /// Total loss over the monitoring period
  final int totalLoss;
  
  /// Maximum allowed loss
  final int maxAllowedLoss;
  
  /// Monitoring period start date
  final DateTime periodStart;
  
  /// Monitoring period end date
  final DateTime periodEnd;
  
  const FFPStatus({
    required this.isCompliant,
    required this.totalLoss,
    required this.maxAllowedLoss,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  List<Object> get props => [
    isCompliant,
    totalLoss,
    maxAllowedLoss,
    periodStart,
    periodEnd,
  ];

  /// Creates a copy with updated values
  FFPStatus copyWith({
    bool? isCompliant,
    int? totalLoss,
    int? maxAllowedLoss,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return FFPStatus(
      isCompliant: isCompliant ?? this.isCompliant,
      totalLoss: totalLoss ?? this.totalLoss,
      maxAllowedLoss: maxAllowedLoss ?? this.maxAllowedLoss,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$FFPStatusToJson(this);

  /// Create from JSON
  factory FFPStatus.fromJson(Map<String, dynamic> json) =>
      _$FFPStatusFromJson(json);
}

/// Represents a financial transaction
@JsonSerializable()
class Transaction extends Equatable {
  /// Unique transaction identifier
  final String id;
  
  /// Transaction amount (positive for income, negative for expenses)
  final int amount;
  
  /// Type of transaction
  final TransactionType type;
  
  /// Transaction description
  final String description;
  
  /// Transaction date
  final DateTime date;
  
  /// Budget category (optional)
  final BudgetCategory? category;
  
  /// Related entity ID (e.g., player ID for transfers)
  final String? relatedEntityId;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// Factory constructor with validation
  factory Transaction({
    required String id,
    required int amount,
    required TransactionType type,
    required String description,
    required DateTime date,
    BudgetCategory? category,
    String? relatedEntityId,
    Map<String, dynamic> metadata = const {},
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }
    if (description.isEmpty) {
      throw ArgumentError('Transaction description cannot be empty');
    }

    return Transaction._internal(
      id: id,
      amount: amount,
      type: type,
      description: description,
      date: date,
      category: category,
      relatedEntityId: relatedEntityId,
      metadata: metadata,
    );
  }

  /// Private constructor for validation
  const Transaction._internal({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.category,
    this.relatedEntityId,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    type,
    description,
    date,
    category,
    relatedEntityId,
    metadata,
  ];

  /// Creates a copy with updated values
  Transaction copyWith({
    String? id,
    int? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
    BudgetCategory? category,
    String? relatedEntityId,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

/// Represents a team's financial account
@JsonSerializable()
class FinancialAccount extends Equatable {
  /// Team identifier
  final String teamId;
  
  /// Current account balance
  final int balance;
  
  /// Currency code (ISO 4217)
  final String currency;
  
  /// List of all transactions
  final List<Transaction> transactions;
  
  /// Budget limits by category
  final Map<BudgetCategory, int> budgetLimits;
  
  /// Whether overdraft is allowed
  final bool allowOverdraft;
  
  /// Maximum overdraft limit
  final int overdraftLimit;

  /// Valid currency codes
  static const List<String> _validCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'SEK', 'NOK', 'DKK',
    'PLN', 'CZK', 'HUF', 'RUB', 'BRL', 'MXN', 'ARS', 'CLP', 'CNY', 'INR',
  ];

  /// Factory constructor with validation
  factory FinancialAccount({
    required String teamId,
    required int balance,
    required String currency,
    List<Transaction> transactions = const [],
    Map<BudgetCategory, int> budgetLimits = const {},
    bool allowOverdraft = false,
    int overdraftLimit = 0,
  }) {
    if (teamId.isEmpty) {
      throw ArgumentError('Team ID cannot be empty');
    }
    if (!_validCurrencies.contains(currency)) {
      throw ArgumentError('Invalid currency code: $currency');
    }

    return FinancialAccount._internal(
      teamId: teamId,
      balance: balance,
      currency: currency,
      transactions: transactions,
      budgetLimits: budgetLimits,
      allowOverdraft: allowOverdraft,
      overdraftLimit: overdraftLimit,
    );
  }

  /// Private constructor for validation
  const FinancialAccount._internal({
    required this.teamId,
    required this.balance,
    required this.currency,
    this.transactions = const [],
    this.budgetLimits = const {},
    this.allowOverdraft = false,
    this.overdraftLimit = 0,
  });

  @override
  List<Object> get props => [
    teamId,
    balance,
    currency,
    transactions,
    budgetLimits,
    allowOverdraft,
    overdraftLimit,
  ];

  /// Adds a transaction to the account
  FinancialAccount addTransaction(Transaction transaction) {
    final newBalance = balance + transaction.amount;
    
    // Check for insufficient funds
    if (newBalance < 0 && !allowOverdraft) {
      throw InsufficientFundsException(
        'Insufficient funds. Current balance: $balance, Transaction: ${transaction.amount}'
      );
    }
    
    // Check overdraft limit
    if (allowOverdraft && newBalance < -overdraftLimit) {
      throw OverdraftLimitExceededException(
        'Transaction would exceed overdraft limit of $overdraftLimit'
      );
    }
    
    // Check budget limits if category is specified and transaction is negative
    if (transaction.category != null && transaction.amount < 0) {
      final category = transaction.category!;
      final budgetLimit = budgetLimits[category];
      if (budgetLimit != null) {
        final currentSpending = getTotalSpending(category);
        final newSpending = currentSpending + transaction.amount.abs();
        if (newSpending > budgetLimit) {
          throw BudgetExceededException(
            'Transaction would exceed budget limit for ${category.name}. '
            'Limit: $budgetLimit, Current spending: $currentSpending, '
            'New transaction: ${transaction.amount.abs()}'
          );
        }
      }
    }
    
    return copyWith(
      balance: newBalance,
      transactions: [...transactions, transaction],
    );
  }

  /// Sets a budget limit for a category
  FinancialAccount setBudgetLimit(BudgetCategory category, int limit) {
    final newLimits = Map<BudgetCategory, int>.from(budgetLimits);
    newLimits[category] = limit;
    return copyWith(budgetLimits: newLimits);
  }

  /// Gets available budget for a category
  int getAvailableBudget(BudgetCategory category) {
    final limit = budgetLimits[category] ?? 0;
    final spent = getTotalSpending(category);
    return limit - spent;
  }

  /// Gets total spending for a category
  int getTotalSpending(BudgetCategory category) {
    return transactions
        .where((tx) => tx.category == category && tx.amount < 0)
        .fold(0, (sum, tx) => sum + tx.amount.abs());
  }

  /// Filters transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return transactions.where((tx) => tx.type == type).toList();
  }

  /// Filters transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return transactions
        .where((tx) => 
            tx.date.isAfter(start.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Calculates total revenue
  int getTotalRevenue() {
    return transactions
        .where((tx) => tx.amount > 0)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  /// Calculates total expenses
  int getTotalExpenses() {
    return transactions
        .where((tx) => tx.amount < 0)
        .fold(0, (sum, tx) => sum + tx.amount.abs());
  }

  /// Checks Financial Fair Play compliance
  FFPStatus checkFFPCompliance(DateTime periodStart, DateTime periodEnd) {
    final periodTransactions = getTransactionsByDateRange(periodStart, periodEnd);
    
    // Group transactions by year to calculate annual losses
    final transactionsByYear = <int, List<Transaction>>{};
    for (final tx in periodTransactions) {
      final year = tx.date.year;
      transactionsByYear.putIfAbsent(year, () => []).add(tx);
    }
    
    // Calculate cumulative losses (only count loss years, not profits)
    int totalLoss = 0;
    for (final yearTransactions in transactionsByYear.values) {
      final yearRevenue = yearTransactions
          .where((tx) => tx.amount > 0)
          .fold(0, (sum, tx) => sum + tx.amount);
      
      final yearExpenses = yearTransactions
          .where((tx) => tx.amount < 0)
          .fold(0, (sum, tx) => sum + tx.amount.abs());
      
      final yearLoss = yearExpenses - yearRevenue;
      
      // Only add to total loss if the year had a net loss
      if (yearLoss > 0) {
        totalLoss += yearLoss;
      }
    }
    
    const maxAllowedLoss = 30000000; // €30M over 3 years (typical FFP rule)
    
    return FFPStatus(
      isCompliant: totalLoss <= maxAllowedLoss,
      totalLoss: totalLoss,
      maxAllowedLoss: maxAllowedLoss,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  /// Creates a copy with updated values
  FinancialAccount copyWith({
    String? teamId,
    int? balance,
    String? currency,
    List<Transaction>? transactions,
    Map<BudgetCategory, int>? budgetLimits,
    bool? allowOverdraft,
    int? overdraftLimit,
  }) {
    return FinancialAccount(
      teamId: teamId ?? this.teamId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      allowOverdraft: allowOverdraft ?? this.allowOverdraft,
      overdraftLimit: overdraftLimit ?? this.overdraftLimit,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$FinancialAccountToJson(this);

  /// Create from JSON
  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountFromJson(json);
}
