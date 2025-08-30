# Models API Reference

[← Back to Documentation Home](../README.md)

This document provides comprehensive API reference for all data models in the Soccer Engine.

## 📋 Overview

The Soccer Engine models represent core entities in soccer simulation:
- **Player**: Individual player with attributes and statistics
- **Team**: Squad management and team organization
- **Match**: Match data, events, and results
- **Financial Account**: Budget management and Financial Fair Play
- **Youth Academy**: Youth player development
- **Contracts & Transfers**: Player movement and negotiations

## 👤 Player

The core entity representing a soccer player.

### Constructor

```dart
Player({
  required String id,
  required String name,
  required int age,
  required PlayerPosition position,
  int? technical,
  int? physical,
  int? mental,
  int? form,
  int? fitness,
})
```

### Properties

| Property | Type | Description | Range |
|----------|------|-------------|-------|
| `id` | `String` | Unique player identifier | Non-empty |
| `name` | `String` | Player's full name | Non-empty |
| `age` | `int` | Player's age in years | 16-45 |
| `position` | `PlayerPosition` | Primary playing position | Enum value |
| `technical` | `int` | Technical skill rating | 1-100 (default: 50) |
| `physical` | `int` | Physical attributes rating | 1-100 (default: 50) |
| `mental` | `int` | Mental attributes rating | 1-100 (default: 50) |
| `form` | `int` | Current form rating | 1-10 (default: 7) |
| `fitness` | `int` | Current fitness percentage | 0-100 (default: 100) |

### Computed Properties

#### `overallRating` → `int`
Simple average of all attributes:
```dart
int get overallRating => ((technical + physical + mental) / 3).round();
```

#### `positionOverallRating` → `int`
Position-weighted overall rating:
- **Goalkeepers**: Mental (50%), Physical (30%), Technical (20%)
- **Defenders**: Physical (40%), Mental (35%), Technical (25%)
- **Midfielders**: Technical (40%), Mental (35%), Physical (25%)
- **Forwards**: Technical (45%), Physical (30%), Mental (25%)

### Methods

#### `updateForm(int newForm)` → `Player`
Updates player's form rating.
```dart
final player = Player(id: 'p1', name: 'Test', age: 25, position: PlayerPosition.midfielder);
final updatedPlayer = player.updateForm(9);
print(updatedPlayer.form); // 9
```

#### `updateFitness(int newFitness)` → `Player`
Updates player's fitness level.
```dart
final updatedPlayer = player.updateFitness(85);
print(updatedPlayer.fitness); // 85
```

### JSON Serialization

```dart
// To JSON
final json = player.toJson();

// From JSON
final player = Player.fromJson(json);
```

### Example Usage

```dart
// Create a player
final player = Player(
  id: 'messi-1',
  name: 'Lionel Messi',
  age: 36,
  position: PlayerPosition.forward,
  technical: 95,
  physical: 75,
  mental: 98,
  form: 9,
  fitness: 90,
);

print('Overall: ${player.overallRating}'); // 89
print('Position Rating: ${player.positionOverallRating}'); // 91

// Update player condition
final updatedPlayer = player
    .updateForm(8)
    .updateFitness(95);
```

## 🏟️ Team

Represents a soccer team with squad management capabilities.

### Constructor

```dart
Team({
  required String id,
  required String name,
  required String city,
  required int foundedYear,
  Stadium? stadium,
  List<Player>? players,
  Formation? formation,
  List<Player>? startingXI,
  int? morale,
})
```

### Properties

| Property | Type | Description | Constraints |
|----------|------|-------------|-------------|
| `id` | `String` | Unique team identifier | Non-empty |
| `name` | `String` | Team name | Non-empty |
| `city` | `String` | Team's home city | Non-empty |
| `foundedYear` | `int` | Year team was founded | 1850-current year |
| `stadium` | `Stadium` | Home stadium | Auto-generated if null |
| `players` | `List<Player>` | Squad players | Max 30 players |
| `formation` | `Formation` | Current formation | Default: 4-4-2 |
| `startingXI` | `List<Player>` | Starting lineup | Exactly 11 players |
| `morale` | `int` | Team morale | 0-100 (default: 75) |

### Computed Properties

#### `overallRating` → `int`
Average rating of all squad players.

