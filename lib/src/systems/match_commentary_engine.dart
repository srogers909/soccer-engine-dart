import 'dart:math';
import '../models/match.dart';
import '../models/team.dart';
import 'package:soccer_utilities/src/models/player.dart';
import '../models/enhanced_match.dart';

/// Generates contextual commentary for match events
class MatchCommentaryEngine {
  final Random _random;
  final Map<String, List<String>> _commentaryTemplates;
  
  /// Creates a new match commentary engine
  MatchCommentaryEngine({int? seed}) 
      : _random = Random(seed),
        _commentaryTemplates = _initializeCommentaryTemplates();

  /// Generates commentary for a specific match event
  String generateEventCommentary(MatchEvent event, Match match, {
    Player? player,
    Team? team,
    MatchStats? stats,
    MomentumTracker? momentum,
  }) {
    final templates = _commentaryTemplates[event.type.name] ?? ['Event occurred.'];
    final template = templates[_random.nextInt(templates.length)];
    
    return _processTemplate(template, event, match, 
        player: player, team: team, stats: stats, momentum: momentum);
  }

  /// Generates general match commentary based on current state
  String generateMatchStateCommentary(Match match, {
    MatchStats? stats,
    MomentumTracker? momentum,
  }) {
    final minute = match.currentMinute;
    final homeScore = match.homeGoals;
    final awayScore = match.awayGoals;
    
    // Generate context-aware commentary based on match state
    if (minute == 0) {
      return _getKickoffCommentary(match);
    } else if (minute == 45) {
      return _getHalfTimeCommentary(match);
    } else if (minute > 85 && minute < 90) {
      return _getLateMatchCommentary(match, stats);
    } else if (minute % 15 == 0) {
      return _getPeriodicUpdateCommentary(match, stats, momentum);
    } else if (stats != null && _shouldCommentOnStats(stats)) {
      return _getStatisticalCommentary(match, stats);
    } else if (momentum != null && _shouldCommentOnMomentum(momentum)) {
      return _getMomentumCommentary(match, momentum);
    }
    
    return _getGenericCommentary(match);
  }

  /// Generates pre-match commentary
  String generatePreMatchCommentary(Match match) {
    final templates = [
      'Welcome to {stadium} where {homeTeam} host {awayTeam} in what promises to be an exciting encounter!',
      'Good evening and welcome to {stadium}! {homeTeam} take on {awayTeam} in tonight\'s fixture.',
      'The teams are making their way onto the pitch at {stadium}. {homeTeam} vs {awayTeam} - this should be a cracker!',
      'Welcome everyone to {stadium} where {homeTeam} welcome {awayTeam}. The atmosphere is electric!',
      'We\'re live from {stadium} where {homeTeam} are preparing to face {awayTeam}. What a match we have in store!',
    ];
    
    final template = templates[_random.nextInt(templates.length)];
    return template
        .replaceAll('{homeTeam}', match.homeTeam.name)
        .replaceAll('{awayTeam}', match.awayTeam.name)
        .replaceAll('{stadium}', match.homeTeam.stadium.name);
  }

  /// Generates post-match commentary
  String generatePostMatchCommentary(Match match) {
    if (!match.isCompleted || match.result == null) {
      return 'The match has ended.';
    }
    
    final score = '${match.homeGoals}-${match.awayGoals}';
    final result = match.result!;
    
    switch (result) {
      case MatchResult.homeWin:
        return _getHomeWinCommentary(match, score);
      case MatchResult.awayWin:
        return _getAwayWinCommentary(match, score);
      case MatchResult.draw:
        return _getDrawCommentary(match, score);
    }
  }

