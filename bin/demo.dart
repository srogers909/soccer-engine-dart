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
      case 'team-demo':
        await _teamDemo();
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
  team-demo                          - Demonstrate team model functionality
  simulate-match <team1> <team2>     - Simulate a single match
  simulate-season <league>           - Simulate an entire season
  player-stats <player>              - Show detailed player statistics
  financial-report <team>            - Show team financial information
  youth-academy <team>               - Show youth academy status
  benchmark                          - Run performance benchmarks
  help                               - Show this help message

Examples:
  dart run bin/demo.dart player-demo
  dart run bin/demo.dart team-demo
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

Future<void> _teamDemo() async {
  print('🏟️  Team Model Demonstration');
  print('=' * 50);
  
  // Create a stadium first
  final stadium = Stadium(
    name: 'Camp Nou',
    capacity: 99354,
    city: 'Barcelona',
  );
  
  print('\n🏟️  Stadium:');
  print('  ${stadium.name} - ${stadium.city}');
  print('  Capacity: ${stadium.capacity.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} seats');
  
  // Create some world-class players for our team
  final players = [
    // Goalkeeper
    Player(
      id: 'ter-stegen-001',
      name: 'Marc-André ter Stegen',
      age: 31,
      position: PlayerPosition.goalkeeper,
      technical: 85,
      physical: 82,
      mental: 90,
    ),
    
    // Defenders
    Player(
      id: 'araujo-001',
      name: 'Ronald Araújo',
      age: 25,
      position: PlayerPosition.defender,
      technical: 75,
      physical: 92,
      mental: 85,
    ),
    Player(
      id: 'kounde-001',
      name: 'Jules Koundé',
      age: 25,
      position: PlayerPosition.defender,
      technical: 82,
      physical: 88,
      mental: 86,
    ),
    Player(
      id: 'balde-001',
      name: 'Alejandro Balde',
      age: 21,
      position: PlayerPosition.defender,
      technical: 80,
      physical: 90,
      mental: 78,
    ),
    Player(
      id: 'cancelo-001',
      name: 'João Cancelo',
      age: 30,
      position: PlayerPosition.defender,
      technical: 88,
      physical: 85,
      mental: 87,
    ),
    
    // Midfielders
    Player(
      id: 'pedri-001',
      name: 'Pedri',
      age: 21,
      position: PlayerPosition.midfielder,
      technical: 92,
      physical: 75,
      mental: 88,
    ),
    Player(
      id: 'de-jong-001',
      name: 'Frenkie de Jong',
      age: 27,
      position: PlayerPosition.midfielder,
      technical: 90,
      physical: 82,
      mental: 86,
    ),
    Player(
      id: 'gavi-001',
      name: 'Gavi',
      age: 20,
      position: PlayerPosition.midfielder,
      technical: 88,
      physical: 78,
      mental: 85,
    ),
    
    // Forwards
    Player(
      id: 'lewandowski-001',
      name: 'Robert Lewandowski',
      age: 35,
      position: PlayerPosition.forward,
      technical: 95,
      physical: 85,
      mental: 92,
    ),
    Player(
      id: 'raphinha-001',
      name: 'Raphinha',
      age: 27,
      position: PlayerPosition.forward,
      technical: 87,
      physical: 85,
      mental: 82,
    ),
    Player(
      id: 'yamal-001',
      name: 'Lamine Yamal',
      age: 17,
      position: PlayerPosition.forward,
      technical: 85,
      physical: 70,
      mental: 80,
    ),
  ];
  
  // Create Barcelona team
  var barcelona = Team(
    id: 'barcelona-001',
    name: 'FC Barcelona',
    city: 'Barcelona',
    foundedYear: 1899,
    stadium: stadium,
    formation: Formation.f433,
  );
  
  print('\n⚽ Creating Team: ${barcelona.name}');
  print('  Formation: ${barcelona.formation.name.toUpperCase()}');
  print('  Stadium: ${barcelona.stadium.name}');
  print('  Squad Size: ${barcelona.players.length}/30');
  print('');
  
  // Add players to the team
  print('📋 Adding Players to Squad:');
  for (final player in players) {
    barcelona = barcelona.addPlayer(player);
    print('  ✅ ${player.name} (${player.position.name.toUpperCase()}) - Overall: ${player.overallRating}');
  }
  
  print('\n📊 Squad Overview:');
  print('  Total Players: ${barcelona.players.length}');
  print('  Goalkeepers: ${barcelona.getPlayersByPosition(PlayerPosition.goalkeeper).length}');
  print('  Defenders: ${barcelona.getPlayersByPosition(PlayerPosition.defender).length}');
  print('  Midfielders: ${barcelona.getPlayersByPosition(PlayerPosition.midfielder).length}');
  print('  Forwards: ${barcelona.getPlayersByPosition(PlayerPosition.forward).length}');
  
  // Set up starting XI for 4-3-3 formation
  print('\n🏃 Setting Starting XI (4-3-3 Formation):');
  final startingXIPlayers = [
    players[0], // GK: ter Stegen
    players[1], // CB: Araújo
    players[2], // CB: Koundé
    players[3], // LB: Balde
    players[4], // RB: Cancelo
    players[5], // CM: Pedri
    players[6], // CM: de Jong
    players[7], // CM: Gavi
    players[8], // CF: Lewandowski
    players[9], // RW: Raphinha
    players[10], // LW: Yamal
  ];
  
  barcelona = barcelona.setStartingXI(startingXIPlayers);
  
  for (final player in barcelona.startingXI) {
    print('  ${player.name} (${player.position.name.toUpperCase()})');
  }
  
  // Analyze team strength
  print('\n💪 Team Analysis:');
  final chemistry = barcelona.chemistry;
  final strengths = barcelona.positionStrengths;
  
  print('  Team Chemistry: ${chemistry}/100');
  print('  Position Strengths:');
  print('    Attack: ${strengths[PlayerPosition.forward] ?? 'N/A'}');
  print('    Midfield: ${strengths[PlayerPosition.midfielder] ?? 'N/A'}');
  print('    Defense: ${strengths[PlayerPosition.defender] ?? 'N/A'}');
  print('    Goalkeeper: ${strengths[PlayerPosition.goalkeeper] ?? 'N/A'}');
  
  // Test formation changes
  print('\n🔄 Formation Changes:');
  print('  Current: ${barcelona.formation.displayName}');
  
  // Try changing to 3-5-2
  try {
    final barcelona352 = barcelona.setFormation(Formation.f352);
    print('  ✅ Changed to ${barcelona352.formation.displayName}');
    print('     Requirements: ${Formation.f352.requirements}');
  } catch (e) {
    print('  ❌ Cannot change to 3-5-2: $e');
  }
  
  // Try changing to 4-4-2
  try {
    final barcelona442 = barcelona.setFormation(Formation.f442);
    print('  ✅ Changed to ${barcelona442.formation.displayName}');
    print('     Requirements: ${Formation.f442.requirements}');
  } catch (e) {
    print('  ❌ Cannot change to 4-4-2: $e');
  }
  
  // Test JSON serialization
  print('\n💾 JSON Serialization:');
  final barcelonaJson = barcelona.toJson();
  final barcelonaFromJson = Team.fromJson(barcelonaJson);
  
  print('  Team serialized to JSON and back:');
  print('  Original squad size: ${barcelona.players.length}');
  print('  From JSON squad size: ${barcelonaFromJson.players.length}');
  print('  Equal? ${barcelona == barcelonaFromJson}');
  
  // Player management operations
  print('\n🔄 Player Management:');
  
  // Add a new player
  final newPlayer = Player(
    id: 'torres-001',
    name: 'Ferran Torres',
    age: 24,
    position: PlayerPosition.forward,
    technical: 83,
    physical: 82,
    mental: 80,
  );
  
  barcelona = barcelona.addPlayer(newPlayer);
  print('  ✅ Added ${newPlayer.name} to squad');
  print('  Squad size: ${barcelona.players.length}');
  
  // Remove a player from the squad (also removes from starting XI)
  try {
    barcelona = barcelona.removePlayer(players.last.id);
    print('  ❌ Removed ${players.last.name} from squad');
    print('  Squad size: ${barcelona.players.length}');
    print('  Starting XI now has ${barcelona.startingXI.length} players');
  } catch (e) {
    print('  ⚠️  Could not remove player: $e');
    print('  Note: This is expected when removing players affects starting XI validation');
  }
  
  // Test squad limits
  print('\n📏 Squad Limits Test:');
  var playersAdded = 0;
  try {
    for (int i = 0; i < 25; i++) {
      final testPlayer = Player(
        id: 'test-player-$i',
        name: 'Test Player $i',
        age: 25,
        position: PlayerPosition.midfielder,
        technical: 70,
        physical: 70,
        mental: 70,
      );
      barcelona = barcelona.addPlayer(testPlayer);
      playersAdded++;
    }
  } catch (e) {
    print('  ⚠️  Hit squad limit after adding $playersAdded players');
    print('  Final squad size: ${barcelona.players.length}/30');
    print('  Error: $e');
  }
  
  print('\n✅ Team model demonstration completed!');
  print('   • Created team with stadium and formation system');
  print('   • Added players and managed squad');
  print('   • Set up starting XI with formation validation');
  print('   • Analyzed team chemistry and position strengths');
  print('   • Tested formation changes and requirements');
  print('   • Demonstrated JSON serialization');
  print('   • Tested player management and squad limits');
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
