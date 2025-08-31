import 'package:tactics_fc_engine/soccer_engine.dart';

void main() {
  print('=== Soccer Engine AI Demo ===\n');
  
  // Create sample players for the team
  final players = _createSamplePlayers();
  
  // Create a team
  final team = Team(
    id: 'demo-team',
    name: 'Demo FC',
    city: 'Demo City',
    foundedYear: 2000,
    players: players,
  );
  
  // Create financial account
  final financialAccount = FinancialAccount(
    teamId: 'demo-team',
    balance: 50000000, // €50M starting balance
    currency: 'EUR',
    budgetLimits: {
      BudgetCategory.transfers: 20000000, // €20M transfer budget
      BudgetCategory.wages: 15000000,     // €15M wage budget
      BudgetCategory.youth: 5000000,      // €5M youth budget
      BudgetCategory.facilities: 10000000, // €10M facilities budget
    },
  );
  
  // Create GM profiles for different personalities
  print('1. Creating GM Profiles...');
  final conservativeGM = GMProfile.conservative(
    id: 'conservative-gm',
    name: 'Conservative Manager',
  );
  
  final aggressiveGM = GMProfile.aggressive(
    id: 'aggressive-gm', 
    name: 'Aggressive Manager',
  );
  
  final youthGM = GMProfile.youthFocused(
    id: 'youth-gm',
    name: 'Youth Manager',
  );
  
  print('   ✓ Conservative GM: ${conservativeGM.name} (Risk: ${conservativeGM.riskTolerance})');
  print('   ✓ Aggressive GM: ${aggressiveGM.name} (Risk: ${aggressiveGM.riskTolerance})');
  print('   ✓ Youth-focused GM: ${youthGM.name} (Youth Focus: ${youthGM.youthFocus})\n');
  
  // Demonstrate different AI systems with each GM personality
  _demonstrateGMPersonalities(team, financialAccount, [conservativeGM, aggressiveGM, youthGM]);
}

void _demonstrateGMPersonalities(Team team, FinancialAccount account, List<GMProfile> gmProfiles) {
  print('2. Demonstrating AI Decision Making by GM Personality...\n');
  
  for (final gm in gmProfiles) {
    print('--- ${gm.name} Analysis ---');
    
    // Create AI system with this GM's personality
    final decisionEngine = DecisionEngine(gmProfile: gm);
    final transferAI = TransferAI(decisionEngine: decisionEngine);
    final squadAI = SquadAI(decisionEngine: decisionEngine);
    final aiSystem = GMAISystem(
      decisionEngine: decisionEngine,
      transferAI: transferAI,
      squadAI: squadAI,
    );
    
    // Generate available players in the market
    final availablePlayers = _createMarketPlayers();
    
    // Generate comprehensive system report
    final report = aiSystem.generateSystemReport(
      team: team,
      financialAccount: account,
      availablePlayers: availablePlayers,
    );
    
    // Display results
    print('Transfer Strategy: ${report.transferAnalysis?.strategy ?? "No strategy"}');
    print('Squad Needs: ${report.transferAnalysis?.squadNeeds.map((n) => n.name).join(", ") ?? "None"}');
    print('Top Transfer Target: ${_getTopTarget(report.transferAnalysis)}');
    print('Formation Recommendation: ${_getTopFormation(report.squadAnalysis)}');
    print('Budget Analysis: Transfer €${report.budgetStatus['transfer_budget'] ~/ 1000000}M available');
    print('Recommendations:');
    for (final rec in report.recommendations.take(3)) {
      print('  • $rec');
    }
    print('System Confidence: ${(report.confidence * 100).toStringAsFixed(1)}%\n');
    
    // Demonstrate specific decision making
    _demonstrateDecisionMaking(aiSystem, team, account, gm);
  }
}

void _demonstrateDecisionMaking(GMAISystem aiSystem, Team team, FinancialAccount account, GMProfile gm) {
  print('Decision Examples for ${gm.name}:');
  
  // Transfer decision example
  final sampleTarget = TransferTarget(
    player: _createSamplePlayers().first,
    priority: 8,
    estimatedFee: 10000000, // €10M
    maxFee: 12000000,       // €12M
    need: TransferNeed.midfielder,
    confidence: 0.75,
  );
  
  final transferDecision = aiSystem.makeTransferDecision(
    target: sampleTarget,
    team: team,
    financialAccount: account,
  );
  
  print('  Transfer Decision: ${transferDecision.selectedOption}');
  print('  Reasoning: ${transferDecision.reasoning}');
  print('  Confidence: ${(transferDecision.confidence * 100).toStringAsFixed(1)}%');
  
  // Squad decision example
  final squadDecision = aiSystem.makeSquadDecision(
    team: team,
    decisionType: 'formation',
    context: {'match_importance': 'high', 'opponent_strength': 85},
  );
  
  print('  Formation Decision: ${squadDecision.selectedOption}');
  print('  Squad Reasoning: ${squadDecision.reasoning}');
  print('  Squad Confidence: ${(squadDecision.confidence * 100).toStringAsFixed(1)}%\n');
}

String _getTopTarget(TransferMarketAnalysis? analysis) {
  if (analysis == null || analysis.targets.isEmpty) return 'None identified';
  final target = analysis.targets.first;
  return '${target.player.name} (${target.need.name}) - €${target.estimatedFee ~/ 1000000}M';
}

String _getTopFormation(SquadAnalysis? analysis) {
  if (analysis == null || analysis.formationRecommendations.isEmpty) return 'Current formation';
  final best = analysis.formationRecommendations.entries
      .reduce((a, b) => a.value > b.value ? a : b);
  return '${best.key.displayName} (${(best.value * 100).toStringAsFixed(1)}% confidence)';
}

List<Player> _createSamplePlayers() {
  return [
    Player(
      id: 'p1',
      name: 'John Keeper',
      age: 28,
      position: PlayerPosition.goalkeeper,
      technical: 85,
      physical: 80,
      mental: 82,
      form: 8,
      fitness: 90,
    ),
    Player(
      id: 'p2',
      name: 'Mike Defender',
      age: 26,
      position: PlayerPosition.defender,
      technical: 70,
      physical: 82,
      mental: 75,
      form: 7,
      fitness: 88,
    ),
    Player(
      id: 'p3',
      name: 'Alex Midfielder',
      age: 24,
      position: PlayerPosition.midfielder,
      technical: 85,
      physical: 70,
      mental: 80,
      form: 9,
      fitness: 92,
    ),
    Player(
      id: 'p4',
      name: 'Tom Forward',
      age: 22,
      position: PlayerPosition.forward,
      technical: 82,
      physical: 75,
      mental: 75,
      form: 8,
      fitness: 85,
    ),
  ];
}

List<Player> _createMarketPlayers() {
  return [
    Player(
      id: 'market1',
      name: 'Star Striker',
      age: 26,
      position: PlayerPosition.forward,
      technical: 90,
      physical: 85,
      mental: 88,
      form: 9,
      fitness: 95,
    ),
    Player(
      id: 'market2',
      name: 'Young Talent',
      age: 19,
      position: PlayerPosition.midfielder,
      technical: 75,
      physical: 65,
      mental: 70,
      form: 8,
      fitness: 100,
    ),
    Player(
      id: 'market3',
      name: 'Experienced Defender',
      age: 32,
      position: PlayerPosition.defender,
      technical: 78,
      physical: 85,
      mental: 90,
      form: 7,
      fitness: 82,
    ),
  ];
}