#### `positionStrengths` → `Map<PlayerPosition, int>`
Average rating by position:
```dart
final strengths = team.positionStrengths;
print('Midfielder strength: ${strengths[PlayerPosition.midfielder]}');
```

#### `chemistry` → `int`
Team chemistry calculation (0-100) based on:
- Team morale (base)
- Squad balance bonus
- Squad size considerations

#### `isCompetitive` → `bool`
Whether team meets minimum squad requirements (16+ players).

### Methods

#### `addPlayer(Player player)` → `Team`
Adds a player to the squad.
```dart
final newPlayer = Player(id: 'new1', name: 'New Player', age: 22, position: PlayerPosition.midfielder);
final updatedTeam = team.addPlayer(newPlayer);
```

**Throws**: `ArgumentError` if player already exists or squad is full.

#### `removePlayer(String playerId)` → `Team`
Removes a player from squad and starting XI.
```dart
final updatedTeam = team.removePlayer('player-id');
```

#### `setFormation(Formation newFormation)` → `Team`
Changes team formation.
```dart
final updatedTeam = team.setFormation(Formation.f433);
```

#### `setStartingXI(List<Player> newStartingXI)` → `Team`
Sets the starting lineup.
```dart
final starters = team.players.take(11).toList();
final updatedTeam = team.setStartingXI(starters);
```

**Throws**: `ArgumentError` if lineup is invalid.

#### `updateMorale(int newMorale)` → `Team`
Updates team morale.
```dart
final updatedTeam = team.updateMorale(85);
```

#### `getPlayersByPosition(PlayerPosition position)` → `List<Player>`
Gets all players in a specific position.
```dart
final midfielders = team.getPlayersByPosition(PlayerPosition.midfielder);
```

### Formation Enum

```dart
enum Formation {
  f442,   // 4-4-2
  f433,   // 4-3-3
  f352,   // 3-5-2
  f541,   // 5-4-1
  f343,   // 3-4-3
  f532,   // 5-3-2
  f4231,  // 4-2-3-1
  f4141,  // 4-1-4-1
  f451,   // 4-5-1
  f3421,  // 3-4-2-1
}
```

Each formation has:
- `requirements` → `List<int>`: Player requirements [GK, DEF, MID, FWD]
- `displayName` → `String`: Human-readable name

### Example Usage

```dart
// Create a team
final team = Team(
  id: 'barcelona',
  name: 'FC Barcelona',
  city: 'Barcelona',
  foundedYear: 1899,
  formation: Formation.f433,
);

// Add players
final updatedTeam = team
    .addPlayer(goalkeeper)
    .addPlayer(defender)
    .addPlayer(midfielder);

// Check team status
print('Chemistry: ${updatedTeam.chemistry}');
print('Competitive: ${updatedTeam.isCompetitive}');
print('Overall: ${updatedTeam.overallRating}');
```

## ⚽ Match

Represents a soccer match with events, statistics, and results.

### Constructor

```dart
Match({
  required String id,
  required String homeTeamId,
  required String awayTeamId,
  required DateTime kickoffTime,
  int? homeScore,
  int? awayScore,
  List<MatchEvent>? events,
  Map<String, dynamic>? statistics,
  MatchStatus? status,
  WeatherCondition? weather,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique match identifier |
| `homeTeamId` | `String` | Home team ID |
| `awayTeamId` | `String` | Away team ID |
| `kickoffTime` | `DateTime` | Match start time |
| `homeScore` | `int` | Home team goals (default: 0) |
| `awayScore` | `int` | Away team goals (default: 0) |
| `events` | `List<MatchEvent>` | Match events |
| `statistics` | `Map<String, dynamic>` | Match statistics |
| `status` | `MatchStatus` | Current match status |
| `weather` | `WeatherCondition` | Weather conditions |

### Match Events

```dart
enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  kickoff,
  fullTime,
}

class MatchEvent {
  final String id;
  final MatchEventType type;
  final int minute;
  final String? playerId;
  final String? teamId;
  final String description;
}
```

### Weather Conditions

```dart
enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  snowy,
  foggy,
}
```

### Example Usage

```dart
final match = Match(
  id: 'match-1',
  homeTeamId: 'barcelona',
  awayTeamId: 'madrid',
  kickoffTime: DateTime.now(),
  homeScore: 2,
  awayScore: 1,
  weather: WeatherCondition.sunny,
);

