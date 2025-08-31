import 'package:test/test.dart';
import 'package:tactics_fc_engine/src/utils/player_valuation.dart';
import 'package:tactics_fc_utilities/src/models/player.dart';

void main() {
  group('Player Valuation Tests', () {
    late PlayerValuation valuation;
    
    setUp(() {
      valuation = PlayerValuation();
    });

    group('Base Valuation Calculation', () {
      test('should calculate base valuation for young high-potential player', () {
        final youngStar = Player(
          id: 'player1',
          name: 'Young Star',
          age: 20,
          position: PlayerPosition.forward,
          technical: 85,
          physical: 80,
          mental: 75,
        );

        final value = valuation.calculateBaseValue(youngStar);
        
        // High ratings + young age should result in high value
        expect(value, greaterThan(10000000)); // > 10M
        expect(value, lessThan(100000000)); // < 100M (reasonable upper bound)
      });

      test('should calculate base valuation for older declining player', () {
        final veteranPlayer = Player(
          id: 'player2',
          name: 'Veteran Player',
          age: 35,
          position: PlayerPosition.defender,
          technical: 70,
          physical: 65,
          mental: 85,
        );

        final value = valuation.calculateBaseValue(veteranPlayer);
        
        // Older age should result in lower value despite decent ratings
        expect(value, greaterThan(1000000)); // > 1M
        expect(value, lessThan(20000000)); // < 20M
      });

      test('should calculate base valuation for average player', () {
        final averagePlayer = Player(
          id: 'player3',
          name: 'Average Player',
          age: 25,
          position: PlayerPosition.midfielder,
          technical: 60,
          physical: 60,
          mental: 60,
        );

        final value = valuation.calculateBaseValue(averagePlayer);
        
        // Average player should have moderate value
        expect(value, greaterThan(500000)); // > 500K
        expect(value, lessThan(10000000)); // < 10M
      });

      test('should value goalkeepers differently', () {
        final goalkeeper = Player(
          id: 'player4',
          name: 'Goalkeeper',
          age: 25,
          position: PlayerPosition.goalkeeper,
          technical: 50,
          physical: 70,
          mental: 80,
        );

        final outfieldPlayer = Player(
          id: 'player5',
          name: 'Outfield Player',
          age: 25,
          position: PlayerPosition.midfielder,
          technical: 50,
          physical: 70,
          mental: 80,
        );

        final gkValue = valuation.calculateBaseValue(goalkeeper);
        final outfieldValue = valuation.calculateBaseValue(outfieldPlayer);
        
        // Different position weighting should result in different values
        expect(gkValue, isNot(equals(outfieldValue)));
      });
    });

    group('Market Factors', () {
      test('should apply age factor correctly', () {
        final youngPlayer = Player(
          id: 'player1',
          name: 'Young Player',
          age: 18,
          position: PlayerPosition.forward,
          technical: 70,
          physical: 70,
          mental: 70,
        );

        final primePlayer = Player(
          id: 'player2',
          name: 'Prime Player',
          age: 26,
          position: PlayerPosition.forward,
          technical: 70,
          physical: 70,
          mental: 70,
        );

        final oldPlayer = Player(
          id: 'player3',
          name: 'Old Player',
          age: 35,
          position: PlayerPosition.forward,
          technical: 70,
          physical: 70,
          mental: 70,
        );

        final ageFactor18 = valuation.calculateAgeFactor(18);
        final ageFactor26 = valuation.calculateAgeFactor(26);
        final ageFactor35 = valuation.calculateAgeFactor(35);

        // Peak age should have highest factor
        expect(ageFactor26, greaterThanOrEqualTo(ageFactor18));
        expect(ageFactor26, greaterThan(ageFactor35));
        
        // Age factors should be reasonable (0.1 to 1.5)
        expect(ageFactor18, greaterThan(0.1));
        expect(ageFactor18, lessThan(1.5));
        expect(ageFactor26, greaterThan(0.1));
        expect(ageFactor26, lessThan(1.5));
        expect(ageFactor35, greaterThan(0.1));
        expect(ageFactor35, lessThan(1.5));
      });

      test('should apply position factor correctly', () {
        final positions = [
          PlayerPosition.goalkeeper,
          PlayerPosition.defender,
          PlayerPosition.midfielder,
          PlayerPosition.forward,
        ];

        for (final position in positions) {
          final factor = valuation.calculatePositionFactor(position);
          expect(factor, greaterThan(0.5));
          expect(factor, lessThan(2.0));
        }
      });

      test('should apply form factor correctly', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 25,
          position: PlayerPosition.midfielder,
          technical: 70,
          physical: 70,
          mental: 70,
          form: 9,
        );

        final highFormFactor = valuation.calculateFormFactor(player);
        
        final lowFormPlayer = player.updateForm(3);
        final lowFormFactor = valuation.calculateFormFactor(lowFormPlayer);

        expect(highFormFactor, greaterThan(lowFormFactor));
        expect(highFormFactor, greaterThan(0.8));
        expect(highFormFactor, lessThan(1.3));
        expect(lowFormFactor, greaterThan(0.8));
        expect(lowFormFactor, lessThan(1.3));
      });
    });

    group('Market Value Calculation', () {
      test('should calculate market value with all factors', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 23,
          position: PlayerPosition.forward,
          technical: 85,
          physical: 80,
          mental: 75,
          form: 8,
        );

        final marketValue = valuation.calculateMarketValue(player);
        
        expect(marketValue, greaterThan(0));
        expect(marketValue, lessThan(200000000)); // Reasonable upper bound
      });

      test('should calculate market value with market conditions', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 25,
          position: PlayerPosition.midfielder,
          technical: 75,
          physical: 75,
          mental: 75,
        );

        final normalValue = valuation.calculateMarketValue(player);
        final inflatedValue = valuation.calculateMarketValue(
          player,
          marketConditions: MarketConditions(
            inflation: 1.2,
            positionDemand: {PlayerPosition.midfielder: 1.3},
          ),
        );

        expect(inflatedValue, greaterThan(normalValue));
      });

      test('should calculate release clause suggestion', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 24,
          position: PlayerPosition.forward,
          technical: 80,
          physical: 80,
          mental: 80,
        );

        final marketValue = valuation.calculateMarketValue(player);
        final releaseClause = valuation.suggestReleaseClause(player);

        // Release clause should be higher than market value
        expect(releaseClause, greaterThan(marketValue));
        expect(releaseClause, lessThan(marketValue * 3)); // Not more than 3x
      });
    });

    group('Contract Value Suggestions', () {
      test('should suggest appropriate weekly wage', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 25,
          position: PlayerPosition.midfielder,
          technical: 75,
          physical: 75,
          mental: 75,
        );

        final weeklyWage = valuation.suggestWeeklyWage(player);
        
        expect(weeklyWage, greaterThan(1000)); // Minimum wage
        expect(weeklyWage, lessThan(500000)); // Reasonable maximum
      });

      test('should suggest signing bonus', () {
        final player = Player(
          id: 'player1',
          name: 'Test Player',
          age: 25,
          position: PlayerPosition.forward,
          technical: 85,
          physical: 80,
          mental: 80,
        );

        final marketValue = valuation.calculateMarketValue(player);
        final signingBonus = valuation.suggestSigningBonus(player);

        expect(signingBonus, greaterThanOrEqualTo(0));
        expect(signingBonus, lessThan(marketValue * 0.2)); // Max 20% of value
      });
    });

    group('Valuation Factors Edge Cases', () {
      test('should handle minimum age player', () {
        final youngPlayer = Player(
          id: 'player1',
          name: 'Very Young Player',
          age: 16,
          position: PlayerPosition.forward,
          technical: 50,
          physical: 50,
          mental: 50,
        );

        final value = valuation.calculateMarketValue(youngPlayer);
        expect(value, greaterThan(0));
      });

      test('should handle maximum age player', () {
        final oldPlayer = Player(
          id: 'player1',
          name: 'Very Old Player',
          age: 45,
          position: PlayerPosition.goalkeeper,
          technical: 60,
          physical: 40,
          mental: 80,
        );

        final value = valuation.calculateMarketValue(oldPlayer);
        expect(value, greaterThan(0));
      });

      test('should handle minimum rating player', () {
        final lowRatedPlayer = Player(
          id: 'player1',
          name: 'Low Rated Player',
          age: 25,
          position: PlayerPosition.defender,
          technical: 1,
          physical: 1,
          mental: 1,
        );

        final value = valuation.calculateMarketValue(lowRatedPlayer);
        expect(value, greaterThan(0));
        expect(value, lessThan(1000000)); // Should be low
      });

      test('should handle maximum rating player', () {
        final worldClassPlayer = Player(
          id: 'player1',
          name: 'World Class Player',
          age: 25,
          position: PlayerPosition.forward,
          technical: 100,
          physical: 100,
          mental: 100,
        );

        final value = valuation.calculateMarketValue(worldClassPlayer);
        expect(value, greaterThan(50000000)); // Should be very high
      });
    });
  });
}
