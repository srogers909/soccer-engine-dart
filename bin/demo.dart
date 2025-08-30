import 'dart:io';
import 'package:soccer_engine/soccer_engine.dart';

/// CLI Demo Application for Soccer Engine
/// 
/// This application demonstrates the engine functionality before UI is ready.
/// Usage examples:
/// - dart run bin/demo.dart simulate-match "Team A" "Team B"
/// - dart run bin/demo.dart simulate-season "Premier League"
/// - dart run bin/demo.dart player-stats "Player Name"
/// - dart run bin/demo.dart financial-report "Team Name"
void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    _showHelp();
    return;
  }

  final command = arguments[0];
  
  try {
    switch (command) {
      case 'simulate-match':
        await _simulateMatch(arguments);
        break;
      case 'simulate-season':
        await _simulateSeason(arguments);
        break;
      case 'player-stats':
        await _showPlayerStats(arguments);
        break;
      case 'financial-report':
        await _showFinancialReport(arguments);
        break;
      case 'youth-academy':
        await _showYouthAcademy(arguments);
        break;
      case 'player-demo':
        await _playerDemo();
        break;
      case 'benchmark':
        await _runBenchmarks();
        break;
      case 'help':
        _showHelp();
        break;
      default:
        print('Unknown command: $command');
        _showHelp();
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _showHelp() {
  print('''
Soccer Engine CLI Demo

Available commands:
  player-demo                        - Demonstrate player model functionality
  simulate-match <team1> <team2>     - Simulate a single match
  simulate-season <league>           - Simulate an entire season
  player-stats <player>              - Show detailed player statistics
  financial-report <team>            - Show team financial information
  youth-academy <team>               - Show youth academy status
  benchmark                          - Run performance benchmarks
  help                               - Show this help message

Examples:
  dart run bin/demo.dart player-demo
  dart run bin/demo.dart simulate-match "Manchester United" "Liverpool"
  dart run bin/demo.dart simulate-season "Premier League"
  dart run bin/demo.dart player-stats "Lionel Messi"
  dart run bin/demo.dart financial-report "Barcelona"
''');
}

Future<void> _simulateMatch(List<String> arguments) async {
  if (arguments.length < 3) {
    print('Usage: simulate-match <team1> <team2>');
    return;
  }
  
  final team1Name = arguments[1];
  final team2Name = arguments[2];
  
  print('🏟️  Simulating match: $team1Name vs $team2Name');
  print('⏳ Setting up teams and match conditions...');
  
  // TODO: Implement once we have the core models
  print('🚧 Match simulation will be implemented with core engine');
}

Future<void> _simulateSeason(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: simulate-season <league>');
    return;
  }
  
  final leagueName = arguments[1];
  
  print('🏆 Simulating season: $leagueName');
  print('⏳ Generating fixtures and teams...');
  
  // TODO: Implement once we have the core models
  print('🚧 Season simulation will be implemented with core engine');
}

Future<void> _showPlayerStats(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: player-stats <player>');
    return;
  }
  
  final playerName = arguments[1];
  
  print('👤 Player Statistics: $playerName');
  
  // TODO: Implement once we have the player model
  print('🚧 Player stats will be implemented with player model');
}

Future<void> _showFinancialReport(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: financial-report <team>');
    return;
  }
  
  final teamName = arguments[1];
  
  print('💰 Financial Report: $teamName');
  
  // TODO: Implement once we have the financial system
  print('🚧 Financial reports will be implemented with financial system');
}

Future<void> _showYouthAcademy(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: youth-academy <team>');
    return;
  }
  
  final teamName = arguments[1];
  
  print('🌱 Youth Academy: $teamName');
  
  // TODO: Implement once we have the youth academy system
  print('🚧 Youth academy will be implemented with academy system');
}