// Add events
final updatedMatch = match.addEvent(
  MatchEvent(
    id: 'event-1',
    type: MatchEventType.goal,
    minute: 25,
    playerId: 'messi-1',
    teamId: 'barcelona',
    description: 'Goal by Lionel Messi',
  ),
);
```

## 💰 Financial Account

Manages team finances and Financial Fair Play compliance.

### Constructor

```dart
FinancialAccount({
  required String teamId,
  required int balance,
  required String currency,
  Map<BudgetCategory, int>? budgetLimits,
  List<FinancialTransaction>? transactions,
})
```

### Budget Categories

```dart
enum BudgetCategory {
  transfers,
  wages,
  youth,
  facilities,
  marketing,
  operations,
}
```

### Methods

#### `getAvailableBudget(BudgetCategory category)` → `int`
Gets remaining budget for a category.

#### `addTransaction(FinancialTransaction transaction)` → `FinancialAccount`
Records a financial transaction.

#### `checkFFPCompliance(DateTime startDate, DateTime endDate)` → `FFPComplianceResult`
Checks Financial Fair Play compliance over a period.

### Example Usage

```dart
final account = FinancialAccount(
  teamId: 'barcelona',
  balance: 100000000, // €100M
  currency: 'EUR',
  budgetLimits: {
    BudgetCategory.transfers: 50000000, // €50M
    BudgetCategory.wages: 200000000,    // €200M
  },
);

final transferBudget = account.getAvailableBudget(BudgetCategory.transfers);
print('Transfer budget: €${transferBudget ~/ 1000000}M');
```

## 🌱 Youth Academy

Manages youth player development and progression.

### Constructor

```dart
YouthAcademy({
  required String id,
  required String teamId,
  required String name,
  List<YouthPlayer>? players,
  Map<String, int>? facilities,
  List<YouthCoach>? coaches,
  int? reputation,
})
```

### Youth Player Development

```dart
class YouthPlayer extends Player {
  final int potential;           // Max possible rating
  final double developmentRate;  // Growth speed
  final List<String> traits;    // Special characteristics
  
  // Development methods
  YouthPlayer developSkills(int months);
  bool get readyForFirstTeam;
}
```

### Example Usage

```dart
final academy = YouthAcademy(
  id: 'barca-academy',
  teamId: 'barcelona',
  name: 'La Masia',
  reputation: 95,
);

// Develop youth players
final developedAcademy = academy.developPlayers(months: 6);

// Check for first-team ready players
final readyPlayers = academy.players
    .where((p) => p.readyForFirstTeam)
    .toList();
```

## 📄 Contracts & Transfers

### Contract

```dart
class Contract {
  final String id;
  final String playerId;
  final String teamId;
  final DateTime startDate;
  final DateTime endDate;
  final int weeklyWage;
  final Map<String, dynamic> clauses;
  
  bool get isActive;
  int get daysRemaining;
  int get totalValue;
}
```

### Transfer

```dart
class Transfer {
  final String id;
  final String playerId;
  final String fromTeamId;
  final String toTeamId;
  final int fee;
  final DateTime agreedDate;
  final DateTime? completedDate;
  final TransferStatus status;
}

enum TransferStatus {
  agreed,
  pending,
  completed,
  cancelled,
}
```

## 🔧 Validation Rules

All models include comprehensive validation:

### Player Validation
- Age: 16-45 years
- Attributes: 1-100 range
- Form: 1-10 range
- Fitness: 0-100 range
- ID and name: Non-empty strings

### Team Validation
- Squad size: 0-30 players
- Starting XI: Exactly 11 unique players from squad
- Founded year: 1850-current year
- Morale: 0-100 range

### Financial Validation
- Positive balance for transactions
- Budget limits must be positive
- FFP compliance calculations

## 📚 Next Steps

- **AI Systems**: Explore [AI Systems API](ai-systems.md)
- **Game Systems**: Learn about [Game Systems API](game-systems.md)
- **Technical Details**: Dive into [System Architecture](../technical/architecture.md)

---

**Navigation**: [Documentation Home](../README.md) → API Reference → Models
