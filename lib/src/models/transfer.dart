import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer.g.dart';

/// Types of transfers
@JsonEnum()
enum TransferType {
  permanent,
  loan,
  freeTransfer;
}

/// Transfer status
@JsonEnum()
enum TransferStatus {
  agreed,
  completed,
  cancelled,
  rejected;
}

/// Types of add-on clauses
@JsonEnum()
enum AddOnClause {
  appearances,
  goals,
  assists,
  internationalCaps,
  trophies,
  promotion,
  relegation;
}

/// Represents a transfer between teams
@JsonSerializable()
class Transfer extends Equatable {
  /// Unique identifier for the transfer
  final String id;

  /// ID of the player being transferred
  final String playerId;

  /// ID of the selling team
  final String sellingTeamId;

  /// ID of the buying team
  final String buyingTeamId;

  /// Transfer fee amount
  final int transferFee;

  /// Date when transfer was agreed
  final DateTime agreedDate;

  /// Type of transfer
  final TransferType transferType;

  /// Current status of the transfer
  final TransferStatus status;

  /// Duration of loan in days (only for loan transfers)
  final int loanDuration;

  /// Loan fee amount (only for loan transfers)
  final int loanFee;

  /// Percentage of wages covered by buying team (0-100)
  final int wageContribution;

  /// Buy-back clause amount (0 means no clause)
  final int buyBackClause;

  /// Sell-on clause percentage (0-100)
  final int sellOnClause;

  /// Add-on clauses and their values
  final Map<AddOnClause, int> addOnClauses;

  /// Date when transfer was completed (null if not completed)
  final DateTime? completionDate;

  /// Creates a new transfer instance
  Transfer({
    required this.id,
    required this.playerId,
    required this.sellingTeamId,
    required this.buyingTeamId,
    required this.transferFee,
    required this.agreedDate,
    TransferType? transferType,
    TransferStatus? status,
    int? loanDuration,
    int? loanFee,
    int? wageContribution,
    int? buyBackClause,
    int? sellOnClause,
    Map<AddOnClause, int>? addOnClauses,
    this.completionDate,
  })  : transferType = transferType ?? TransferType.permanent,
        status = status ?? TransferStatus.agreed,
        loanDuration = loanDuration ?? 0,
        loanFee = loanFee ?? 0,
        wageContribution = wageContribution ?? 0,
        buyBackClause = buyBackClause ?? 0,
        sellOnClause = sellOnClause ?? 0,
        addOnClauses = addOnClauses ?? {} {
    // Validation
    if (id.trim().isEmpty) {
      throw ArgumentError('Transfer ID cannot be empty');
    }
    if (playerId.trim().isEmpty) {
      throw ArgumentError('Player ID cannot be empty');
    }
    if (sellingTeamId.trim().isEmpty) {
      throw ArgumentError('Selling team ID cannot be empty');
    }
    if (buyingTeamId.trim().isEmpty) {
      throw ArgumentError('Buying team ID cannot be empty');
    }
    if (sellingTeamId == buyingTeamId) {
      throw ArgumentError('Selling and buying team cannot be the same');
    }
    if (transferFee < 0) {
      throw ArgumentError('Transfer fee cannot be negative');
    }
    
    final wageContrib = wageContribution ?? 0;
    final sellOn = sellOnClause ?? 0;
    
    if (wageContrib < 0 || wageContrib > 100) {
      throw ArgumentError('Wage contribution must be between 0 and 100');
    }
    if (sellOn < 0 || sellOn > 100) {
      throw ArgumentError('Sell-on clause must be between 0 and 100');
    }
  }

  /// Creates a transfer from JSON data
  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);

  /// Converts the transfer to JSON data
  Map<String, dynamic> toJson() => _$TransferToJson(this);

  /// Checks if this is a loan transfer
  bool get isLoan => transferType == TransferType.loan;

  /// Calculates total potential cost including add-ons
  int get totalPotentialCost {
    final addOnTotal = addOnClauses.values.fold(0, (sum, value) => sum + value);
    if (isLoan) {
      return loanFee + addOnTotal;
    }
    return transferFee + addOnTotal;
  }

  /// Checks if loan is expired (only for loan transfers)
  bool get isLoanExpired {
    if (!isLoan || completionDate == null) return false;
    final loanEndDate = completionDate!.add(Duration(days: loanDuration));
    return DateTime.now().isAfter(loanEndDate);
  }

  /// Calculates days remaining for loan
  int get loanDaysRemaining {
    if (!isLoan || completionDate == null) return 0;
    final loanEndDate = completionDate!.add(Duration(days: loanDuration));
    if (DateTime.now().isAfter(loanEndDate)) return 0;
    return loanEndDate.difference(DateTime.now()).inDays;
  }

  /// Completes the transfer
  Transfer complete(DateTime completionDate) {
    if (status == TransferStatus.completed) {
      throw ArgumentError('Transfer is already completed');
    }

    return Transfer(
      id: id,
      playerId: playerId,
      sellingTeamId: sellingTeamId,
      buyingTeamId: buyingTeamId,
      transferFee: transferFee,
      agreedDate: agreedDate,
      transferType: transferType,
      status: TransferStatus.completed,
      loanDuration: loanDuration,
      loanFee: loanFee,
      wageContribution: wageContribution,
      buyBackClause: buyBackClause,
      sellOnClause: sellOnClause,
      addOnClauses: addOnClauses,
      completionDate: completionDate,
    );
  }

  /// Cancels the transfer
  Transfer cancel() {
    return Transfer(
      id: id,
      playerId: playerId,
      sellingTeamId: sellingTeamId,
      buyingTeamId: buyingTeamId,
      transferFee: transferFee,
      agreedDate: agreedDate,
      transferType: transferType,
      status: TransferStatus.cancelled,
      loanDuration: loanDuration,
      loanFee: loanFee,
      wageContribution: wageContribution,
      buyBackClause: buyBackClause,
      sellOnClause: sellOnClause,
      addOnClauses: addOnClauses,
      completionDate: completionDate,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transfer(id: $id, playerId: $playerId, '
        'from: $sellingTeamId, to: $buyingTeamId, '
        'fee: $transferFee, type: ${transferType.name}, status: ${status.name})';
  }
}
