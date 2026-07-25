import '../models/profile.dart';
import 'api_client.dart';

class SwipeResult {
  final bool matched;
  final int? matchId;

  SwipeResult({required this.matched, this.matchId});

  factory SwipeResult.fromJson(Map<String, dynamic> json) => SwipeResult(
        matched: json['matched'] as bool,
        matchId: json['match_id'] as int?,
      );
}

class DiscoveryRepository {
  DiscoveryRepository(this._client);

  final ApiClient _client;

  Future<List<PublicProfile>> discover({int limit = 20}) async {
    final response = await _client.get('/api/discover', query: {'limit': limit});
    return (response as List)
        .map((p) => PublicProfile.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<SwipeResult> swipe({required int swipedId, required bool liked}) async {
    final response = await _client.post('/api/swipes', body: {
      'swiped_id': swipedId,
      'liked': liked,
    });
    return SwipeResult.fromJson(response as Map<String, dynamic>);
  }
}