Future<void> _playerDemo() async {
  print('⚽ Player Model Demonstration');
  print('=' * 50);
  
  // Create some sample players
  final messi = Player(
    id: 'messi-001',
    name: 'Lionel Messi',
    age: 36,
    position: PlayerPosition.forward,
    technical: 99,
    physical: 75,
    mental: 95,
  );
  
  final mbappe = Player(
    id: 'mbappe-001',
    name: 'Kylian Mbappé',
    age: 25,
    position: PlayerPosition.forward,
    technical: 90,
    physical: 95,
    mental: 85,
  );
  
  final neuer = Player(
    id: 'neuer-001',
    name: 'Manuel Neuer',
    age: 38,
    position: PlayerPosition.goalkeeper,
    technical: 85,
    physical: 80,
    mental: 98,
  );
  
  final modric = Player(
    id: 'modric-001',
    name: 'Luka Modrić',
    age: 38,
    position: PlayerPosition.midfielder,
    technical: 95,
    physical: 70,
    mental: 99,
  );
  
  final players = [messi, mbappe, neuer, modric];
  
  print('\n🌟 Star Players:');
  for (final player in players) {
    print('  ${player.name} (${player.position.name.toUpperCase()})');
    print('    Age: ${player.age} | Overall: ${player.overallRating} | Position Rating: ${player.positionOverallRating}');
    print('    Tech: ${player.technical} | Phys: ${player.physical} | Mental: ${player.mental}');
    print('    Form: ${player.form}/10 | Fitness: ${player.fitness}%');
    print('');
  }
  
  // Demonstrate form and fitness updates
  print('📈 Form & Fitness Updates:');
  final tiredMessi = messi.updateFitness(75);
  final hotFormMbappe = mbappe.updateForm(10);
  
  print('  Messi after tough match (fitness: 75%):');
  print('    Before: Fitness ${messi.fitness}% | After: Fitness ${tiredMessi.fitness}%');
  print('');
  print('  Mbappé in excellent form (10/10):');
  print('    Before: Form ${mbappe.form}/10 | After: Form ${hotFormMbappe.form}/10');
  print('');
  
  // Demonstrate JSON serialization
  print('💾 JSON Serialization:');
  final messiJson = messi.toJson();
  final messiFromJson = Player.fromJson(messiJson);
  
  print('  Messi serialized to JSON and back:');
  print('  Original: $messi');
  print('  From JSON: $messiFromJson');
  print('  Equal? ${messi == messiFromJson}');
  print('');
  
  // Position-specific ratings comparison
  print('⚖️  Position-Specific vs Overall Ratings:');
  for (final player in players) {
    final overall = player.overallRating;
    final positionSpecific = player.positionOverallRating;
    final difference = positionSpecific - overall;
    final arrow = difference > 0 ? '↗️' : (difference < 0 ? '↘️' : '➡️');
    
    print('  ${player.name}: Overall $overall → Position $positionSpecific $arrow');
  }
  
  print('\n✅ Player model demonstration completed!');
  print('   • Created players with different positions and attributes');
  print('   • Demonstrated form and fitness updates');
  print('   • Tested JSON serialization/deserialization');
  print('   • Compared overall vs position-specific ratings');
}

Future<void> _runBenchmarks() async {
  print('⚡ Running performance benchmarks...');
  
  final stopwatch = Stopwatch()..start();
  
  // Benchmark player creation and operations
  const playerCount = 10000;
  final players = <Player>[];
  
  print('Creating $playerCount players...');
  for (int i = 0; i < playerCount; i++) {
    players.add(Player(
      id: 'player-$i',
      name: 'Player $i',
      age: 20 + (i % 25), // Ages 20-44
      position: PlayerPosition.values[i % PlayerPosition.values.length],
      technical: 50 + (i % 51), // 50-100
      physical: 50 + (i % 51),
      mental: 50 + (i % 51),
    ));
  }
  
  print('Testing player operations...');
  var operationCount = 0;
  for (final player in players) {
    // Test various operations
    player.overallRating;
    player.positionOverallRating;
    player.updateForm((operationCount % 10) + 1);
    player.updateFitness((operationCount % 101));
    player.toJson();
    operationCount += 4;
  }
  
  stopwatch.stop();
  
  print('✅ Benchmark completed in ${stopwatch.elapsedMilliseconds}ms');
  print('   • Created $playerCount players');
  print('   • Performed $operationCount operations');
  print('   • Average: ${(stopwatch.elapsedMicroseconds / operationCount).toStringAsFixed(2)} μs/operation');
}