  /// Processes template strings with dynamic replacements
  String _processTemplate(String template, MatchEvent event, Match match, {
    Player? player,
    Team? team,
    MatchStats? stats,
    MomentumTracker? momentum,
  }) {
    final actualTeam = team ?? (event.teamId == match.homeTeam.id ? match.homeTeam : match.awayTeam);
    final oppositionTeam = actualTeam.id == match.homeTeam.id ? match.awayTeam : match.homeTeam;
    
    return template
        .replaceAll('{player}', player?.name ?? event.playerName ?? 'Unknown Player')
        .replaceAll('{team}', actualTeam.name)
        .replaceAll('{opposition}', oppositionTeam.name)
        .replaceAll('{homeTeam}', match.homeTeam.name)
        .replaceAll('{awayTeam}', match.awayTeam.name)
        .replaceAll('{minute}', event.minute.toString())
        .replaceAll('{homeScore}', match.homeGoals.toString())
        .replaceAll('{awayScore}', match.awayGoals.toString())
        .replaceAll('{stadium}', match.homeTeam.stadium.name)
        .replaceAll('{weather}', _getWeatherDescription(match.weather))
        .replaceAll('{possession}', _getPossessionString(stats, actualTeam.id == match.homeTeam.id))
        .replaceAll('{momentum}', _getMomentumString(momentum, actualTeam.id == match.homeTeam.id));
  }

