/// Soccer Engine - A comprehensive soccer simulation library
/// 
/// This library provides a complete soccer simulation engine with:
/// - Statistical match simulation
/// - Team and player management
/// - Financial systems
/// - Youth academy
/// - Weather and tactical systems
library soccer_engine;

// Core models (implemented)
export 'src/models/player.dart' show Player, PlayerPosition;
export 'src/models/team.dart' hide Formation;
export 'src/models/youth_player.dart';
export 'src/models/youth_academy.dart';
export 'src/models/contract.dart';
export 'src/models/transfer.dart';
export 'src/models/financial_account.dart';
export 'src/utils/player_valuation.dart';

// Core models (implemented)
export 'src/models/match.dart';
export 'src/models/tactics.dart' hide PlayerPosition;
export 'src/models/league.dart';
export 'src/models/gameweek.dart';

// Game systems (implemented)
export 'src/systems/game_state.dart';
export 'src/systems/match_simulator.dart';
export 'src/systems/tactical_system.dart';

// TODO: Game systems (to be implemented)
// export 'src/systems/financial_system.dart';
// export 'src/systems/youth_academy.dart';

// TODO: Utilities (to be implemented)
// export 'src/utils/random_generator.dart';
// export 'src/utils/name_generator.dart';

// AI models (implemented)
export 'src/ai/models/gm_profile.dart';
export 'src/ai/engines/decision_engine.dart';

// AI systems (implemented)
export 'src/ai/systems/transfer_ai.dart';
export 'src/ai/systems/squad_ai.dart';
export 'src/ai/systems/gm_ai_system.dart';

// TODO: AI systems (to be implemented)
// export 'src/ai/analyzers/market_analyzer.dart';
// export 'src/ai/systems/strategic_ai.dart';

// TODO: Data persistence (to be implemented)
// export 'src/persistence/save_manager.dart';
