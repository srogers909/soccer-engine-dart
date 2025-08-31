import 'dart:async';
import 'dart:math';
import '../models/match.dart';
import '../models/team.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';
import '../models/enhanced_match.dart';
import '../models/tactical_match.dart' as tactical;

/// Event emitted during live match simulation
class MatchSimulationEvent {
  final Match currentMatch;
  final MatchEvent? newEvent;
  final String? commentary;
  final Map<String, dynamic> metadata;

  const MatchSimulationEvent({
    required this.currentMatch,
    this.newEvent,
    this.commentary,
    this.metadata = const {},
  });

  @override
  String toString() => 'MatchSimulationEvent(minute: ${currentMatch.currentMinute}, event: ${newEvent?.type})';
}

/// Controls for the streaming match simulation
class MatchSimulationControls {
  final StreamController<MatchSimulationCommand> _commandController = StreamController<MatchSimulationCommand>.broadcast();
  
  Stream<MatchSimulationCommand> get commands => _commandController.stream;
  
  void pause() => _commandController.add(MatchSimulationCommand.pause);
  void resume() => _commandController.add(MatchSimulationCommand.resume);
  void setSpeed(double speed) => _commandController.add(MatchSimulationCommand.setSpeed(speed));
  void jumpToMinute(int minute) => _commandController.add(MatchSimulationCommand.jumpToMinute(minute));
  void skipToEnd() => _commandController.add(MatchSimulationCommand.skipToEnd);
  void applyTacticalChange(String teamId, TeamTactics tactics) => 
      _commandController.add(MatchSimulationCommand.tacticalChange(teamId, tactics));
  
  // Tactical control methods
  void changeFormation(String teamId, tactical.Formation formation) =>
      _commandController.add(MatchSimulationCommand.changeFormation(teamId, formation));
  
  void setPlayerInstructions(String teamId, String playerId, tactical.PlayerInstructions instructions) =>
      _commandController.add(MatchSimulationCommand.setPlayerInstructions(teamId, playerId, instructions));
  
  void enableAutomaticTactics(String teamId, bool enabled) =>
      _commandController.add(MatchSimulationCommand.enableAutomaticTactics(teamId, enabled));
  
  void setMatchIntensity(String teamId, tactical.MatchIntensity intensity) =>
      _commandController.add(MatchSimulationCommand.setMatchIntensity(teamId, intensity));
  
  void dispose() {
    _commandController.close();
  }
}

/// Commands that can be sent to control the match simulation
sealed class MatchSimulationCommand {
  const MatchSimulationCommand();
  
  static const pause = _PauseCommand();
  static const resume = _ResumeCommand();
  static const skipToEnd = _SkipToEndCommand();
  
  static MatchSimulationCommand setSpeed(double speed) => _SetSpeedCommand(speed);
  static MatchSimulationCommand jumpToMinute(int minute) => _JumpToMinuteCommand(minute);
  static MatchSimulationCommand tacticalChange(String teamId, TeamTactics tactics) => 
      _TacticalChangeCommand(teamId, tactics);
  
  // Tactical commands
  static MatchSimulationCommand changeFormation(String teamId, tactical.Formation formation) =>
      _ChangeFormationCommand(teamId, formation);
  static MatchSimulationCommand setPlayerInstructions(String teamId, String playerId, tactical.PlayerInstructions instructions) =>
      _SetPlayerInstructionsCommand(teamId, playerId, instructions);
  static MatchSimulationCommand enableAutomaticTactics(String teamId, bool enabled) =>
      _EnableAutomaticTacticsCommand(teamId, enabled);
  static MatchSimulationCommand setMatchIntensity(String teamId, tactical.MatchIntensity intensity) =>
      _SetMatchIntensityCommand(teamId, intensity);
}

class _PauseCommand extends MatchSimulationCommand {
  const _PauseCommand();
}

class _ResumeCommand extends MatchSimulationCommand {
  const _ResumeCommand();
}

class _SetSpeedCommand extends MatchSimulationCommand {
  final double speed;
  const _SetSpeedCommand(this.speed);
}

class _JumpToMinuteCommand extends MatchSimulationCommand {
  final int minute;
  const _JumpToMinuteCommand(this.minute);
}

class _SkipToEndCommand extends MatchSimulationCommand {
  const _SkipToEndCommand();
}

class _TacticalChangeCommand extends MatchSimulationCommand {
  final String teamId;
  final TeamTactics tactics;
  const _TacticalChangeCommand(this.teamId, this.tactics);
}

