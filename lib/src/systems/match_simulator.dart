import 'dart:math';
import '../models/match.dart';
import '../models/team.dart';
import '../models/player.dart';

/// Handles soccer match simulation with realistic statistical outcomes
class MatchSimulator {
  final Random _random;
  
  /// Creates a new match simulator with optional random seed for testing
  MatchSimulator({int? seed}) : _random = Random(seed);

  /// Simulates a complete match and returns the final result
  Match simulateMatch(Match match) {
    if (match.isCompleted) {
      throw ArgumentError('Cannot simulate an already completed match');
    }

    var currentMatch = match;
    
    // Add kickoff event
    currentMatch = _addEvent(
      currentMatch,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.kickoff,
        minute: 0,
        teamId: match.homeTeam.id,
        description: 'Match kicks off',
      ),
    );

    // Simulate first half (45 minutes + stoppage time)
    currentMatch = _simulateHalf(currentMatch, 1);
    
    // Add half time event
    currentMatch = _addEvent(
      currentMatch,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.halfTime,
        minute: 45,
        teamId: match.homeTeam.id,
        description: 'Half time',
      ),
    );

    // Simulate second half (45-90 minutes + stoppage time)
    currentMatch = _simulateHalf(currentMatch, 2);

    // Add full time event and complete the match
    final finalMinute = 90 + _random.nextInt(6); // 0-5 minutes stoppage time
    currentMatch = _addEvent(
      currentMatch,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.fullTime,
        minute: finalMinute,
        teamId: match.homeTeam.id,
        description: 'Full time',
      ),
    );

    // Determine the result
    MatchResult result;
    if (currentMatch.homeGoals > currentMatch.awayGoals) {
      result = MatchResult.homeWin;
    } else if (currentMatch.homeGoals < currentMatch.awayGoals) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }

    return currentMatch.copyWith(
      isCompleted: true,
      result: result,
      currentMinute: finalMinute,
    );
  }

  /// Simulates a half of the match
  Match _simulateHalf(Match match, int half) {
    var currentMatch = match;
    final startMinute = half == 1 ? 1 : 46;
    final endMinute = half == 1 ? 45 : 90;
    
    // Calculate team strengths considering all factors
    final homeStrength = _calculateTeamStrength(
      match.homeTeam,
      isHome: true,
      weather: match.weather,
      homeAdvantage: match.homeAdvantage,
    );
    
    final awayStrength = _calculateTeamStrength(
      match.awayTeam,
      isHome: false,
      weather: match.weather,
      homeAdvantage: 1.0,
    );

    // Simulate events during the half
    for (int minute = startMinute; minute <= endMinute; minute++) {
      currentMatch = currentMatch.copyWith(currentMinute: minute);
      
      // Calculate event probabilities based on minute and team strengths
      final eventProbability = _calculateEventProbability(minute, homeStrength, awayStrength);
      
      if (_random.nextDouble() < eventProbability['goal']!) {
        currentMatch = _simulateGoal(currentMatch, minute, homeStrength, awayStrength);
      } else if (_random.nextDouble() < eventProbability['yellowCard']!) {
        currentMatch = _simulateYellowCard(currentMatch, minute);
      } else if (_random.nextDouble() < eventProbability['redCard']!) {
        currentMatch = _simulateRedCard(currentMatch, minute);
      }
    }

    return currentMatch;
  }

  /// Calculates overall team strength considering all factors
  double _calculateTeamStrength(Team team, {
    required bool isHome,
    required Weather weather,
    required double homeAdvantage,
  }) {
    // Base strength from team rating
    double strength = team.overallRating.toDouble();
    
    // Apply home advantage
    if (isHome) {
      strength *= homeAdvantage;
    }
    
    // Apply weather effects
    strength *= weather.performanceImpact;
    
    // Apply team chemistry effects
    final chemistryFactor = (team.chemistry / 100.0);
    strength *= (0.9 + (chemistryFactor * 0.2)); // Chemistry affects 90-110% of strength
    
    // Apply morale effects
    final moraleFactor = (team.morale / 100.0);
    strength *= (0.95 + (moraleFactor * 0.1)); // Morale affects 95-105% of strength
    
    return strength;
  }

  /// Calculates event probabilities for a given minute
  Map<String, double> _calculateEventProbability(int minute, double homeStrength, double awayStrength) {
    // Base probabilities per minute
    const baseGoalProbability = 0.02; // ~2% chance per minute
    const baseYellowCardProbability = 0.015; // ~1.5% chance per minute  
    const baseRedCardProbability = 0.002; // ~0.2% chance per minute
    
    // Adjust probabilities based on match phase
    double intensityMultiplier = 1.0;
    if (minute <= 15 || minute >= 75) {
      intensityMultiplier = 1.2; // More events early and late in the game
    } else if (minute >= 30 && minute <= 60) {
      intensityMultiplier = 0.8; // Fewer events in middle period
    }
    
    return {
      'goal': baseGoalProbability * intensityMultiplier,
      'yellowCard': baseYellowCardProbability * intensityMultiplier,
      'redCard': baseRedCardProbability * intensityMultiplier,
    };
  }

  /// Simulates a goal event
  Match _simulateGoal(Match match, int minute, double homeStrength, double awayStrength) {
    // Determine which team scores based on relative strength
    final totalStrength = homeStrength + awayStrength;
    final homeGoalProbability = homeStrength / totalStrength;
    
    final isHomeGoal = _random.nextDouble() < homeGoalProbability;
    final scoringTeam = isHomeGoal ? match.homeTeam : match.awayTeam;
    
    // Select a random player from the scoring team (prefer forwards and midfielders)
    final scorer = _selectGoalScorer(scoringTeam);
    
    // Create goal event
    final goalEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.goal,
      minute: minute,
      teamId: scoringTeam.id,
      description: 'Goal scored by ${scorer?.name ?? 'Unknown Player'}',
      playerId: scorer?.id,
      playerName: scorer?.name,
      metadata: {
        'scoringTeam': isHomeGoal ? 'home' : 'away',
        'homeScore': isHomeGoal ? match.homeGoals + 1 : match.homeGoals,
        'awayScore': isHomeGoal ? match.awayGoals : match.awayGoals + 1,
      },
    );
    
    // Update match with goal
    return _addEvent(
      match.copyWith(
        homeGoals: isHomeGoal ? match.homeGoals + 1 : match.homeGoals,
        awayGoals: isHomeGoal ? match.awayGoals : match.awayGoals + 1,
      ),
      goalEvent,
    );
  }

  /// Simulates a yellow card event
  Match _simulateYellowCard(Match match, int minute) {
    // Randomly select team (slightly favor away team for cards)
    final isHomeCard = _random.nextDouble() < 0.45;
    final team = isHomeCard ? match.homeTeam : match.awayTeam;
    
    // Select a random player from the team
    final player = _selectRandomPlayer(team);
    
    final cardEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.yellowCard,
      minute: minute,
      teamId: team.id,
      description: 'Yellow card for ${player?.name ?? 'Unknown Player'}',
      playerId: player?.id,
      playerName: player?.name,
      metadata: {'cardType': 'yellow'},
    );
    
    return _addEvent(match, cardEvent);
  }

  /// Simulates a red card event
  Match _simulateRedCard(Match match, int minute) {
    // Randomly select team (slightly favor away team for cards)
    final isHomeCard = _random.nextDouble() < 0.45;
    final team = isHomeCard ? match.homeTeam : match.awayTeam;
    
    // Select a random player from the team
    final player = _selectRandomPlayer(team);
    
    final cardEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.redCard,
      minute: minute,
      teamId: team.id,
      description: 'Red card for ${player?.name ?? 'Unknown Player'}',
      playerId: player?.id,
      playerName: player?.name,
      metadata: {'cardType': 'red'},
    );
    
    return _addEvent(match, cardEvent);
  }

  /// Selects a goal scorer, preferring forwards and midfielders
  Player? _selectGoalScorer(Team team) {
    if (team.players.isEmpty) return null;
    
    // Get forwards first, then midfielders, then others
    final forwards = team.players.where((p) => p.position == PlayerPosition.forward).toList();
    final midfielders = team.players.where((p) => p.position == PlayerPosition.midfielder).toList();
    final others = team.players.where((p) => 
        p.position != PlayerPosition.forward && 
        p.position != PlayerPosition.midfielder &&
        p.position != PlayerPosition.goalkeeper).toList();
    
    // Weight selection: 60% forwards, 30% midfielders, 10% others
    final random = _random.nextDouble();
    
    if (random < 0.6 && forwards.isNotEmpty) {
      return forwards[_random.nextInt(forwards.length)];
    } else if (random < 0.9 && midfielders.isNotEmpty) {
      return midfielders[_random.nextInt(midfielders.length)];
    } else if (others.isNotEmpty) {
      return others[_random.nextInt(others.length)];
    } else if (midfielders.isNotEmpty) {
      return midfielders[_random.nextInt(midfielders.length)];
    } else if (forwards.isNotEmpty) {
      return forwards[_random.nextInt(forwards.length)];
    } else {
      return team.players[_random.nextInt(team.players.length)];
    }
  }

  /// Selects a random player from the team
  Player? _selectRandomPlayer(Team team) {
    if (team.players.isEmpty) return null;
    return team.players[_random.nextInt(team.players.length)];
  }

  /// Adds an event to the match
  Match _addEvent(Match match, MatchEvent event) {
    final newEvents = [...match.events, event];
    return match.copyWith(events: newEvents);
  }

  /// Generates a unique event ID
  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  /// Simulates just the final result without detailed events (fast simulation)
  Match simulateQuickResult(Match match) {
    if (match.isCompleted) {
      throw ArgumentError('Cannot simulate an already completed match');
    }

    // Calculate team strengths
    final homeStrength = _calculateTeamStrength(
      match.homeTeam,
      isHome: true,
      weather: match.weather,
      homeAdvantage: match.homeAdvantage,
    );
    
    final awayStrength = _calculateTeamStrength(
      match.awayTeam,
      isHome: false,
      weather: match.weather,
      homeAdvantage: 1.0,
    );

    // Calculate expected goals using Poisson distribution approximation
    final homeExpectedGoals = _calculateExpectedGoals(homeStrength);
    final awayExpectedGoals = _calculateExpectedGoals(awayStrength);
    
    // Generate actual goals using random distribution around expected values
    final homeGoals = _generateGoals(homeExpectedGoals);
    final awayGoals = _generateGoals(awayExpectedGoals);

    // Determine result
    MatchResult result;
    if (homeGoals > awayGoals) {
      result = MatchResult.homeWin;
    } else if (homeGoals < awayGoals) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }

    return match.copyWith(
      isCompleted: true,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      result: result,
      currentMinute: 90,
      events: [
        MatchEvent.create(
          id: _generateEventId(),
          type: MatchEventType.fullTime,
          minute: 90,
          teamId: match.homeTeam.id,
          description: 'Match completed (quick simulation)',
        ),
      ],
    );
  }

  /// Calculates expected goals based on team strength
  double _calculateExpectedGoals(double teamStrength) {
    // Convert team strength (0-100+) to expected goals (typically 0-4)
    // Strong teams (~80-90) should average ~1.5-2.5 goals
    // Weaker teams (~50-60) should average ~0.5-1.5 goals
    final normalizedStrength = (teamStrength / 100.0).clamp(0.3, 3.0);
    return normalizedStrength * 1.5; // Scale to reasonable goal expectation
  }

  /// Generates actual goals from expected goals using randomization
  int _generateGoals(double expectedGoals) {
    // Use a simplified Poisson-like distribution
    // Generate goals with some randomness around the expected value
    final random1 = _random.nextDouble();
    final random2 = _random.nextDouble();
    
    // Weighted random generation favoring values close to expected
    final baseGoals = expectedGoals.floor();
    final fractionalPart = expectedGoals - baseGoals;
    
    int goals = baseGoals;
    
    // Add extra goal based on fractional probability
    if (random1 < fractionalPart) {
      goals++;
    }
    
    // Small chance for additional goals (excitement factor)
    if (random2 < 0.1) { // 10% chance
      goals += _random.nextInt(2); // 0 or 1 extra goal
    }
    
    return goals.clamp(0, 8); // Reasonable maximum of 8 goals per team
  }
}
