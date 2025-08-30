import '../../lib/src/models/league.dart';
import '../../lib/src/models/team.dart';
import '../../lib/src/models/player.dart';
import '../../lib/src/models/match.dart';
import '../../lib/src/models/gameweek.dart';
import '../../lib/src/systems/game_state.dart';

/// Test data builders for creating consistent test objects
class TestDataBuilders {
  static League createTestLeague({
    String id = 'test-league',
    String name = 'Test League',
    String country = 'Test Country',
    int teamCount = 4,
  }) {
    final teams = List.generate(teamCount, (index) => 
      createTestTeam(id: 'team-${index + 1}', name: 'Team ${index + 1}'));
    
    return League(
      id: id,
      name: name,
      country: country,
      teams: teams,
      minTeams: 2,
      maxTeams: 20,
    );
  }

  static Team createTestTeam({
    String id = 'test-team',
    String name = 'Test Team',
    String city = 'Test City',
    int playerCount = 16,
  }) {
    final players = List.generate(playerCount, (index) => 
      createTestPlayer(id: 'player-${index + 1}', name: 'Player ${index + 1}'));
    
    return Team(
      id: id,
      name: name,
      city: city,
      foundedYear: 2000,
      players: players,
    );
  }

  static Player createTestPlayer({
    String id = 'test-player',
    String name = 'Test Player',
    int age = 25,
    PlayerPosition position = PlayerPosition.midfielder,
    int technical = 70,
    int physical = 70,
    int mental = 70,
  }) {
    return Player(
      id: id,
      name: name,
      age: age,
      position: position,
      technical: technical,
      physical: physical,
      mental: mental,
    );
  }

  static Weather createTestWeather({
    WeatherCondition condition = WeatherCondition.sunny,
    double temperature = 20.0,
    double humidity = 50.0,
    double windSpeed = 10.0,
  }) {
    return Weather.create(
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
    );
  }

  static Match createTestMatch({
    String id = 'test-match',
    Team? homeTeam,
    Team? awayTeam,
    DateTime? kickoffTime,
    Weather? weather,
  }) {
    return Match.create(
      id: id,
      homeTeam: homeTeam ?? createTestTeam(id: 'home-team', name: 'Home Team'),
      awayTeam: awayTeam ?? createTestTeam(id: 'away-team', name: 'Away Team'),
      weather: weather ?? createTestWeather(),
      kickoffTime: kickoffTime ?? DateTime.now().add(Duration(days: 1)),
    );
  }

  static Gameweek createTestGameweek({
    String id = 'test-gameweek',
    int number = 1,
    String seasonId = 'test-season',
    DateTime? scheduledDate,
    List<Match>? matches,
  }) {
    return Gameweek(
      id: id,
      number: number,
      seasonId: seasonId,
      scheduledDate: scheduledDate ?? DateTime.now(),
      matches: matches ?? [],
    );
  }
}

/// Builder pattern for complex game states
class GameStateBuilder {
  League? _league;
  String? _playerTeamId;
  DateTime? _currentDate;
  int? _currentDay;

  GameStateBuilder withLeague(League league) {
    _league = league;
    return this;
  }

  GameStateBuilder withPlayerTeam(String teamId) {
    _playerTeamId = teamId;
    return this;
  }

  GameStateBuilder atDate(DateTime date) {
    _currentDate = date;
    return this;
  }

  GameStateBuilder atDay(int day) {
    _currentDay = day;
    return this;
  }

  GameState build() {
    return GameState(
      league: _league ?? TestDataBuilders.createTestLeague(),
      playerTeamId: _playerTeamId ?? 'team-1',
      currentDate: _currentDate ?? DateTime(2024, 8, 1),
      currentDay: _currentDay ?? 1,
    );
  }
}

/// Builder for complete season scenarios
/// TODO: Implement when Season model is created
// class CompleteSeasonBuilder {
//   League? _league;
//   List<Gameweek>? _gameweeks;
//   
//   CompleteSeasonBuilder withLeague(League league) {
//     _league = league;
//     return this;
//   }
//
//   CompleteSeasonBuilder generateFixtures() {
//     final league = _league ?? TestDataBuilders.createTestLeague();
//     final gameweeks = <Gameweek>[];
//     
//     // Generate round-robin fixtures
//     final teams = league.teams;
//     final totalGameweeks = league.requiredGameweeks;
//     
//     for (int gw = 1; gw <= totalGameweeks; gw++) {
//       final matches = <Match>[];
//       
//       // Simple fixture generation for testing
//       for (int i = 0; i < teams.length; i += 2) {
//         if (i + 1 < teams.length) {
//           final match = TestDataBuilders.createTestMatch(
//             id: 'match-gw${gw}-${i}',
//             homeTeam: teams[i],
//             awayTeam: teams[i + 1],
//             kickoffTime: DateTime(2024, 8, 1).add(Duration(days: (gw - 1) * 7)),
//           );
//           matches.add(match);
//         }
//       }
//       
//       gameweeks.add(TestDataBuilders.createTestGameweek(
//         id: 'gameweek-$gw',
//         number: gw,
//         scheduledDate: DateTime(2024, 8, 1).add(Duration(days: (gw - 1) * 7)),
//         matches: matches,
//       ));
//     }
//     
//     _gameweeks = gameweeks;
//     return this;
//   }
//
//   Season build() {
//     return Season(
//       id: 'test-season',
//       league: _league ?? TestDataBuilders.createTestLeague(),
//       gameweeks: _gameweeks ?? [],
//       startDate: DateTime(2024, 8, 1),
//     );
//   }
// }