  /// Gets weather description for commentary
  String _getWeatherDescription(Weather weather) {
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return 'sunny conditions';
      case WeatherCondition.cloudy:
        return 'overcast skies';
      case WeatherCondition.rainy:
        return 'wet conditions';
      case WeatherCondition.snowy:
        return 'snowy weather';
      case WeatherCondition.windy:
        return 'windy conditions';
      case WeatherCondition.foggy:
        return 'foggy conditions';
    }
  }

  /// Gets possession string for commentary
  String _getPossessionString(MatchStats? stats, bool isHomeTeam) {
    if (stats == null) return '';
    
    final possession = isHomeTeam ? stats.homePossession : stats.awayPossession;
    return '${possession.toStringAsFixed(0)}%';
  }

  /// Gets momentum string for commentary
  String _getMomentumString(MomentumTracker? momentum, bool isHomeTeam) {
    if (momentum == null) return '';
    
    final teamMomentum = isHomeTeam ? momentum.homeMomentum : momentum.awayMomentum;
    if (teamMomentum > 70) return 'dominant';
    if (teamMomentum > 55) return 'in control';
    if (teamMomentum < 30) return 'under pressure';
    if (teamMomentum < 45) return 'struggling';
    return 'balanced';
  }

  /// Commentary for kickoff
  String _getKickoffCommentary(Match match) {
    final templates = [
      'And we\'re underway! {homeTeam} get us started here at {stadium}.',
      'The referee blows his whistle and {homeTeam} kick off against {awayTeam}!',
      'Here we go! {homeTeam} vs {awayTeam} is now underway at {stadium}.',
      'The match begins! {homeTeam} start play in front of their home crowd.',
    ];
    
    final template = templates[_random.nextInt(templates.length)];
    return template
        .replaceAll('{homeTeam}', match.homeTeam.name)
        .replaceAll('{awayTeam}', match.awayTeam.name)
        .replaceAll('{stadium}', match.homeTeam.stadium.name);
  }

  /// Commentary for half time
  String _getHalfTimeCommentary(Match match) {
    final score = '${match.homeGoals}-${match.awayGoals}';
    final templates = [
      'The referee brings the first half to an end. It\'s {homeTeam} {score} {awayTeam} at the break.',
      'Half time here at {stadium}. {homeTeam} {score} {awayTeam} - what a first 45 minutes!',
      'That\'s the half time whistle! {homeTeam} {score} {awayTeam} as we reach the interval.',
      'The first half comes to a close with {homeTeam} leading {score} against {awayTeam}.',
    ];
    
    final template = templates[_random.nextInt(templates.length)];
    return template
        .replaceAll('{homeTeam}', match.homeTeam.name)
        .replaceAll('{awayTeam}', match.awayTeam.name)
        .replaceAll('{score}', score)
        .replaceAll('{stadium}', match.homeTeam.stadium.name);
  }

  /// Commentary for late match situations
  String _getLateMatchCommentary(Match match, MatchStats? stats) {
    final minutesLeft = 90 - match.currentMinute;
    final isClose = (match.homeGoals - match.awayGoals).abs() <= 1;
    
    if (isClose) {
      return 'Just $minutesLeft minutes remaining and this match is still very much in the balance!';
    } else if (match.homeGoals > match.awayGoals) {
      return 'Time is running out for ${match.awayTeam.name} as ${match.homeTeam.name} hold a comfortable lead.';
    } else {
      return '${match.awayTeam.name} are cruising to victory here with just $minutesLeft minutes left on the clock.';
    }
  }

  /// Periodic update commentary
  String _getPeriodicUpdateCommentary(Match match, MatchStats? stats, MomentumTracker? momentum) {
    final minute = match.currentMinute;
    final score = '${match.homeGoals}-${match.awayGoals}';
    
    if (stats != null) {
      final homePossession = stats.homePossession.toStringAsFixed(0);
      final awayPossession = stats.awayPossession.toStringAsFixed(0);
      
      return '$minute minutes played here at ${match.homeTeam.stadium.name}. '
             '${match.homeTeam.name} $score ${match.awayTeam.name}. '
             'Possession: ${match.homeTeam.name} $homePossession%, ${match.awayTeam.name} $awayPossession%.';
    }
    
    return '$minute minutes on the clock. ${match.homeTeam.name} $score ${match.awayTeam.name}.';
  }

  /// Statistical commentary
  String _getStatisticalCommentary(Match match, MatchStats stats) {
    final homeShots = stats.homeShots;
    final awayShots = stats.awayShots;
    final homePossession = stats.homePossession;
    
    if (homeShots > awayShots + 3) {
      return '${match.homeTeam.name} are really turning up the pressure with $homeShots shots to ${match.awayTeam.name}\'s $awayShots.';
    } else if (awayShots > homeShots + 3) {
      return 'The visitors are asking all the questions here - $awayShots shots for ${match.awayTeam.name} compared to $homeShots for the hosts.';
    } else if (homePossession > 70) {
      return '${match.homeTeam.name} are really dominating possession here with ${homePossession.toStringAsFixed(0)}% of the ball.';
    } else if (homePossession < 30) {
      return '${match.awayTeam.name} are controlling this match, enjoying ${(100 - homePossession).toStringAsFixed(0)}% possession.';
    }
    
    return 'It\'s been an evenly contested affair so far between these two sides.';
  }

  /// Momentum commentary
  String _getMomentumCommentary(Match match, MomentumTracker momentum) {
    if (momentum.homeMomentum > 75) {
      return '${match.homeTeam.name} have really seized control of this match and are piling on the pressure!';
    } else if (momentum.awayMomentum > 75) {
      return 'The momentum has completely shifted in favor of ${match.awayTeam.name} here!';
    } else if ((momentum.homeMomentum - momentum.awayMomentum).abs() < 10) {
      return 'This is incredibly evenly poised - neither side can gain the upper hand!';
    }
    
    return 'The ebb and flow of this match continues as both teams battle for control.';
  }

  /// Generic commentary for regular play
  String _getGenericCommentary(Match match) {
    final templates = [
      'The action continues here at {stadium}...',
      'Both teams working hard in these {weather}.',
      'An intriguing battle unfolding between {homeTeam} and {awayTeam}.',
      'The intensity remains high as we approach minute {minute}.',
      'Good football being played by both sides here.',
      'The crowd at {stadium} are enjoying this encounter.',
      'Neither team giving an inch in this competitive fixture.',
    ];
    
    final template = templates[_random.nextInt(templates.length)];
    return template
        .replaceAll('{stadium}', match.homeTeam.stadium.name)
        .replaceAll('{homeTeam}', match.homeTeam.name)
        .replaceAll('{awayTeam}', match.awayTeam.name)
        .replaceAll('{minute}', match.currentMinute.toString())
        .replaceAll('{weather}', _getWeatherDescription(match.weather));
  }

  /// Home win commentary
  String _getHomeWinCommentary(Match match, String score) {
    final margin = match.homeGoals - match.awayGoals;
    
    if (margin == 1) {
      return 'A narrow but deserved victory for ${match.homeTeam.name}! They edge past ${match.awayTeam.name} $score in a closely fought contest.';
    } else if (margin >= 3) {
      return 'A comprehensive victory for ${match.homeTeam.name}! They sweep aside ${match.awayTeam.name} $score in emphatic fashion.';
    } else {
      return '${match.homeTeam.name} secure a solid $score victory over ${match.awayTeam.name} here at ${match.homeTeam.stadium.name}.';
    }
  }

  /// Away win commentary
  String _getAwayWinCommentary(Match match, String score) {
    final margin = match.awayGoals - match.homeGoals;
    
    if (margin == 1) {
      return 'What a result for ${match.awayTeam.name}! They snatch a crucial $score victory away from home against ${match.homeTeam.name}.';
    } else if (margin >= 3) {
      return 'Stunning! ${match.awayTeam.name} run riot here at ${match.homeTeam.stadium.name}, crushing ${match.homeTeam.name} $score!';
    } else {
      return 'Excellent away performance from ${match.awayTeam.name} as they beat ${match.homeTeam.name} $score on the road.';
    }
  }

  /// Draw commentary
  String _getDrawCommentary(Match match, String score) {
    if (match.homeGoals == 0) {
      return 'A goalless draw here at ${match.homeTeam.stadium.name}. Both defenses stood firm in a tactical battle.';
    } else if (match.homeGoals >= 3) {
      return 'What an entertaining $score draw! Goals galore here at ${match.homeTeam.stadium.name} but neither side could find a winner.';
    } else {
      return 'The points are shared here at ${match.homeTeam.stadium.name}. A $score draw between ${match.homeTeam.name} and ${match.awayTeam.name}.';
    }
  }

  /// Checks if we should comment on statistics
  bool _shouldCommentOnStats(MatchStats stats) {
    final shotDifference = (stats.homeShots - stats.awayShots).abs();
    final possessionDifference = (stats.homePossession - stats.awayPossession).abs();
    
    return shotDifference >= 3 || possessionDifference >= 20;
  }

  /// Checks if we should comment on momentum
  bool _shouldCommentOnMomentum(MomentumTracker momentum) {
    final momentumDifference = (momentum.homeMomentum - momentum.awayMomentum).abs();
    return momentumDifference >= 25;
  }

  /// Initializes commentary templates for different event types
  static Map<String, List<String>> _initializeCommentaryTemplates() {
    return {
      'goal': [
        'GOAL! {player} finds the back of the net for {team}! What a finish!',
        'It\'s in the net! {player} scores for {team}! {homeScore}-{awayScore}!',
        'GOAL! {player} strikes! {team} take the lead here at {stadium}!',
        'What a goal by {player}! {team} are ahead {homeScore}-{awayScore}!',
        '{player} scores! The crowd erupts as {team} find the breakthrough!',
        'GOAL! {player} with a brilliant finish for {team}! {homeScore}-{awayScore}!',
        'It\'s a goal! {player} delivers for {team} in style!',
        '{player} finds the target! {team} celebrate another goal!',
      ],
      'yellowCard': [
        'Yellow card for {player}! The referee shows the first card of the game.',
        '{player} goes into the book for that challenge.',
        'The referee reaches for his pocket - yellow card for {player}.',
        '{player} is cautioned by the referee for that foul.',
        'Yellow card! {player} will have to be careful for the rest of the match.',
        'That\'s a booking for {player} - a deserved yellow card.',
        'The referee shows {player} the yellow card for that infringement.',
      ],
      'redCard': [
        'RED CARD! {player} is sent off! {team} are down to ten men!',
        'It\'s red! {player} has to go! What a moment in this match!',
        'SENT OFF! {player} receives his marching orders from the referee!',
        'Red card for {player}! {team} will have to play the remainder with ten men!',
        'Disaster for {team}! {player} sees red and is dismissed!',
        'The referee shows the red card! {player} is off!',
        '{player} is sent off! {team} are in real trouble now!',
      ],
      'shotOnTarget': [
        'Great shot by {player}! The goalkeeper makes a fine save!',
        '{player} tries his luck but the keeper is equal to it!',
        'Good effort from {player} - saved by the goalkeeper!',
        '{player} forces a save from the keeper with that strike!',
        'Close! {player} almost found the target there!',
        '{player} tests the goalkeeper with a well-struck shot!',
        'Good attempt by {player} but the keeper gathers safely.',
      ],
      'shotOffTarget': [
        '{player} shoots but it\'s wide of the target!',
        'Over the bar! {player} couldn\'t keep his shot down!',
        '{player} blazes it over! A chance goes begging for {team}!',
        'Wide! {player} drags his shot past the post!',
        '{player} shoots but it\'s off target - not troubling the keeper.',
        'Wayward from {player}! That one was never going in!',
        '{player} fires wide - {team} will rue that missed opportunity!',
      ],
      'foul': [
        'Foul by {player}! The referee awards a free kick to {opposition}.',
        '{player} brings down his opponent - free kick {opposition}.',
        'The referee stops play - foul by {player}.',
        '{player} is penalized for that challenge.',
        'Free kick to {opposition} after that foul by {player}.',
        '{player} commits the foul and {opposition} have a set piece.',
        'The referee blows for a foul by {player}.',
      ],
      'corner': [
        'Corner kick for {team}! A good opportunity to create danger!',
        '{team} win a corner - can they capitalize on this set piece?',
        'Corner to {team}! The defenders will need to be alert here.',
        'It\'s a corner for {team} - a chance to test the {opposition} defense!',
        '{team} have a corner kick - all eyes on the penalty area!',
        'Corner for {team}! The goalkeeper punches it away for a set piece.',
        '{team} earn themselves a corner kick here.',
      ],
      'injury': [
        '{player} is down injured. The medical team are attending to the player.',
        'Concern for {player} here - he\'s receiving treatment on the field.',
        '{player} needs medical attention after that challenge.',
        'Play is stopped as {player} requires treatment from the physios.',
        '{player} is hurt and the medics are on the field to assess him.',
        'The referee stops play as {player} needs medical assistance.',
        '{player} is receiving treatment - hopefully it\'s nothing serious.',
      ],
      'tacticalChange': [
        '{team} make a tactical adjustment here at {stadium}.',
        'The manager is making changes - {team} switch their approach.',
        '{team} alter their tactics as they look for a breakthrough.',
        'Tactical switch from {team} - the manager is making his mark.',
        'Interesting change from {team} - they\'re adapting their game plan.',
        '{team} make a formation change as they chase the game.',
        'The tactical battle continues as {team} adjust their setup.',
      ],
      'momentumShift': [
        'The momentum is shifting! {team} are taking control of this match!',
        '{team} are starting to assert their dominance here!',
        'You can feel the tide turning in favor of {team}!',
        '{team} are finding their rhythm and putting pressure on!',
        'The initiative is with {team} now - they\'re on top!',
        '{team} are gaining the upper hand in this encounter!',
        'Momentum swinging toward {team} here at {stadium}!',
      ],
      'substitution': [
        'Substitution for {team} - fresh legs coming on.',
        '{team} make a change - tactical substitution here.',
        'The manager makes his move with this substitution.',
        'Change for {team} as they look to alter the dynamic.',
        'Substitution for {team} - reinforcements coming on.',
        '{team} bring on a substitute - strategic change by the manager.',
        'Fresh impetus for {team} with this substitution.',
      ],
      'save': [
        'Brilliant save! The goalkeeper keeps his team in the game!',
        'What a save! Outstanding reflexes from the keeper!',
        'Superb goalkeeping! He denies {opposition} with that save!',
        'The goalkeeper comes to his team\'s rescue with that save!',
        'Great reflexes! The keeper turns that shot away!',
        'Excellent save! The goalkeeper is keeping {team} in this match!',
        'World-class goalkeeping! What a save that was!',
      ],
      'offside': [
        'Offside! {player} was caught in an offside position.',
        'The flag is up - {player} strayed offside there.',
        'Offside against {player} - the assistant referee spots it.',
        '{player} is flagged for offside - good decision from the linesman.',
        'The flag goes up for offside against {player}.',
        'Offside! {player} was just ahead of the last defender.',
        'Caught offside! {player} timed his run poorly there.',
      ],
    };
  }
}
