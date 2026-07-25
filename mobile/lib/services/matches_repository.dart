import '../models/match.dart';
import 'api_client.dart';

class MatchesRepository {
  MatchesRepository(this._client);

  final ApiClient _client;

  Future<List<MatchSummary>> listMatches() async {
    final response = await _client.get('/api/matches');
    return (response as List)
        .map((m) => MatchSummary.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> listMessages(int matchId) async {
    final response = await _client.get('/api/matches/$matchId/messages');
    return (response as List)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(int matchId, String content) async {
    final response = await _client.post(
      '/api/matches/$matchId/messages',
      body: {'content': content},
    );
    return ChatMessage.fromJson(response as Map<String, dynamic>);
  }
}
