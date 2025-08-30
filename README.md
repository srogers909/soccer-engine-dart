# Soccer Engine Dart

A comprehensive soccer simulation engine built with Dart/Flutter using Test-Driven Development (TDD) methodology with 100% test coverage.

## 🎯 Project Overview

This project consists of two separate components:
1. **Engine** (This repository) - Pure Dart package for soccer simulation logic
2. **UI** (Future repository) - Flutter app that consumes the engine

## ⚽ Features

### ✅ Implemented
- **Player Model** - Complete player system with:
  - Comprehensive attributes (technical, physical, mental)
  - Position-specific rating calculations
  - Form and fitness tracking
  - JSON serialization/deserialization
  - Age validation and realistic constraints
  - Immutable data structure with update methods

### 🚧 In Development
- Team management system
- Match simulation engine with weather and home advantage
- Tactical system
- Youth academy
- Financial management system
- League and competition management
- Save/load functionality

## 🧪 Test-Driven Development

This project follows strict TDD methodology:
- **100% test coverage** (statements, functions, branches, lines)
- **Red-Green-Refactor** cycle for all features
- Comprehensive unit, integration, and end-to-end tests
- Property-based testing for statistical accuracy

## 🚀 Quick Start

### Prerequisites
- Dart SDK 3.0.0 or higher
- Git

### Installation
```bash
git clone https://github.com/srogers909/soccer-engine-dart.git
cd soccer-engine-dart

# Install dependencies
dart pub get

# Generate JSON serialization code
dart run build_runner build
```

### Running Tests
```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
```

### CLI Demo
The engine includes a comprehensive CLI demonstration tool:

```bash
# Show help
dart run bin/demo.dart help

# Demonstrate player model
dart run bin/demo.dart player-demo

# Run performance benchmarks
dart run bin/demo.dart benchmark
```

## 📊 Performance

Current benchmarks (Player model):
- **10,000 players created** in ~22ms
- **40,000 operations** performed in ~22ms  
- **Average: 0.57 μs/operation**

## 🏗️ Architecture

### Core Models
- `Player` - Individual player with attributes, position, form, and fitness
- `PlayerPosition` - Enum for goalkeeper, defender, midfielder, forward

### Position-Specific Ratings
The engine calculates position-weighted overall ratings:
- **Goalkeepers**: Mental (50%), Physical (30%), Technical (20%)
- **Defenders**: Physical (40%), Mental (35%), Technical (25%)
- **Midfielders**: Technical (40%), Mental (35%), Physical (25%)
- **Forwards**: Technical (45%), Physical (30%), Mental (25%)

## 📱 Mobile Testing

Designed and optimized for:
- **Samsung Galaxy S25 Ultra**
- Flutter/Dart mobile performance
- Efficient memory usage for long gaming sessions

## 🛠️ Development

### Project Structure
```
lib/
├── soccer_engine.dart          # Main library exports
└── src/
    ├── models/                 # Data models
    │   ├── player.dart         # ✅ Player model
    │   ├── team.dart           # 🚧 Team model
    │   ├── match.dart          # 🚧 Match model
    │   └── league.dart         # 🚧 League model
    ├── systems/                # Game systems
    │   ├── match_engine.dart   # 🚧 Match simulation
    │   ├── tactical_system.dart # 🚧 Tactical calculations
    │   ├── financial_system.dart # 🚧 Financial management
    │   └── youth_academy.dart  # 🚧 Youth development
    ├── utils/                  # Utilities
    │   ├── random_generator.dart # 🚧 Random number generation
    │   └── name_generator.dart # 🚧 Name generation
    └── persistence/            # Data persistence
        └── save_manager.dart   # 🚧 Save/load functionality

test/                           # Test files (mirrors lib structure)
bin/
└── demo.dart                   # CLI demonstration tool
```

### Contributing

1. All code must be developed using TDD
2. 100% test coverage is required
3. Follow Dart style guidelines
4. Update CLI demos for new features

## 📋 Todo List

- [ ] TDD: Implement team data models with 100% test coverage
- [ ] TDD: Create match simulation engine with weather and home advantage
- [ ] TDD: Build tactical system with comprehensive tests
- [ ] TDD: Develop youth academy system with full coverage
- [ ] TDD: Implement financial management system with edge case testing
- [ ] TDD: Develop league/competition management with integration tests
- [ ] TDD: Implement save/load functionality with serialization tests
- [ ] Verify 100% test coverage across entire engine
- [ ] Create UI project structure with widget testing setup
- [ ] Build match display interface with UI tests
- [ ] Implement team management screens with integration tests
- [ ] Add youth academy UI with full test coverage
- [ ] Add financial management UI with comprehensive tests
- [ ] Add league/season progression UI with workflow tests
- [ ] Implement end-to-end testing scenarios
- [ ] Create performance and memory benchmarking tests
- [ ] Test on Galaxy S25 Ultra with comprehensive E2E scenarios
- [ ] Performance optimization with benchmark tests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Acknowledgments

- Built with Test-Driven Development principles
- Designed for statistical soccer simulation
- Optimized for mobile gaming performance
