import 'package:test/test.dart';
import 'package:soccer_engine/src/models/match.dart';
import 'package:soccer_engine/src/models/team.dart';
import 'package:soccer_utilities/src/models/player.dart';

void main() {
  group('WeatherCondition', () {
    test('should have all expected weather conditions', () {
      expect(WeatherCondition.values, hasLength(6));
      expect(WeatherCondition.values, contains(WeatherCondition.sunny));
      expect(WeatherCondition.values, contains(WeatherCondition.cloudy));
      expect(WeatherCondition.values, contains(WeatherCondition.rainy));
      expect(WeatherCondition.values, contains(WeatherCondition.snowy));
      expect(WeatherCondition.values, contains(WeatherCondition.windy));
      expect(WeatherCondition.values, contains(WeatherCondition.foggy));
    });
  });

  group('MatchResult', () {
    test('should have all expected match results', () {
      expect(MatchResult.values, hasLength(3));
      expect(MatchResult.values, contains(MatchResult.homeWin));
      expect(MatchResult.values, contains(MatchResult.draw));
      expect(MatchResult.values, contains(MatchResult.awayWin));
    });
  });

  group('Weather', () {
    test('should create weather with valid parameters', () {
      final weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 60.0,
        windSpeed: 10.0,
      );

      expect(weather.condition, equals(WeatherCondition.sunny));
      expect(weather.temperature, equals(20.0));
      expect(weather.humidity, equals(60.0));
      expect(weather.windSpeed, equals(10.0));
    });

    test('should reject invalid temperature', () {
      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: -50.0,
          humidity: 60.0,
          windSpeed: 10.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Temperature must be between -40 and 50 degrees Celsius',
        )),
      );

      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: 60.0,
          humidity: 60.0,
          windSpeed: 10.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Temperature must be between -40 and 50 degrees Celsius',
        )),
      );
    });

    test('should reject invalid humidity', () {
      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: 20.0,
          humidity: -10.0,
          windSpeed: 10.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Humidity must be between 0 and 100 percent',
        )),
      );

      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: 20.0,
          humidity: 110.0,
          windSpeed: 10.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Humidity must be between 0 and 100 percent',
        )),
      );
    });

    test('should reject invalid wind speed', () {
      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: 20.0,
          humidity: 60.0,
          windSpeed: -5.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Wind speed must be between 0 and 200 km/h',
        )),
      );

      expect(
        () => Weather.create(
          condition: WeatherCondition.sunny,
          temperature: 20.0,
          humidity: 60.0,
          windSpeed: 250.0,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Wind speed must be between 0 and 200 km/h',
        )),
      );
    });

    test('should calculate performance impact for sunny weather', () {
      final weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 50.0,
        windSpeed: 10.0,
      );

      expect(weather.performanceImpact, equals(1.1)); // 1.0 + 0.05 (sunny) + 0.05 (ideal temp)
    });

    test('should calculate performance impact for rainy weather', () {
      final weather = Weather.create(
        condition: WeatherCondition.rainy,
        temperature: 10.0,
        humidity: 90.0,
        windSpeed: 20.0,
      );

      expect(weather.performanceImpact, equals(0.8)); // 1.0 - 0.15 (rainy) - 0.05 (high humidity)
    });

    test('should calculate performance impact for extreme conditions', () {
      final weather = Weather.create(
        condition: WeatherCondition.snowy,
        temperature: -10.0,
        humidity: 85.0,
        windSpeed: 40.0,
      );

      // 1.0 - 0.2 (snowy) - 0.1 (extreme temp) - 0.05 (high humidity) - 0.05 (high wind) = 0.6
      // But clamped to 0.8
      expect(weather.performanceImpact, equals(0.8));
    });

    test('should calculate performance impact with maximum bonus', () {
      final weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 40.0,
        windSpeed: 5.0,
      );

      // 1.0 + 0.05 (sunny) + 0.05 (ideal temp) = 1.1
      expect(weather.performanceImpact, equals(1.1));
    });

    test('should support equality comparison', () {
      final weather1 = Weather.create(
        condition: WeatherCondition.cloudy,
        temperature: 15.0,
        humidity: 70.0,
        windSpeed: 15.0,
      );

      final weather2 = Weather.create(
        condition: WeatherCondition.cloudy,
        temperature: 15.0,
        humidity: 70.0,
        windSpeed: 15.0,
      );

      final weather3 = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 15.0,
        humidity: 70.0,
        windSpeed: 15.0,
      );

      expect(weather1, equals(weather2));
      expect(weather1, isNot(equals(weather3)));
      expect(weather1.hashCode, equals(weather2.hashCode));
    });

    test('should have proper string representation', () {
      final weather = Weather.create(
        condition: WeatherCondition.cloudy,
        temperature: 18.5,
        humidity: 65.0,
        windSpeed: 12.5,
      );

      expect(
        weather.toString(),
        equals('Weather(condition: WeatherCondition.cloudy, temperature: 18.5°C, humidity: 65.0%, windSpeed: 12.5km/h)'),
      );
    });

    test('should serialize to and from JSON', () {
      final weather = Weather.create(
        condition: WeatherCondition.windy,
        temperature: 25.0,
        humidity: 55.0,
        windSpeed: 30.0,
      );

      final json = weather.toJson();
      final deserialized = Weather.fromJson(json);

      expect(deserialized, equals(weather));
    });
  });

  group('Match', () {
    late Stadium stadium1;
    late Stadium stadium2;
    late Team homeTeam;
    late Team awayTeam;
    late Weather weather;
    late DateTime kickoffTime;

    setUp(() {
      stadium1 = Stadium(
        name: 'Home Stadium',
        city: 'Home City',
        capacity: 50000,
      );

      stadium2 = Stadium(
        name: 'Away Stadium',
        city: 'Away City',
        capacity: 40000,
      );

      homeTeam = Team(
        id: 'home-team',
        name: 'Home Team',
        city: 'Home City',
        foundedYear: 2000,
        stadium: stadium1,
        formation: Formation.f442,
      );

      awayTeam = Team(
        id: 'away-team',
        name: 'Away Team',
        city: 'Away City',
        foundedYear: 2001,
        stadium: stadium2,
        formation: Formation.f433,
      );

      weather = Weather.create(
        condition: WeatherCondition.sunny,
        temperature: 20.0,
        humidity: 60.0,
        windSpeed: 10.0,
      );

      kickoffTime = DateTime.now().add(const Duration(hours: 2));
    });

    test('should create match with valid parameters', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      expect(match.id, equals('match-1'));
      expect(match.homeTeam, equals(homeTeam));
      expect(match.awayTeam, equals(awayTeam));
      expect(match.weather, equals(weather));
      expect(match.kickoffTime, equals(kickoffTime));
      expect(match.isNeutralVenue, isFalse);
      expect(match.isCompleted, isFalse);
      expect(match.homeGoals, equals(0));
      expect(match.awayGoals, equals(0));
      expect(match.result, isNull);
      expect(match.currentMinute, equals(0));
      expect(match.events, isEmpty);
    });

    test('should create neutral venue match', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
        isNeutralVenue: true,
      );

      expect(match.isNeutralVenue, isTrue);
    });

    test('should reject empty match ID', () {
      expect(
        () => Match.create(
          id: '',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: kickoffTime,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Match ID cannot be empty',
        )),
      );
    });

    test('should reject same home and away teams', () {
      expect(
        () => Match.create(
          id: 'match-1',
          homeTeam: homeTeam,
          awayTeam: homeTeam,
          weather: weather,
          kickoffTime: kickoffTime,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Home and away teams cannot be the same',
        )),
      );
    });

    test('should reject past kickoff time', () {
      final pastTime = DateTime.now().subtract(const Duration(days: 2));

      expect(
        () => Match.create(
          id: 'match-1',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          weather: weather,
          kickoffTime: pastTime,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Kickoff time cannot be more than 1 day in the past',
        )),
      );
    });

    test('should calculate home advantage based on stadium capacity', () {
      // Large stadium (>80k)
      final largeStadium = Stadium(name: 'Large', city: 'City', capacity: 85000);
      final largeTeam = Team(id: 'large', name: 'Large Team', city: 'City', foundedYear: 2000, stadium: largeStadium, formation: Formation.f442);
      final largeMatch = Match.create(
        id: 'large-match',
        homeTeam: largeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );
      expect(largeMatch.homeAdvantage, equals(1.15));

      // Medium stadium (60-80k)
      final mediumStadium = Stadium(name: 'Medium', city: 'City', capacity: 70000);
      final mediumTeam = Team(id: 'medium', name: 'Medium Team', city: 'City', foundedYear: 2000, stadium: mediumStadium, formation: Formation.f442);
      final mediumMatch = Match.create(
        id: 'medium-match',
        homeTeam: mediumTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );
      expect(mediumMatch.homeAdvantage, equals(1.12));

      // Small stadium (<20k)
      final smallStadium = Stadium(name: 'Small', city: 'City', capacity: 15000);
      final smallTeam = Team(id: 'small', name: 'Small Team', city: 'City', foundedYear: 2000, stadium: smallStadium, formation: Formation.f442);
      final smallMatch = Match.create(
        id: 'small-match',
        homeTeam: smallTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );
      expect(smallMatch.homeAdvantage, equals(1.05));
    });

    test('should have no home advantage for neutral venue', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
        isNeutralVenue: true,
      );

      expect(match.homeAdvantage, equals(1.0));
    });

    test('should update match state with copyWith', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      final updatedMatch = match.copyWith(
        isCompleted: true,
        homeGoals: 2,
        awayGoals: 1,
        result: MatchResult.homeWin,
        currentMinute: 90,
      );

      expect(updatedMatch.isCompleted, isTrue);
      expect(updatedMatch.homeGoals, equals(2));
      expect(updatedMatch.awayGoals, equals(1));
      expect(updatedMatch.result, equals(MatchResult.homeWin));
      expect(updatedMatch.currentMinute, equals(90));
      
      // Original should be unchanged
      expect(match.isCompleted, isFalse);
      expect(match.homeGoals, equals(0));
      expect(match.awayGoals, equals(0));
    });

    test('should support equality comparison', () {
      final match1 = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      final match2 = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      final match3 = Match.create(
        id: 'match-2',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      expect(match1, equals(match2));
      expect(match1, isNot(equals(match3)));
      expect(match1.hashCode, equals(match2.hashCode));
    });

    test('should have proper string representation', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      expect(
        match.toString(),
        equals('Match(id: match-1, Home Team vs Away Team, score: 0-0, minute: 0)'),
      );
    });

    test('should serialize to and from JSON', () {
      final match = Match.create(
        id: 'match-1',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        weather: weather,
        kickoffTime: kickoffTime,
      );

      final json = match.toJson();
      final deserialized = Match.fromJson(json);

      expect(deserialized, equals(match));
    });
  });

  group('MatchEventType', () {
    test('should have all expected event types', () {
      expect(MatchEventType.values, hasLength(21));
      expect(MatchEventType.values, contains(MatchEventType.goal));
      expect(MatchEventType.values, contains(MatchEventType.yellowCard));
      expect(MatchEventType.values, contains(MatchEventType.redCard));
      expect(MatchEventType.values, contains(MatchEventType.substitution));
      expect(MatchEventType.values, contains(MatchEventType.kickoff));
      expect(MatchEventType.values, contains(MatchEventType.halfTime));
      expect(MatchEventType.values, contains(MatchEventType.fullTime));
      expect(MatchEventType.values, contains(MatchEventType.penalty));
      expect(MatchEventType.values, contains(MatchEventType.ownGoal));
      expect(MatchEventType.values, contains(MatchEventType.assist));
      // Enhanced Football Manager-style events
      expect(MatchEventType.values, contains(MatchEventType.injury));
      expect(MatchEventType.values, contains(MatchEventType.shot));
      expect(MatchEventType.values, contains(MatchEventType.shotOnTarget));
      expect(MatchEventType.values, contains(MatchEventType.shotOffTarget));
      expect(MatchEventType.values, contains(MatchEventType.tackle));
      expect(MatchEventType.values, contains(MatchEventType.foul));
      expect(MatchEventType.values, contains(MatchEventType.corner));
      expect(MatchEventType.values, contains(MatchEventType.offside));
      expect(MatchEventType.values, contains(MatchEventType.save));
      expect(MatchEventType.values, contains(MatchEventType.tacticalChange));
      expect(MatchEventType.values, contains(MatchEventType.momentumShift));
    });
  });

  group('MatchEvent', () {
    test('should create match event with valid parameters', () {
      final event = MatchEvent.create(
        id: 'event-1',
        type: MatchEventType.goal,
        minute: 25,
        teamId: 'team-1',
        description: 'Goal scored by Player',
        playerId: 'player-1',
        playerName: 'John Doe',
        metadata: {'position': 'striker'},
      );

      expect(event.id, equals('event-1'));
      expect(event.type, equals(MatchEventType.goal));
      expect(event.minute, equals(25));
      expect(event.teamId, equals('team-1'));
      expect(event.description, equals('Goal scored by Player'));
      expect(event.playerId, equals('player-1'));
      expect(event.playerName, equals('John Doe'));
      expect(event.metadata, equals({'position': 'striker'}));
    });

    test('should create event without optional parameters', () {
      final event = MatchEvent.create(
        id: 'event-1',
        type: MatchEventType.halfTime,
        minute: 45,
        teamId: 'team-1',
        description: 'Half time',
      );

      expect(event.playerId, isNull);
      expect(event.playerName, isNull);
      expect(event.metadata, isEmpty);
    });

    test('should reject empty event ID', () {
      expect(
        () => MatchEvent.create(
          id: '',
          type: MatchEventType.goal,
          minute: 25,
          teamId: 'team-1',
          description: 'Goal',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Event ID cannot be empty',
        )),
      );
    });

    test('should reject invalid minute', () {
      expect(
        () => MatchEvent.create(
          id: 'event-1',
          type: MatchEventType.goal,
          minute: -5,
          teamId: 'team-1',
          description: 'Goal',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Event minute must be between 0 and 120',
        )),
      );

      expect(
        () => MatchEvent.create(
          id: 'event-1',
          type: MatchEventType.goal,
          minute: 125,
          teamId: 'team-1',
          description: 'Goal',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Event minute must be between 0 and 120',
        )),
      );
    });

    test('should reject empty team ID', () {
      expect(
        () => MatchEvent.create(
          id: 'event-1',
          type: MatchEventType.goal,
          minute: 25,
          teamId: '',
          description: 'Goal',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Team ID cannot be empty',
        )),
      );
    });

    test('should reject empty description', () {
      expect(
        () => MatchEvent.create(
          id: 'event-1',
          type: MatchEventType.goal,
          minute: 25,
          teamId: 'team-1',
          description: '',
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Event description cannot be empty',
        )),
      );
    });

    test('should have proper string representation', () {
      final event = MatchEvent.create(
        id: 'event-1',
        type: MatchEventType.goal,
        minute: 32,
        teamId: 'team-1',
        description: 'Beautiful goal from outside the box',
      );

      expect(
        event.toString(),
        equals('MatchEvent(32\': Beautiful goal from outside the box)'),
      );
    });

    test('should serialize to and from JSON', () {
      final event = MatchEvent.create(
        id: 'event-1',
        type: MatchEventType.yellowCard,
        minute: 67,
        teamId: 'team-2',
        description: 'Yellow card for dangerous tackle',
        playerId: 'player-5',
        playerName: 'Mike Smith',
        metadata: {'reason': 'dangerous tackle'},
      );

      final json = event.toJson();
      final deserialized = MatchEvent.fromJson(json);

      expect(deserialized.id, equals(event.id));
      expect(deserialized.type, equals(event.type));
      expect(deserialized.minute, equals(event.minute));
      expect(deserialized.teamId, equals(event.teamId));
      expect(deserialized.description, equals(event.description));
      expect(deserialized.playerId, equals(event.playerId));
      expect(deserialized.playerName, equals(event.playerName));
      expect(deserialized.metadata, equals(event.metadata));
    });
  });
}
