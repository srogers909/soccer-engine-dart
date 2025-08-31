import 'dart:async';
import '../models/match.dart';
import '../models/match_state.dart';
import '../models/enhanced_match.dart';
import 'streaming_match_simulator.dart';
import 'match_commentary_engine.dart';

/// Manages match state, checkpoints, and persistence for streaming matches
class MatchStateManager {
  final MatchCommentaryEngine _commentaryEngine;
  final CheckpointConfig _checkpointConfig;
  
  // State management
  MatchState? _currentState;
  final List<MatchCheckpoint> _checkpoints = [];
  final StreamController<MatchState> _stateController = StreamController<MatchState>.broadcast();
  final StreamController<MatchCheckpoint> _checkpointController = StreamController<MatchCheckpoint>.broadcast();
  
  // Simulator integration
  StreamingMatchSimulator? _simulator;
  StreamSubscription<MatchSimulationEvent>? _simulatorSubscription;

  /// Creates a new match state manager
  MatchStateManager({
    MatchCommentaryEngine? commentaryEngine,
    CheckpointConfig checkpointConfig = CheckpointConfig.defaultConfig,
  }) : _commentaryEngine = commentaryEngine ?? MatchCommentaryEngine(),
        _checkpointConfig = checkpointConfig;

  /// Stream of match state updates
  Stream<MatchState> get stateUpdates => _stateController.stream;

  /// Stream of checkpoint creation events
  Stream<MatchCheckpoint> get checkpointUpdates => _checkpointController.stream;

  /// Current match state (null if no match is active)
  MatchState? get currentState => _currentState;

  /// List of available checkpoints for the current match
  List<MatchCheckpoint> get checkpoints => List.unmodifiable(_checkpoints);

  /// Starts managing a match with the streaming simulator
  Future<void> startMatch(Match match, StreamingMatchSimulator simulator) async {
    if (_currentState != null) {
      throw StateError('A match is already being managed');
    }

    _simulator = simulator;
    _currentState = MatchState.fromMatch(match);
    
    // Create initial checkpoint
    await _createCheckpoint('Match Start', 'Match kicked off');
    
    // Listen to simulator events
    _simulatorSubscription = simulator.events.listen(_handleSimulatorEvent);
    
    // Emit initial state
    _emitStateUpdate();
  }

  /// Loads a match from a checkpoint
  Future<void> loadFromCheckpoint(MatchCheckpoint checkpoint) async {
    if (_simulator == null) {
      throw StateError('No active simulator to load checkpoint into');
    }

    _currentState = checkpoint.state;
    _emitStateUpdate();
    
    // Create a restoration checkpoint
    await _createCheckpoint(
      'Restored from ${checkpoint.name}',
      'Match state restored from checkpoint: ${checkpoint.name}',
    );
  }

  /// Creates a manual checkpoint with a custom name
  Future<MatchCheckpoint> createCheckpoint(String name, {String description = ''}) async {
    if (_currentState == null) {
      throw StateError('No active match to create checkpoint for');
    }

    return _createCheckpoint(name, description);
  }

  /// Pauses the current match
  void pauseMatch() {
    if (_currentState == null) return;
    
    _currentState = _currentState!.copyWith(isPaused: true);
    _emitStateUpdate();
  }

  /// Resumes the current match
  void resumeMatch() {
    if (_currentState == null) return;
    
    _currentState = _currentState!.copyWith(isPaused: false);
    _emitStateUpdate();
  }

  /// Changes the simulation speed
  void setSpeed(double speed) {
    if (_currentState == null) return;
    
    _currentState = _currentState!.copyWith(speed: speed.clamp(0.25, 8.0));
    _emitStateUpdate();
  }

  /// Updates tactics for a team
  Future<void> updateTactics(String teamId, TeamTactics tactics) async {
    if (_currentState == null) return;
    
    _currentState = _currentState!.updateTactics(teamId, tactics);
    _currentState = _currentState!.addToEventLog('Tactical change for team $teamId');
    
    // Create checkpoint if configured
    if (_checkpointConfig.shouldCreateCheckpoint('tacticalChange')) {
      await _createAutoCheckpoint('tacticalChange');
    }
    
    _emitStateUpdate();
  }