class _ChangeFormationCommand extends MatchSimulationCommand {
  final String teamId;
  final tactical.Formation formation;
  const _ChangeFormationCommand(this.teamId, this.formation);
}

class _SetPlayerInstructionsCommand extends MatchSimulationCommand {
  final String teamId;
  final String playerId;
  final tactical.PlayerInstructions instructions;
  const _SetPlayerInstructionsCommand(this.teamId, this.playerId, this.instructions);
}

class _EnableAutomaticTacticsCommand extends MatchSimulationCommand {
  final String teamId;
  final bool enabled;
  const _EnableAutomaticTacticsCommand(this.teamId, this.enabled);
}

class _SetMatchIntensityCommand extends MatchSimulationCommand {
  final String teamId;
  final tactical.MatchIntensity intensity;
  const _SetMatchIntensityCommand(this.teamId, this.intensity);
}

/// Simulates soccer matches with real-time streaming events and interactive controls
class StreamingMatchSimulator {
  final Random _random;
  final StreamController<MatchSimulationEvent> _eventController = StreamController<MatchSimulationEvent>.broadcast();
  
  Timer? _timer;
  bool _isPaused = false;
  double _speed = 1.0; // 1.0 = real time, 2.0 = 2x speed, etc.
  Match? _currentMatch;
  MatchSimulationControls? _controls;
  
  // Enhanced match tracking
  MatchStats? _matchStats;
  Map<String, PlayerPerformance>? _playerPerformances;
  MomentumTracker? _momentumTracker;
  Map<String, TeamTactics> _teamTactics = {};
  
  /// Creates a new streaming match simulator
  StreamingMatchSimulator({int? seed}) : _random = Random(seed);

  /// Stream of match simulation events
  Stream<MatchSimulationEvent> get events => _eventController.stream;

  /// Starts streaming simulation of a match
  Future<MatchSimulationControls> startMatch(Match match) async {
    if (_currentMatch != null) {
      throw StateError('A match is already being simulated');
    }
    
    if (match.isCompleted) {
      throw ArgumentError('Cannot simulate an already completed match');
    }

    _currentMatch = match;
    _controls = MatchSimulationControls();
    
    // Initialize enhanced match tracking
    _initializeMatchTracking();
    
    // Initialize default tactics
    _teamTactics[match.homeTeam.id] = TeamTactics(
      mentality: TeamMentality.balanced,
      pressing: 50,
      tempo: 50,
      width: 50,
      directness: 50,
    );
    _teamTactics[match.awayTeam.id] = TeamTactics(
      mentality: TeamMentality.balanced,
      pressing: 50,
      tempo: 50,
      width: 50,
      directness: 50,
    );

    // Listen to control commands
    _controls!.commands.listen(_handleCommand);
    
    // Start the simulation
    await _startSimulation();
    
    return _controls!;
  }

  /// Initializes enhanced match tracking data
  void _initializeMatchTracking() {
    if (_currentMatch == null) return;
    
    _matchStats = MatchStats(
      homePossession: 50.0,
      awayPossession: 50.0,
      homeShots: 0,
      awayShots: 0,
      homeShotsOnTarget: 0,
      awayShotsOnTarget: 0,
      homePasses: 0,
      awayPasses: 0,
      homePassAccuracy: 75.0,
      awayPassAccuracy: 75.0,
      homeTackles: 0,
      awayTackles: 0,
      homeCorners: 0,
      awayCorners: 0,
      homeOffsides: 0,
      awayOffsides: 0,
      homeFouls: 0,
      awayFouls: 0,
    );

    _playerPerformances = {};
    for (final player in [..._currentMatch!.homeTeam.players, ..._currentMatch!.awayTeam.players]) {
      _playerPerformances![player.id] = PlayerPerformance(
        playerId: player.id,
        playerName: player.name,
        rating: 6.0,
        goals: 0,
        assists: 0,
        shots: 0,
        shotsOnTarget: 0,
        passes: 0,
        passAccuracy: 75.0,
        tackles: 0,
        fouls: 0,
        yellowCards: 0,
        redCards: 0,
        minutesPlayed: 0,
      );
    }

    _momentumTracker = MomentumTracker(
      homeMomentum: 50.0,
      awayMomentum: 50.0,
      lastShift: 0,
      shiftEvents: [],
    );
  }

  /// Starts the actual simulation process
  Future<void> _startSimulation() async {
    if (_currentMatch == null) return;
    
    // Emit kickoff event
    final kickoffEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.kickoff,
      minute: 0,
      teamId: _currentMatch!.homeTeam.id,
      description: 'Match kicks off',
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, kickoffEvent);
    _emitEvent(
      newEvent: kickoffEvent,
      commentary: 'The match is underway! ${_currentMatch!.homeTeam.name} vs ${_currentMatch!.awayTeam.name}',
    );

