import 'lib/src/models/player.dart';
import 'lib/src/models/tactics.dart' as tactics;
import 'lib/src/systems/tactical_system.dart';

void main() {
  // Exact setup from the failing test
  final tacticalSystem = TacticalSystem(seed: 42);
  
  // Recreate the exact players from the test setup
  final balancedPlayers = [
    Player(id: '1', name: 'Goalkeeper', age: 25, position: PlayerPosition.goalkeeper, technical: 80, physical: 70, mental: 85),
    Player(id: '2', name: 'Centre Back 1', age: 28, position: PlayerPosition.defender, technical: 60, physical: 80, mental: 75),
    Player(id: '3', name: 'Centre Back 2', age: 27, position: PlayerPosition.defender, technical: 65, physical: 85, mental: 78),
    Player(id: '4', name: 'Left Back', age: 24, position: PlayerPosition.defender, technical: 75, physical: 75, mental: 65),
    Player(id: '5', name: 'Right Back', age: 26, position: PlayerPosition.defender, technical: 70, physical: 70, mental: 68),
    Player(id: '6', name: 'CDM', age: 29, position: PlayerPosition.midfielder, technical: 75, physical: 70, mental: 80),
    Player(id: '7', name: 'CM 1', age: 25, position: PlayerPosition.midfielder, technical: 80, physical: 65, mental: 75),
    Player(id: '8', name: 'CM 2', age: 27, position: PlayerPosition.midfielder, technical: 85, physical: 60, mental: 78),
    Player(id: '9', name: 'LW', age: 23, position: PlayerPosition.forward, technical: 80, physical: 65, mental: 70),
    Player(id: '10', name: 'RW', age: 24, position: PlayerPosition.forward, technical: 85, physical: 70, mental: 72),
    Player(id: '11', name: 'Striker', age: 26, position: PlayerPosition.forward, technical: 75, physical: 80, mental: 75),
  ];

  // Exact test code
  final goalkeeper = balancedPlayers[0];
  final striker = balancedPlayers[10];

  print('Test players:');
  print('Goalkeeper: ${goalkeeper.name}, position: ${goalkeeper.position}');
  print('  technical: ${goalkeeper.technical}, physical: ${goalkeeper.physical}, mental: ${goalkeeper.mental}');
  print('Striker: ${striker.name}, position: ${striker.position}');
  print('  technical: ${striker.technical}, physical: ${striker.physical}, mental: ${striker.mental}');

  final roles442 = tacticalSystem.createOptimalRoles(tactics.Formation.f442, [goalkeeper, striker]);
  
  print('\nRoles created: ${roles442.length}');
  
  final gkRole = roles442.first;
  print('\nGoalkeeper Role (roles442.first):');
  print('  Position: ${gkRole.position}');
  print('  Attacking Freedom: ${gkRole.attackingFreedom}');
  print('  Defensive Work: ${gkRole.defensiveWork}');
  print('  Width: ${gkRole.width}');
  print('  Creative Freedom: ${gkRole.creativeFreedom}');
  
  print('\nTest check: gkRole.attackingFreedom < 30 = ${gkRole.attackingFreedom < 30}');
  print('Expected: true, Actual: ${gkRole.attackingFreedom < 30}');

  if (roles442.length > 1) {
    final strikerRole = roles442.last;
    print('\nStriker Role (roles442.last):');
    print('  Position: ${strikerRole.position}');
    print('  Attacking Freedom: ${strikerRole.attackingFreedom}');
    print('  Defensive Work: ${strikerRole.defensiveWork}');
    
    print('\nTest checks for striker:');
    print('  strikerRole.attackingFreedom > 80 = ${strikerRole.attackingFreedom > 80}');
    print('  strikerRole.defensiveWork < 30 = ${strikerRole.defensiveWork < 30}');
  }
}