  /// Gets match statistics from current state
  MatchStats? getMatchStats() {
    return _currentState?.match.matchStats;
  }

  /// Gets momentum tracker from current state
  MomentumTracker? getMomentumTracker() {
    return _currentState?.match.momentumTracker;
  }

  /// Gets player performances from current state
  Map<String, PlayerPerformance>? getPlayerPerformances() {
    return _currentState?.match.playerPerformances;
  }

  /// Generates commentary for the current match state
  String generateStateCommentary() {
    if (_currentState == null) return '';
    
    return _commentaryEngine.generateMatchStateCommentary(
      _currentState!.match,
      stats: getMatchStats(),
      momentum: getMomentumTracker(),
    );
  }

  /// Gets match events up to a specific minute
  List<MatchEvent> getEventsUpToMinute(int minute) {
    if (_currentState == null) return [];
    
    return _currentState!.match.events
        .where((event) => event.minute <= minute)
        .toList();
  }

  /// Gets key match events (goals, cards, etc.)
  List<MatchEvent> getKeyEvents() {
    if (_currentState == null) return [];
    
    final keyEventTypes = {
      MatchEventType.goal,
      MatchEventType.yellowCard,
      MatchEventType.redCard,
      MatchEventType.halfTime,
      MatchEventType.fullTime,
      MatchEventType.tacticalChange,
    };
    
    return _currentState!.match.events
        .where((event) => keyEventTypes.contains(event.type))
        .toList();
  }

  /// Cleans up old checkpoints based on configuration
  void cleanupCheckpoints() {
    if (_checkpoints.isEmpty) return;
    
    final now = DateTime.now();
    final cutoffTime = now.subtract(_checkpointConfig.retentionPeriod);
    
    // Remove old checkpoints
    _checkpoints.removeWhere((checkpoint) => 
        checkpoint.timestamp.isBefore(cutoffTime));
    
    // Enforce maximum checkpoint limit
    if (_checkpoints.length > _checkpointConfig.maxCheckpoints) {
      final excessCount = _checkpoints.length - _checkpointConfig.maxCheckpoints;
      
      // Remove oldest non-automatic checkpoints first
      final manualCheckpoints = _checkpoints
          .where((cp) => cp.metadata['auto'] != true)
          .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      final toRemove = manualCheckpoints.take(excessCount).toList();
      for (final checkpoint in toRemove) {
        _checkpoints.remove(checkpoint);
      }
      
      // If still over limit, remove oldest automatic checkpoints
      if (_checkpoints.length > _checkpointConfig.maxCheckpoints) {
        final remainingExcess = _checkpoints.length - _checkpointConfig.maxCheckpoints;
        _checkpoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _checkpoints.removeRange(0, remainingExcess);
      }
    }
  }

  /// Removes a specific checkpoint
  bool removeCheckpoint(String checkpointId) {
    final index = _checkpoints.indexWhere((cp) => cp.id == checkpointId);
    if (index != -1) {
      _checkpoints.removeAt(index);
      return true;
    }
    return false;
  }

  /// Exports current match state as JSON
  Map<String, dynamic> exportState() {
    if (_currentState == null) {
      throw StateError('No active match state to export');
    }
    
    return {
      'state': _currentState!.toJson(),
      'checkpoints': _checkpoints.map((cp) => cp.toJson()).toList(),
      'config': _checkpointConfig.toJson(),
      'exportTime': DateTime.now().toIso8601String(),
    };
  }

  /// Imports match state from JSON
  Future<void> importState(Map<String, dynamic> data) async {
    try {
      final stateData = data['state'] as Map<String, dynamic>;
      final checkpointData = data['checkpoints'] as List<dynamic>;
      
      _currentState = MatchState.fromJson(stateData);
      _checkpoints.clear();
      _checkpoints.addAll(
        checkpointData.map((cp) => MatchCheckpoint.fromJson(cp as Map<String, dynamic>))
      );
      
      _emitStateUpdate();
    } catch (e) {
      throw ArgumentError('Invalid state data format: $e');
    }
  }