    // Start the main simulation loop
    _startSimulationLoop();
  }

  /// Main simulation loop that processes each minute
  void _startSimulationLoop() {
    const baseInterval = Duration(seconds: 1); // 1 second per minute at 1x speed
    
    _timer = Timer.periodic(baseInterval, (timer) {
      if (_isPaused || _currentMatch == null) return;
      
      // Adjust timer based on speed (this is a simplified approach)
      if (_speed != 1.0) {
        timer.cancel();
        final adjustedInterval = Duration(milliseconds: (1000 / _speed).round());
        _timer = Timer.periodic(adjustedInterval, (newTimer) {
          if (_isPaused || _currentMatch == null) return;
          _processMinute();
        });
        return;
      }
      
      _processMinute();
    });
  }

  /// Processes events for the current minute
  void _processMinute() {
    if (_currentMatch == null || _currentMatch!.isCompleted) return;
    
    final currentMinute = _currentMatch!.currentMinute + 1;
    
    // Check if match should end
    if (currentMinute > 90) {
      final stoppageTime = _random.nextInt(6); // 0-5 minutes
      if (currentMinute > 90 + stoppageTime) {
        _endMatch();
        return;
      }
    }
    
    // Update current minute
    _currentMatch = _currentMatch!.copyWith(currentMinute: currentMinute);
    
    // Update player minutes played
    _updatePlayerMinutes(currentMinute);
    
    // Simulate events for this minute
    _simulateMinuteEvents(currentMinute);
    
    // Emit minute update
    _emitEvent(commentary: _generateMinuteCommentary(currentMinute));
    
    // Add half-time event
    if (currentMinute == 45) {
      final halfTimeEvent = MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.halfTime,
        minute: currentMinute,
        teamId: _currentMatch!.homeTeam.id,
        description: 'Half time',
      );
      
      _currentMatch = _addEventToMatch(_currentMatch!, halfTimeEvent);
      _emitEvent(
        newEvent: halfTimeEvent,
        commentary: 'Half time! ${_currentMatch!.homeTeam.name} ${_currentMatch!.homeGoals} - ${_currentMatch!.awayGoals} ${_currentMatch!.awayTeam.name}',
      );
    }
  }

  /// Simulates events that can occur during a specific minute
  void _simulateMinuteEvents(int minute) {
    if (_currentMatch == null) return;
    
    // Calculate event probabilities based on tactics and match state
    final homeTactics = _teamTactics[_currentMatch!.homeTeam.id]!;
    final awayTactics = _teamTactics[_currentMatch!.awayTeam.id]!;
    
    // Get tactical modifiers
    final homeAttackingModifier = homeTactics.attackingModifier;
    final awayAttackingModifier = awayTactics.attackingModifier;
    
    // Base event probabilities (per minute)
    final baseGoalProbability = 0.018; // ~1.8% per minute
    final baseShotProbability = 0.08; // ~8% per minute
    final baseCardProbability = 0.01; // ~1% per minute
    final baseFoulProbability = 0.04; // ~4% per minute
    
    // Adjust probabilities based on match phase
    double intensityMultiplier = 1.0;
    if (minute <= 15 || minute >= 75) {
      intensityMultiplier = 1.3; // More intense at start and end
    } else if (minute >= 30 && minute <= 60) {
      intensityMultiplier = 0.8; // Calmer in middle
    }
    
    // Check for shots (which might become goals)
    final shotProbability = baseShotProbability * intensityMultiplier * 
        ((homeAttackingModifier + awayAttackingModifier) / 2);
    
    if (_random.nextDouble() < shotProbability) {
      _simulateShot(minute, homeAttackingModifier, awayAttackingModifier);
    }
    
    // Check for fouls
    if (_random.nextDouble() < baseFoulProbability * intensityMultiplier) {
      _simulateFoul(minute);
    }
    
    // Check for cards (separate from fouls)
    if (_random.nextDouble() < baseCardProbability * intensityMultiplier) {
      _simulateCard(minute);
    }
    
    // Check for other events
    if (_random.nextDouble() < 0.02) { // 2% chance for corner
      _simulateCorner(minute);
    }
    
    if (_random.nextDouble() < 0.005) { // 0.5% chance for injury
      _simulateInjury(minute);
    }
    
    // Check for momentum shifts
    if (_random.nextDouble() < 0.015) { // 1.5% chance
      _updateMomentum(minute);
    }
  }

  /// Simulates a shot event which might become a goal
  void _simulateShot(int minute, double homeAttackingModifier, double awayAttackingModifier) {
    if (_currentMatch == null) return;
    
    // Determine which team takes the shot based on attacking modifiers
    final totalAttacking = homeAttackingModifier + awayAttackingModifier;
    final homeShootProbability = homeAttackingModifier / totalAttacking;
    
    final isHomeShot = _random.nextDouble() < homeShootProbability;
    final shootingTeam = isHomeShot ? _currentMatch!.homeTeam : _currentMatch!.awayTeam;
    final shooter = _selectGoalScorer(shootingTeam);
    
    // Update shot statistics
    if (isHomeShot) {
      _matchStats!.homeShots++;
    } else {
      _matchStats!.awayShots++;
    }
    
    if (shooter != null) {
      final performance = _playerPerformances![shooter.id]!;
      _playerPerformances![shooter.id] = _updatePlayerPerformance(
        performance,
        shots: performance.shots + 1,
      );
    }
    
    // Determine if shot is on target
    final isOnTarget = _random.nextDouble() < 0.4; // 40% shots on target
    
    if (isOnTarget) {
      if (isHomeShot) {
        _matchStats!.homeShotsOnTarget++;
      } else {
        _matchStats!.awayShotsOnTarget++;
      }
      
      if (shooter != null) {
        final performance = _playerPerformances![shooter.id]!;
        _playerPerformances![shooter.id] = _updatePlayerPerformance(
          performance,
          shotsOnTarget: performance.shotsOnTarget + 1,
        );
      }
      
      // Check if it's a goal (30% of shots on target)
      if (_random.nextDouble() < 0.3) {
        _simulateGoal(minute, shootingTeam, shooter, isHomeShot);
        return;
      }
      
      // Shot on target but saved
      final shotEvent = MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.shotOnTarget,
        minute: minute,
        teamId: shootingTeam.id,
        description: 'Shot on target by ${shooter?.name ?? 'Unknown'}',
        playerId: shooter?.id,
        playerName: shooter?.name,
      );
      
      _currentMatch = _addEventToMatch(_currentMatch!, shotEvent);
      _emitEvent(
        newEvent: shotEvent,
        commentary: 'Great shot by ${shooter?.name ?? 'Unknown'} but it\'s saved by the goalkeeper!',
      );
    } else {
      // Shot off target
      final shotEvent = MatchEvent.create(
        id: _generateEventId(),
        type: MatchEventType.shotOffTarget,
        minute: minute,
        teamId: shootingTeam.id,
        description: 'Shot off target by ${shooter?.name ?? 'Unknown'}',
        playerId: shooter?.id,
        playerName: shooter?.name,
      );
      
      _currentMatch = _addEventToMatch(_currentMatch!, shotEvent);
      _emitEvent(
        newEvent: shotEvent,
        commentary: '${shooter?.name ?? 'Unknown'} shoots but it goes wide of the target.',
      );
    }
  }

  /// Simulates a goal event
  void _simulateGoal(int minute, Team scoringTeam, Player? scorer, bool isHomeGoal) {
    if (_currentMatch == null || scorer == null) return;
    
    // Update match score
    _currentMatch = _currentMatch!.copyWith(
      homeGoals: isHomeGoal ? _currentMatch!.homeGoals + 1 : _currentMatch!.homeGoals,
      awayGoals: isHomeGoal ? _currentMatch!.awayGoals : _currentMatch!.awayGoals + 1,
    );
    
    // Update player performance
    final performance = _playerPerformances![scorer.id]!;
    _playerPerformances![scorer.id] = _updatePlayerPerformance(
      performance,
      goals: performance.goals + 1,
      rating: performance.rating + 1.0, // Big rating boost for goal
    );
    
    // Create goal event
    final goalEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.goal,
      minute: minute,
      teamId: scoringTeam.id,
      description: 'Goal scored by ${scorer.name}',
      playerId: scorer.id,
      playerName: scorer.name,
      metadata: {
        'scoringTeam': isHomeGoal ? 'home' : 'away',
        'homeScore': _currentMatch!.homeGoals,
        'awayScore': _currentMatch!.awayGoals,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, goalEvent);
    
    // Update momentum significantly for goals
    final momentumShift = isHomeGoal ? 15.0 : -15.0;
    _momentumTracker!.homeMomentum = (_momentumTracker!.homeMomentum + momentumShift).clamp(0, 100);
    _momentumTracker!.awayMomentum = (_momentumTracker!.awayMomentum - momentumShift).clamp(0, 100);
    _momentumTracker!.lastShift = minute;
    _momentumTracker!.shiftEvents.add('Goal by ${scorer.name} at minute $minute');
    
    _emitEvent(
      newEvent: goalEvent,
      commentary: 'GOAL! ${scorer.name} finds the back of the net! ${_currentMatch!.homeTeam.name} ${_currentMatch!.homeGoals} - ${_currentMatch!.awayGoals} ${_currentMatch!.awayTeam.name}',
    );
  }

  /// Simulates a foul event
  void _simulateFoul(int minute) {
    if (_currentMatch == null) return;
    
    final isHomeFoul = _random.nextDouble() < 0.5;
    final foulingTeam = isHomeFoul ? _currentMatch!.homeTeam : _currentMatch!.awayTeam;
    final fouler = _selectRandomPlayer(foulingTeam);
    
    // Update statistics
    if (isHomeFoul) {
      _matchStats!.homeFouls++;
    } else {
      _matchStats!.awayFouls++;
    }
    
    if (fouler != null) {
      final performance = _playerPerformances![fouler.id]!;
      _playerPerformances![fouler.id] = _updatePlayerPerformance(
        performance,
        fouls: performance.fouls + 1,
        rating: performance.rating - 0.1, // Small rating penalty
      );
    }
    
    final foulEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.foul,
      minute: minute,
      teamId: foulingTeam.id,
      description: 'Foul by ${fouler?.name ?? 'Unknown'}',
      playerId: fouler?.id,
      playerName: fouler?.name,
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, foulEvent);
    _emitEvent(
      newEvent: foulEvent,
      commentary: 'Foul committed by ${fouler?.name ?? 'Unknown'}. Free kick awarded.',
    );
  }

  /// Simulates a card event
  void _simulateCard(int minute) {
    if (_currentMatch == null) return;
    
    final isHomeCard = _random.nextDouble() < 0.45; // Slightly favor away team for cards
    final cardedTeam = isHomeCard ? _currentMatch!.homeTeam : _currentMatch!.awayTeam;
    final cardedPlayer = _selectRandomPlayer(cardedTeam);
    
    // Determine card type (90% yellow, 10% red)
    final isRedCard = _random.nextDouble() < 0.1;
    final cardType = isRedCard ? MatchEventType.redCard : MatchEventType.yellowCard;
    
    if (cardedPlayer != null) {
      final performance = _playerPerformances![cardedPlayer.id]!;
      _playerPerformances![cardedPlayer.id] = _updatePlayerPerformance(
        performance,
        yellowCards: isRedCard ? performance.yellowCards : performance.yellowCards + 1,
        redCards: isRedCard ? performance.redCards + 1 : performance.redCards,
        rating: performance.rating - (isRedCard ? 1.0 : 0.3), // Bigger penalty for red
      );
    }
    
    final cardEvent = MatchEvent.create(
      id: _generateEventId(),
      type: cardType,
      minute: minute,
      teamId: cardedTeam.id,
      description: '${isRedCard ? 'Red' : 'Yellow'} card for ${cardedPlayer?.name ?? 'Unknown'}',
      playerId: cardedPlayer?.id,
      playerName: cardedPlayer?.name,
      metadata: {'cardType': isRedCard ? 'red' : 'yellow'},
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, cardEvent);
    _emitEvent(
      newEvent: cardEvent,
      commentary: '${isRedCard ? 'RED CARD!' : 'Yellow card'} ${cardedPlayer?.name ?? 'Unknown'} is ${isRedCard ? 'sent off' : 'booked'}!',
    );
  }

  /// Simulates a corner event
  void _simulateCorner(int minute) {
    if (_currentMatch == null) return;
    
    final isHomeCorner = _random.nextDouble() < 0.5;
    final team = isHomeCorner ? _currentMatch!.homeTeam : _currentMatch!.awayTeam;
    
    if (isHomeCorner) {
      _matchStats!.homeCorners++;
    } else {
      _matchStats!.awayCorners++;
    }
    
    final cornerEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.corner,
      minute: minute,
      teamId: team.id,
      description: 'Corner kick for ${team.name}',
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, cornerEvent);
    _emitEvent(
      newEvent: cornerEvent,
      commentary: 'Corner kick for ${team.name}. Good opportunity to create danger!',
    );
  }

  /// Simulates an injury event
  void _simulateInjury(int minute) {
    if (_currentMatch == null) return;
    
    final isHomeInjury = _random.nextDouble() < 0.5;
    final team = isHomeInjury ? _currentMatch!.homeTeam : _currentMatch!.awayTeam;
    final injuredPlayer = _selectRandomPlayer(team);
    
    if (injuredPlayer != null) {
      final performance = _playerPerformances![injuredPlayer.id]!;
      _playerPerformances![injuredPlayer.id] = _updatePlayerPerformance(
        performance,
        rating: performance.rating - 0.5, // Rating penalty for injury
      );
    }
    
    final injuryEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.injury,
      minute: minute,
      teamId: team.id,
      description: 'Injury to ${injuredPlayer?.name ?? 'Unknown'}',
      playerId: injuredPlayer?.id,
      playerName: injuredPlayer?.name,
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, injuryEvent);
    _emitEvent(
      newEvent: injuryEvent,
      commentary: '${injuredPlayer?.name ?? 'Unknown'} is down injured. The medical team is attending to the player.',
    );
  }

  /// Updates momentum tracker
  void _updateMomentum(int minute) {
    if (_momentumTracker == null) return;
    
    final shift = (_random.nextDouble() - 0.5) * 15; // -7.5 to +7.5 momentum shift
    _momentumTracker!.homeMomentum = (_momentumTracker!.homeMomentum + shift).clamp(0, 100);
    _momentumTracker!.awayMomentum = (_momentumTracker!.awayMomentum - shift).clamp(0, 100);
    _momentumTracker!.lastShift = minute;
    _momentumTracker!.shiftEvents.add('Momentum shift at minute $minute');
    
    final momentumEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.momentumShift,
      minute: minute,
      teamId: _momentumTracker!.homeMomentum > _momentumTracker!.awayMomentum 
          ? _currentMatch!.homeTeam.id 
          : _currentMatch!.awayTeam.id,
      description: 'Momentum shift',
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, momentumEvent);
    _emitEvent(
      newEvent: momentumEvent,
      commentary: 'The momentum is shifting! ${_momentumTracker!.homeMomentum > _momentumTracker!.awayMomentum ? _currentMatch!.homeTeam.name : _currentMatch!.awayTeam.name} are taking control.',
    );
  }

  /// Ends the match
  void _endMatch() {
    if (_currentMatch == null) return;
    
    // Determine final result
    MatchResult result;
    if (_currentMatch!.homeGoals > _currentMatch!.awayGoals) {
      result = MatchResult.homeWin;
    } else if (_currentMatch!.homeGoals < _currentMatch!.awayGoals) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }
    
    // Create full time event
    final fullTimeEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.fullTime,
      minute: _currentMatch!.currentMinute,
      teamId: _currentMatch!.homeTeam.id,
      description: 'Full time',
    );
    
    // Complete the match
    _currentMatch = _addEventToMatch(_currentMatch!, fullTimeEvent);
    _currentMatch = _currentMatch!.copyWith(
      isCompleted: true,
      result: result,
      matchStats: _matchStats,
      playerPerformances: _playerPerformances,
      momentumTracker: _momentumTracker,
    );
    
    _emitEvent(
      newEvent: fullTimeEvent,
      commentary: 'FULL TIME! ${_currentMatch!.homeTeam.name} ${_currentMatch!.homeGoals} - ${_currentMatch!.awayGoals} ${_currentMatch!.awayTeam.name}. What a match!',
    );
    
    // Clean up
    _timer?.cancel();
    _timer = null;
  }

  /// Handles control commands
  void _handleCommand(MatchSimulationCommand command) {
    switch (command) {
      case _PauseCommand():
        _isPaused = true;
      case _ResumeCommand():
        _isPaused = false;
      case _SetSpeedCommand(:final speed):
        _speed = speed.clamp(0.25, 8.0); // Limit speed between 0.25x and 8x
        _restartSimulationLoop();
      case _JumpToMinuteCommand(:final minute):
        _jumpToMinute(minute);
      case _SkipToEndCommand():
        _skipToEnd();
      case _TacticalChangeCommand(:final teamId, :final tactics):
        _applyTacticalChange(teamId, tactics);
      case _ChangeFormationCommand(:final teamId, :final formation):
        _changeFormation(teamId, formation);
      case _SetPlayerInstructionsCommand(:final teamId, :final playerId, :final instructions):
        _setPlayerInstructions(teamId, playerId, instructions);
      case _EnableAutomaticTacticsCommand(:final teamId, :final enabled):
        _enableAutomaticTactics(teamId, enabled);
      case _SetMatchIntensityCommand(:final teamId, :final intensity):
        _setMatchIntensity(teamId, intensity);
    }
  }
  
  /// Changes formation for a team during the match
  void _changeFormation(String teamId, tactical.Formation formation) {
    if (_currentMatch == null) return;
    
    final team = teamId == _currentMatch!.homeTeam.id 
        ? _currentMatch!.homeTeam 
        : _currentMatch!.awayTeam;
    
    final formationEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.tacticalChange,
      minute: _currentMatch!.currentMinute,
      teamId: teamId,
      description: 'Formation change to ${formation.name}',
      metadata: {
        'changeType': 'formation',
        'formation': formation.name,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, formationEvent);
    _emitEvent(
      newEvent: formationEvent,
      commentary: '${team.name} change their formation to ${formation.name}!',
    );
  }
  
  /// Sets player instructions for a specific player
  void _setPlayerInstructions(String teamId, String playerId, tactical.PlayerInstructions instructions) {
    if (_currentMatch == null) return;
    
    final team = teamId == _currentMatch!.homeTeam.id 
        ? _currentMatch!.homeTeam 
        : _currentMatch!.awayTeam;
    
    final player = team.players.firstWhere((p) => p.id == playerId, orElse: () => throw ArgumentError('Player not found'));
    
    final instructionsEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.tacticalChange,
      minute: _currentMatch!.currentMinute,
      teamId: teamId,
      description: 'Player instructions updated for ${player.name}',
      playerId: playerId,
      playerName: player.name,
      metadata: {
        'changeType': 'playerInstructions',
        'role': instructions.role.name,
        'mentality': instructions.mentality.name,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, instructionsEvent);
    _emitEvent(
      newEvent: instructionsEvent,
      commentary: '${player.name} receives new tactical instructions from the bench.',
    );
  }
  
  /// Enables or disables automatic tactics for a team
  void _enableAutomaticTactics(String teamId, bool enabled) {
    if (_currentMatch == null) return;
    
    final team = teamId == _currentMatch!.homeTeam.id 
        ? _currentMatch!.homeTeam 
        : _currentMatch!.awayTeam;
    
    final autoTacticsEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.tacticalChange,
      minute: _currentMatch!.currentMinute,
      teamId: teamId,
      description: 'Automatic tactics ${enabled ? 'enabled' : 'disabled'}',
      metadata: {
        'changeType': 'automaticTactics',
        'enabled': enabled,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, autoTacticsEvent);
    _emitEvent(
      newEvent: autoTacticsEvent,
      commentary: '${team.name} ${enabled ? 'enable' : 'disable'} automatic tactical adjustments.',
    );
  }
  
  /// Sets match intensity for a team
  void _setMatchIntensity(String teamId, tactical.MatchIntensity intensity) {
    if (_currentMatch == null) return;
    
    final team = teamId == _currentMatch!.homeTeam.id 
        ? _currentMatch!.homeTeam 
        : _currentMatch!.awayTeam;
    
    final intensityEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.tacticalChange,
      minute: _currentMatch!.currentMinute,
      teamId: teamId,
      description: 'Match intensity set to ${intensity.name}',
      metadata: {
        'changeType': 'matchIntensity',
        'intensity': intensity.name,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, intensityEvent);
    _emitEvent(
      newEvent: intensityEvent,
      commentary: '${team.name} adjust their match intensity to ${intensity.name}.',
    );
  }

  /// Jumps simulation to a specific minute
  void _jumpToMinute(int targetMinute) {
    if (_currentMatch == null || targetMinute < 0 || targetMinute > 120) return;
    
    if (targetMinute < _currentMatch!.currentMinute) {
      // Cannot go backwards in live simulation
      return;
    }
    
    // Fast-forward to target minute
    while (_currentMatch!.currentMinute < targetMinute && !_currentMatch!.isCompleted) {
      _processMinute();
    }
  }

  /// Skips to the end of the match
  void _skipToEnd() {
    if (_currentMatch == null) return;
    
    // Fast-forward to end
    while (!_currentMatch!.isCompleted) {
      _processMinute();
    }
  }

  /// Applies a tactical change during the match
  void _applyTacticalChange(String teamId, TeamTactics tactics) {
    if (_currentMatch == null) return;
    
    _teamTactics[teamId] = tactics;
    
    final team = teamId == _currentMatch!.homeTeam.id 
        ? _currentMatch!.homeTeam 
        : _currentMatch!.awayTeam;
    
    final tacticalEvent = MatchEvent.create(
      id: _generateEventId(),
      type: MatchEventType.tacticalChange,
      minute: _currentMatch!.currentMinute,
      teamId: teamId,
      description: 'Tactical change: ${tactics.mentality.name}',
      metadata: {
        'mentality': tactics.mentality.name,
        'pressing': tactics.pressing,
        'tempo': tactics.tempo,
      },
    );
    
    _currentMatch = _addEventToMatch(_currentMatch!, tacticalEvent);
    _emitEvent(
      newEvent: tacticalEvent,
      commentary: '${team.name} make a tactical adjustment. They\'re now playing with a ${tactics.mentality.name} mentality.',
    );
  }

  /// Restarts the simulation loop with current speed
  void _restartSimulationLoop() {
    _timer?.cancel();
    if (!_isPaused && _currentMatch != null && !_currentMatch!.isCompleted) {
      _startSimulationLoop();
    }
  }

  /// Updates player minutes played
  void _updatePlayerMinutes(int minute) {
    if (_playerPerformances == null) return;
    
    for (final playerId in _playerPerformances!.keys) {
      final performance = _playerPerformances![playerId]!;
      _playerPerformances![playerId] = _updatePlayerPerformance(
        performance,
        minutesPlayed: minute,
      );
    }
  }

  /// Generates commentary for minute updates
  String _generateMinuteCommentary(int minute) {
    if (_currentMatch == null) return '';
    
    final phrases = [
      'The action continues...',
      'Both teams looking for an opening...',
      'Intense battle in midfield...',
      'The pace is picking up...',
      'Players working hard on both sides...',
    ];
    
    if (minute == 45) {
      return 'We\'re approaching half time...';
    } else if (minute > 85) {
      return 'The clock is ticking down...';
    } else if (minute % 10 == 0) {
      return '${minute} minutes played. ${_currentMatch!.homeTeam.name} ${_currentMatch!.homeGoals} - ${_currentMatch!.awayGoals} ${_currentMatch!.awayTeam.name}';
    }
    
    return phrases[_random.nextInt(phrases.length)];
  }

  /// Helper method to emit events
  void _emitEvent({MatchEvent? newEvent, String? commentary, Map<String, dynamic> metadata = const {}}) {
    if (_currentMatch == null) return;
    
    final event = MatchSimulationEvent(
      currentMatch: _currentMatch!.copyWith(
        matchStats: _matchStats,
        playerPerformances: _playerPerformances,
        momentumTracker: _momentumTracker,
      ),
      newEvent: newEvent,
      commentary: commentary,
      metadata: metadata,
    );
    
    _eventController.add(event);
  }

  /// Helper method to add event to match
  Match _addEventToMatch(Match match, MatchEvent event) {
    final newEvents = [...match.events, event];
    return match.copyWith(events: newEvents);
  }

  /// Helper method to update player performance
  PlayerPerformance _updatePlayerPerformance(
    PlayerPerformance performance, {
    int? goals,
    int? assists,
    int? shots,
    int? shotsOnTarget,
    int? passes,
    double? passAccuracy,
    int? tackles,
    int? fouls,
    int? yellowCards,
    int? redCards,
    int? minutesPlayed,
    double? rating,
  }) {
    return PlayerPerformance(
      playerId: performance.playerId,
      playerName: performance.playerName,
      rating: rating ?? performance.rating,
      goals: goals ?? performance.goals,
      assists: assists ?? performance.assists,
      shots: shots ?? performance.shots,
      shotsOnTarget: shotsOnTarget ?? performance.shotsOnTarget,
      passes: passes ?? performance.passes,
      passAccuracy: passAccuracy ?? performance.passAccuracy,
      tackles: tackles ?? performance.tackles,
      fouls: fouls ?? performance.fouls,
      yellowCards: yellowCards ?? performance.yellowCards,
      redCards: redCards ?? performance.redCards,
      minutesPlayed: minutesPlayed ?? performance.minutesPlayed,
    );
  }

  /// Selects a goal scorer, preferring forwards and midfielders
  Player? _selectGoalScorer(Team team) {
    if (team.players.isEmpty) return null;
    
    final forwards = team.players.where((p) => p.position == PlayerPosition.forward).toList();
    final midfielders = team.players.where((p) => p.position == PlayerPosition.midfielder).toList();
    final others = team.players.where((p) => 
        p.position != PlayerPosition.forward && 
        p.position != PlayerPosition.midfielder &&
        p.position != PlayerPosition.goalkeeper).toList();
    
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

  /// Generates a unique event ID
  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  /// Stops the current simulation and cleans up resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _currentMatch = null;
    _controls?.dispose();
    _controls = null;
    _eventController.close();
  }
}
