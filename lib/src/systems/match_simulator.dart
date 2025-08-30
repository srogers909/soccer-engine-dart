import 'dart:math';
import '../models/match.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/enhanced_match.dart';

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

  /// Simulates a detailed Football Manager-style match with comprehensive statistics
  Match simulateDetailedMatch(Match match) {
    if (match.isCompleted) {
      throw ArgumentError('Cannot simulate an already completed match');
    }

    var currentMatch = match;
    
    // Initialize enhanced match tracking
    final matchStats = MatchStats(
      homePossession: 50.0,
      awayPossession: 50.0,
      homeShots: 0,
      awayShots: 0,
      homeShotsOnTarget: 0,
      awayShotsOnTarget: 0,
      homePasses: 0,
      awayPasses: 0,
      homePassAccuracy: 0.0,
      awayPassAccuracy: 0.0,
      homeTackles: 0,
      awayTackles: 0,
      homeCorners: 0,
      awayCorners: 0,
      homeOffsides: 0,
      awayOffsides: 0,
      homeFouls: 0,
      awayFouls: 0,
    );

    final playerPerformances = <String, PlayerPerformance>{};
    for (final player in [...match.homeTeam.players, ...match.awayTeam.players]) {
      playerPerformances[player.id] = PlayerPerformance(
        playerId: player.id,
        playerName: player.name,
        rating: 6.0,
        goals: 0,
        assists: 0,
        shots: 0,
        shotsOnTarget: 0,
        passes: 0,
        passAccuracy: 0.0,
        tackles: 0,
        fouls: 0,
        yellowCards: 0,
        redCards: 0,
        minutesPlayed: 0,
      );
    }

    final momentumTracker = MomentumTracker(
      homeMomentum: 50.0,
      awayMomentum: 50.0,
      lastShift: 0,
      shiftEvents: [],
    );

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

    // Simulate detailed first half
    currentMatch = _simulateDetailedHalf(currentMatch, 1, matchStats, playerPerformances, momentumTracker);
    
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

    // Simulate detailed second half
    currentMatch = _simulateDetailedHalf(currentMatch, 2, matchStats, playerPerformances, momentumTracker);

    // Add full time event and complete the match
    final finalMinute = 90 + _random.nextInt(6);
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
      matchStats: matchStats,
      playerPerformances: playerPerformances,
      momentumTracker: momentumTracker,
    );
  }

  /// Simulates a detailed match with tactical changes
  Match simulateDetailedMatchWithTacticalChanges(
    Match match,
    Map<int, TeamTactics> homeTacticalChanges,
    Map<int, TeamTactics> awayTacticalChanges,
  ) {
    if (match.isCompleted) {
      throw ArgumentError('Cannot simulate an already completed match');
    }

    var currentMatch = match;
    var currentHomeTactics = TeamTactics(
      mentality: TeamMentality.balanced,
      pressing: 50,
      tempo: 50,
      width: 50,
      directness: 50,
    );
    var currentAwayTactics = TeamTactics(
      mentality: TeamMentality.balanced,
      pressing: 50,
      tempo: 50,
      width: 50,
      directness: 50,
    );
    
    // Initialize enhanced match tracking
    final matchStats = MatchStats(
      homePossession: 50.0,
      awayPossession: 50.0,
      homeShots: 0,
      awayShots: 0,
      homeShotsOnTarget: 0,
      awayShotsOnTarget: 0,
      homePasses: 0,
      awayPasses: 0,
      homePassAccuracy: 0.0,
      awayPassAccuracy: 0.0,
      homeTackles: 0,
      awayTackles: 0,
      homeCorners: 0,
      awayCorners: 0,
      homeOffsides: 0,
      awayOffsides: 0,
      homeFouls: 0,
      awayFouls: 0,
    );

    final playerPerformances = <String, PlayerPerformance>{};
    for (final player in [...match.homeTeam.players, ...match.awayTeam.players]) {
      playerPerformances[player.id] = PlayerPerformance(
        playerId: player.id,
        playerName: player.name,
        rating: 6.0,
        goals: 0,
        assists: 0,
        shots: 0,
        shotsOnTarget: 0,
        passes: 0,
        passAccuracy: 0.0,
        tackles: 0,
        fouls: 0,
        yellowCards: 0,
        redCards: 0,
        minutesPlayed: 0,
      );
    }

    final momentumTracker = MomentumTracker(
      homeMomentum: 50.0,
      awayMomentum: 50.0,
      lastShift: 0,
      shiftEvents: [],
    );

    // Simulate match with tactical changes
    for (int minute = 0; minute <= 90; minute++) {
      // Check for tactical changes
      if (homeTacticalChanges.containsKey(minute)) {
        currentHomeTactics = homeTacticalChanges[minute]!;
        currentMatch = _addEvent(
          currentMatch,
          MatchEvent.create(
            id: _generateEventId(),
            type: MatchEventType.tacticalChange,
            minute: minute,
            teamId: match.homeTeam.id,
            description: 'Tactical change: ${currentHomeTactics.mentality.name}',
          ),
        );
      }
      
      if (awayTacticalChanges.containsKey(minute)) {
        currentAwayTactics = awayTacticalChanges[minute]!;
        currentMatch = _addEvent(
          currentMatch,
          MatchEvent.create(
            id: _generateEventId(),
            type: MatchEventType.tacticalChange,
            minute: minute,
            teamId: match.awayTeam.id,
            description: 'Tactical change: ${currentAwayTactics.mentality.name}',
          ),
        );
      }

      // Simulate events for this minute with tactical influence
      currentMatch = _simulateMinuteWithTactics(
        currentMatch,
        minute,
        currentHomeTactics,
        currentAwayTactics,
        matchStats,
        playerPerformances,
        momentumTracker,
      );
    }

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
      currentMinute: 90,
      matchStats: matchStats,
      playerPerformances: playerPerformances,
      momentumTracker: momentumTracker,
    );
  }

  /// Simulates a detailed half with enhanced events and statistics
  Match _simulateDetailedHalf(
    Match match,
    int half,
    MatchStats matchStats,
    Map<String, PlayerPerformance> playerPerformances,
    MomentumTracker momentumTracker,
  ) {
    var currentMatch = match;
    final startMinute = half == 1 ? 1 : 46;
    final endMinute = half == 1 ? 45 : 90;
    
    for (int minute = startMinute; minute <= endMinute; minute++) {
      currentMatch = currentMatch.copyWith(currentMinute: minute);
      
      // Simulate various events with higher frequency for detailed simulation
      if (_random.nextDouble() < 0.05) { // 5% chance for shot
        currentMatch = _simulateShot(currentMatch, minute, matchStats, playerPerformances);
      }
      
      if (_random.nextDouble() < 0.03) { // 3% chance for tackle
        currentMatch = _simulateTackle(currentMatch, minute, matchStats, playerPerformances);
      }
      
      if (_random.nextDouble() < 0.02) { // 2% chance for foul
        currentMatch = _simulateFoul(currentMatch, minute, matchStats, playerPerformances);
      }
      
      if (_random.nextDouble() < 0.01) { // 1% chance for corner
        currentMatch = _simulateCorner(currentMatch, minute, matchStats);
      }
      
      if (_random.nextDouble() < 0.005) { // 0.5% chance for injury
        currentMatch = _simulateInjury(currentMatch, minute, playerPerformances);
      }
      
      // Check for momentum shifts
      if (_random.nextDouble() < 0.02) { // 2% chance for momentum shift
        _updateMomentum(momentumTracker, minute);
        currentMatch = _addEvent(
          currentMatch,
          MatchEvent.create(
            id: _generateEventId(),
            type: MatchEventType.momentumShift,
            minute: minute,
            teamId: momentumTracker.homeMomentum > momentumTracker.awayMomentum ? match.homeTeam.id : match.awayTeam.id,
            description: 'Momentum shift',
          ),
        );
      }
    }

    return currentMatch;
  }

  /// Simulates a minute with tactical considerations
  Match _simulateMinuteWithTactics(
    Match match,
    int minute,
    TeamTactics homeTactics,
    TeamTactics awayTactics,
    MatchStats matchStats,
    Map<String, PlayerPerformance> playerPerformances,
    MomentumTracker momentumTracker,
  ) {
    var currentMatch = match;
    
    // Tactical influence on event probabilities
    final homeAttackingBonus = _getTacticalAttackingBonus(homeTactics);
    final awayAttackingBonus = _getTacticalAttackingBonus(awayTactics);
    
    // Simulate events with tactical modifiers
    final shotProbability = 0.05 * ((homeAttackingBonus + awayAttackingBonus) / 2);
    if (_random.nextDouble() < shotProbability) {
      currentMatch = _simulateShot(currentMatch, minute, matchStats, playerPerformances);
    }
    
    final tackleProbability = 0.03 * ((homeTactics.pressing + awayTactics.pressing) / 100);
    if (_random.nextDouble() < tackleProbability) {
      currentMatch = _simulateTackle(currentMatch, minute, matchStats, playerPerformances);
    }
    
    return currentMatch;
  }

  /// Gets tactical attacking bonus from team tactics
  double _getTacticalAttackingBonus(TeamTactics tactics) {
    switch (tactics.mentality) {
      case TeamMentality.veryAttacking:
        return 1.4;
      case TeamMentality.attacking:
        return 1.2;
      case TeamMentality.balanced:
        return 1.0;
      case TeamMentality.defensive:
        return 0.8;
      case TeamMentality.veryDefensive:
        return 0.6;
    }
  }

  /// Simulates a shot event
  Match _simulateShot(
    Match match,
    int minute,
    MatchStats matchStats,
    Map<String, PlayerPerformance> playerPerformances,
  ) {
    final isHomeShot = _random.nextDouble() < 0.5;
    final team = isHomeShot ? match.homeTeam : match.awayTeam;
    final shooter = _selectGoalScorer(team);
    
    // Update statistics
    if (isHomeShot) {
      matchStats.homeShots++;
    } else {
      matchStats.awayShots++;
    }
    
    if (shooter != null) {
      final performance = playerPerformances[shooter.id]!;
      playerPerformances[shooter.id] = PlayerPerformance(
        playerId: performance.playerId,
        playerName: performance.playerName,
        rating: performance.rating,
        goals: performance.goals,
        assists: performance.assists,
        shots: performance.shots + 1,
        shotsOnTarget: performance.shotsOnTarget,
        passes: performance.passes,
        passAccuracy: performance.passAccuracy,
        tackles: performance.tackles,
        fouls: performance.fouls,
        yellowCards: performance.yellowCards,
        redCards: performance.redCards,
        minutesPlayed: performance.minutesPlayed,
      );
    }
    
    final isOnTarget = _random.nextDouble() < 0.4; // 40% shots on target
    final eventType = isOnTarget ? MatchEventType.shotOnTarget : MatchEventType.shotOffTarget;
    
    if (isOnTarget) {
      if (isHomeShot) {
        matchStats.homeShotsOnTarget++;
      } else {
        matchStats.awayShotsOnTarget++;
      }
      
      if (shooter != null) {
        final performance = playerPerformances[shooter.id]!;
        playerPerformances[shooter.id] = PlayerPerformance(
          playerId: performance.playerId,
          playerName: performance.playerName,
          rating: performance.rating,
          goals: performance.goals,
          assists: performance.assists,
          shots: performance.shots,
          shotsOnTarget: performance.shotsOnTarget + 1,
          passes: performance.passes,
          passAccuracy: performance.passAccuracy,
          tackles: performance.tackles,
          fouls: performance.fouls,
          yellowCards: performance.yellowCards,
          redCards: performance.redCards,
          minutesPlayed: performance.minutesPlayed,
        );
      }
      
      // Check if it's a goal
      if (_random.nextDouble() < 0.3) { // 30% of shots on target are goals
        // Create goal event directly with proper statistics tracking
        var updatedMatch = match;
        
        if (isHomeShot) {
          updatedMatch = updatedMatch.copyWith(homeGoals: match.homeGoals + 1);
        } else {
          updatedMatch = updatedMatch.copyWith(awayGoals: match.awayGoals + 1);
        }
        
        if (shooter != null) {
          final performance = playerPerformances[shooter.id]!;
          playerPerformances[shooter.id] = PlayerPerformance(
            playerId: performance.playerId,
            playerName: performance.playerName,
            rating: performance.rating + 1.0, // Big rating boost for goal
            goals: performance.goals + 1,
            assists: performance.assists,
            shots: performance.shots,
            shotsOnTarget: performance.shotsOnTarget,
            passes: performance.passes,
            passAccuracy: performance.passAccuracy,
            tackles: performance.tackles,
            fouls: performance.fouls,
            yellowCards: performance.yellowCards,
            redCards: performance.redCards,
            minutesPlayed: performance.minutesPlayed,
          );
        }
        
        return _addEvent(
          updatedMatch,
          MatchEvent.create(
            id: _generateEventId(),
            type: MatchEventType.goal,
            minute: minute,
            teamId: team.id,
            description: 'Goal scored by ${shooter?.name ?? 'Unknown Player'}',
            playerId: shooter?.id,
            playerName: shooter?.name,
            metadata: {
              'scoringTeam': isHomeShot ? 'home' : 'away',
              'homeScore': updatedMatch.homeGoals,
              'awayScore': updatedMatch.awayGoals,
            },
          ),
        );
      }
    }
    
    return _addEvent(
      match,
      MatchEvent.create(
        id: _generateEventId(),
        type: eventType,
        minute: minute,
        teamId: team.id,
        description: isOnTarget ? 'Shot on target by ${shooter?.name ?? 'Unknown'}' : 'Shot off target by ${shooter?.name ?? 'Unknown'}',
        playerId: shooter?.id,
        playerName: shooter?.name,
      ),
    );
  }

  /// Simulates a tackle event
  Match _simulateTackle(
    Match match,
    int minute,
    MatchStats matchStats,
    Map<String, PlayerPerformance> playerPerformances,
  ) {
    final isHomeTackle = _random.nextDouble() < 0.5;
    final team = isHomeTackle ? match.homeTeam : match.awayTeam;
    final tackler = _selectRandomPlayer(team);
    
    // Update statistics
    if (isHomeTackle) {
      matchStats.homeTackles++;
    } else {
      matchStats.awayTackles++;
    }
    
    if (tackler != null) {
      final performance = playerPerformances[tackler.id]!;
      playerPerformances[tackler.id] = PlayerPerformance(
        playerId: performance.playerId,
        playerName: performance.playerName,
        rating: performance.rating + 0.1, // Small rating boost for tackles
        goals: performance.goals,
        assists: performance.assists,
        shots: performance.shots,
        shotsOnTarget: performance.shotsOnTarget,
        passes: performance.passes,
        passAccuracy: performance.passAccuracy,
        tackles: performance.tackles + 1,
        fouls: performance.fouls,
        yellowCards: performance.yellowCards,
        redCards: performance.redCards,
        minutesPlayed: performance.minutesPlayed,
      );
    }
    
    return _addEvent(
      match,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.tackle,
        minute: minute,
        teamId: team.id,
        description: 'Tackle by ${tackler?.name ?? 'Unknown Player'}',
        playerId: tackler?.id,
        playerName: tackler?.name,
      ),
    );
  }

  /// Simulates a foul event
  Match _simulateFoul(
    Match match,
    int minute,
    MatchStats matchStats,
    Map<String, PlayerPerformance> playerPerformances,
  ) {
    final isHomeFoul = _random.nextDouble() < 0.5;
    final team = isHomeFoul ? match.homeTeam : match.awayTeam;
    final fouler = _selectRandomPlayer(team);
    
    // Update statistics
    if (isHomeFoul) {
      matchStats.homeFouls++;
    } else {
      matchStats.awayFouls++;
    }
    
    if (fouler != null) {
      final performance = playerPerformances[fouler.id]!;
      playerPerformances[fouler.id] = PlayerPerformance(
        playerId: performance.playerId,
        playerName: performance.playerName,
        rating: performance.rating - 0.1, // Small rating penalty for fouls
        goals: performance.goals,
        assists: performance.assists,
        shots: performance.shots,
        shotsOnTarget: performance.shotsOnTarget,
        passes: performance.passes,
        passAccuracy: performance.passAccuracy,
        tackles: performance.tackles,
        fouls: performance.fouls + 1,
        yellowCards: performance.yellowCards,
        redCards: performance.redCards,
        minutesPlayed: performance.minutesPlayed,
      );
    }
    
    return _addEvent(
      match,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.foul,
        minute: minute,
        teamId: team.id,
        description: 'Foul by ${fouler?.name ?? 'Unknown Player'}',
        playerId: fouler?.id,
        playerName: fouler?.name,
      ),
    );
  }

  /// Simulates a corner event
  Match _simulateCorner(Match match, int minute, MatchStats matchStats) {
    final isHomeCorner = _random.nextDouble() < 0.5;
    final team = isHomeCorner ? match.homeTeam : match.awayTeam;
    
    // Update statistics
    if (isHomeCorner) {
      matchStats.homeCorners++;
    } else {
      matchStats.awayCorners++;
    }
    
    return _addEvent(
      match,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.corner,
        minute: minute,
        teamId: team.id,
        description: 'Corner kick for ${team.name}',
      ),
    );
  }

  /// Simulates an injury event
  Match _simulateInjury(
    Match match,
    int minute,
    Map<String, PlayerPerformance> playerPerformances,
  ) {
    final isHomeInjury = _random.nextDouble() < 0.5;
    final team = isHomeInjury ? match.homeTeam : match.awayTeam;
    final injuredPlayer = _selectRandomPlayer(team);
    
    if (injuredPlayer != null) {
      final performance = playerPerformances[injuredPlayer.id]!;
      playerPerformances[injuredPlayer.id] = PlayerPerformance(
        playerId: performance.playerId,
        playerName: performance.playerName,
        rating: performance.rating - 0.5, // Rating penalty for injury
        goals: performance.goals,
        assists: performance.assists,
        shots: performance.shots,
        shotsOnTarget: performance.shotsOnTarget,
        passes: performance.passes,
        passAccuracy: performance.passAccuracy,
        tackles: performance.tackles,
        fouls: performance.fouls,
        yellowCards: performance.yellowCards,
        redCards: performance.redCards,
        minutesPlayed: performance.minutesPlayed,
      );
    }
    
    return _addEvent(
      match,
      MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.injury,
        minute: minute,
        teamId: team.id,
        description: 'Injury to ${injuredPlayer?.name ?? 'Unknown Player'}',
        playerId: injuredPlayer?.id,
        playerName: injuredPlayer?.name,
      ),
    );
  }

  /// Updates momentum tracker
  void _updateMomentum(MomentumTracker tracker, int minute) {
    final shift = (_random.nextDouble() - 0.5) * 20; // -10 to +10 momentum shift
    tracker.homeMomentum = (tracker.homeMomentum + shift).clamp(0, 100);
    tracker.awayMomentum = (tracker.awayMomentum - shift).clamp(0, 100);
    tracker.lastShift = minute;
    tracker.shiftEvents.add('Minute $minute: Momentum shift');
  }
}