  /// Ends the current match management session
  Future<void> endMatch() async {
    if (_currentState != null && !_currentState!.match.isCompleted) {
      // Create final checkpoint
      await _createCheckpoint('Match Ended', 'Match management session ended');
    }
    
    await _simulatorSubscription?.cancel();
    _simulatorSubscription = null;
    _simulator = null;
    _currentState = null;
    
    // Clean up old checkpoints
    cleanupCheckpoints();
  }

  /// Handles events from the streaming match simulator
  void _handleSimulatorEvent(MatchSimulationEvent event) async {
    if (_currentState == null) return;
    
    // Update current state with new match data
    _currentState = _currentState!.copyWith(
      match: event.currentMatch,
      currentMinute: event.currentMatch.currentMinute,
      timestamp: DateTime.now(),
    );
    
    // Add event to log if there's a new event
    if (event.newEvent != null) {
      final eventDescription = event.commentary ?? event.newEvent!.description;
      _currentState = _currentState!.addToEventLog(
        '${event.newEvent!.minute}\': $eventDescription'
      );
      
      // Create automatic checkpoint if configured
      final eventType = event.newEvent!.type.name;
      if (_checkpointConfig.shouldCreateCheckpoint(eventType)) {
        await _createAutoCheckpoint(eventType);
      }
    }
    
    _emitStateUpdate();
  }

  /// Creates a checkpoint and adds it to the collection
  Future<MatchCheckpoint> _createCheckpoint(String name, String description) async {
    if (_currentState == null) {
      throw StateError('No active match state');
    }
    
    final checkpoint = MatchCheckpoint.fromState(
      _currentState!,
      name: name,
      description: description,
    );
    
    _checkpoints.add(checkpoint);
    _checkpointController.add(checkpoint);
    
    // Cleanup if needed
    if (_checkpoints.length > _checkpointConfig.maxCheckpoints) {
      cleanupCheckpoints();
    }
    
    return checkpoint;
  }

  /// Creates an automatic checkpoint based on event type
  Future<MatchCheckpoint> _createAutoCheckpoint(String eventType) async {
    if (_currentState == null) {
      throw StateError('No active match state');
    }
    
    final checkpoint = MatchCheckpoint.auto(_currentState!, eventType);
    _checkpoints.add(checkpoint);
    _checkpointController.add(checkpoint);
    
    return checkpoint;
  }

  /// Emits a state update to listeners
  void _emitStateUpdate() {
    if (_currentState != null) {
      _stateController.add(_currentState!);
    }
  }

  /// Disposes of the state manager and cleans up resources
  void dispose() {
    _simulatorSubscription?.cancel();
    _stateController.close();
    _checkpointController.close();
    _checkpoints.clear();
    _currentState = null;
    _simulator = null;
  }
}

/// Utility class for match state persistence operations
class MatchStatePersistence {
  /// Saves match state to a storage mechanism (implementation dependent)
  static Future<bool> saveState(MatchState state, String storage) async {
    try {
      // This is a placeholder - in a real implementation, this would
      // save to local storage, database, or file system
      final json = state.toJson();
      // await storage.write(state.id, json);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads match state from storage
  static Future<MatchState?> loadState(String stateId, String storage) async {
    try {
      // This is a placeholder - in a real implementation, this would
      // load from local storage, database, or file system
      // final json = await storage.read(stateId);
      // return MatchState.fromJson(json);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Lists available saved states
  static Future<List<String>> listSavedStates(String storage) async {
    try {
      // Placeholder implementation
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Deletes a saved state
  static Future<bool> deleteState(String stateId, String storage) async {
    try {
      // Placeholder implementation
      return true;
    } catch (e) {
      return false;
    }
  }
}
