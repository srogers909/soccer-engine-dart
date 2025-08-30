import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contract.g.dart';

/// Types of contracts available
@JsonEnum()
enum ContractType {
  playing,
  youth,
  coaching,
  staff;
}

/// Types of performance bonuses
@JsonEnum()
enum PerformanceBonus {
  goalBonus,
  assistBonus,
  cleanSheetBonus,
  appearanceBonus,
  winBonus,
  trophyBonus;
}

/// Represents a contract between a player and a team
@JsonSerializable()
class Contract extends Equatable {
  /// Unique identifier for the contract
  final String id;

  /// ID of the player this contract is for
  final String playerId;

  /// ID of the team offering the contract
  final String teamId;

  /// Contract start date
  final DateTime startDate;

  /// Contract end date
  final DateTime endDate;

  /// Weekly salary amount
  final int weeklySalary;

  /// Type of contract
  final ContractType contractType;

  /// One-time signing bonus
  final int signingBonus;

  /// Release clause amount (0 means no release clause)
  final int releaseClause;

  /// Loyalty bonus paid at contract completion
  final int loyaltyBonus;

  /// Performance-based bonuses
  final Map<PerformanceBonus, int> performanceBonuses;

  /// Whether the contract is currently active
  final bool isActive;

  /// Creates a new contract instance
  Contract({
    required this.id,
    required this.playerId,
    required this.teamId,
    required this.startDate,
    required this.endDate,
    required this.weeklySalary,
    ContractType? contractType,
    int? signingBonus,
    int? releaseClause,
    int? loyaltyBonus,
    Map<PerformanceBonus, int>? performanceBonuses,
    bool? isActive,
  })  : contractType = contractType ?? ContractType.playing,
        signingBonus = signingBonus ?? 0,
        releaseClause = releaseClause ?? 0,
        loyaltyBonus = loyaltyBonus ?? 0,
        performanceBonuses = performanceBonuses ?? {},
        isActive = isActive ?? true {
    // Validation
    if (id.trim().isEmpty) {
      throw ArgumentError('Contract ID cannot be empty');
    }
    if (playerId.trim().isEmpty) {
      throw ArgumentError('Player ID cannot be empty');
    }
    if (teamId.trim().isEmpty) {
      throw ArgumentError('Team ID cannot be empty');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('Contract end date cannot be before start date');
    }
    if (weeklySalary < 0) {
      throw ArgumentError('Weekly salary cannot be negative');
    }
    
    final signingBonusValue = signingBonus ?? 0;
    final releaseClauseValue = releaseClause ?? 0;
    
    if (signingBonusValue < 0) {
      throw ArgumentError('Signing bonus cannot be negative');
    }
    if (releaseClauseValue < 0) {
      throw ArgumentError('Release clause cannot be negative');
    }
  }

  /// Creates a contract from JSON data
  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);

  /// Converts the contract to JSON data
  Map<String, dynamic> toJson() => _$ContractToJson(this);

  /// Calculates duration in complete years
  int get durationInYears {
    final difference = endDate.difference(startDate);
    return (difference.inDays / 365).floor();
  }

  /// Calculates annual salary (weekly salary * 52)
  int get annualSalary => weeklySalary * 52;

  /// Calculates total contract value including bonuses
  int get totalValue {
    final totalSalary = annualSalary * durationInYears;
    return totalSalary + signingBonus + loyaltyBonus;
  }

  /// Checks if contract is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Calculates days remaining in contract
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Extends the contract with new terms
  Contract extendContract({
    required DateTime newEndDate,
    required int newWeeklySalary,
    int? newSigningBonus,
    int? newLoyaltyBonus,
    Map<PerformanceBonus, int>? newPerformanceBonuses,
  }) {
    if (newEndDate.isBefore(endDate)) {
      throw ArgumentError('New end date cannot be before current end date');
    }

    return Contract(
      id: id,
      playerId: playerId,
      teamId: teamId,
      startDate: startDate,
      endDate: newEndDate,
      weeklySalary: newWeeklySalary,
      contractType: contractType,
      signingBonus: newSigningBonus ?? signingBonus,
      releaseClause: releaseClause,
      loyaltyBonus: newLoyaltyBonus ?? loyaltyBonus,
      performanceBonuses: newPerformanceBonuses ?? performanceBonuses,
      isActive: isActive,
    );
  }

  /// Terminates the contract
  Contract terminate() {
    return Contract(
      id: id,
      playerId: playerId,
      teamId: teamId,
      startDate: startDate,
      endDate: endDate,
      weeklySalary: weeklySalary,
      contractType: contractType,
      signingBonus: signingBonus,
      releaseClause: releaseClause,
      loyaltyBonus: loyaltyBonus,
      performanceBonuses: performanceBonuses,
      isActive: false,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contract(id: $id, playerId: $playerId, teamId: $teamId, '
        'weeklySalary: $weeklySalary, startDate: ${startDate.toIso8601String().substring(0, 10)}, '
        'endDate: ${endDate.toIso8601String().substring(0, 10)}, isActive: $isActive)';
  }
}
