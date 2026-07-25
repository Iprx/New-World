import 'profile.dart';

class MatchSummary {
  final int id;
  final PublicProfile otherUser;
  final DateTime createdAt;

  MatchSummary({
    required this.id,
    required this.otherUser,
    required this.createdAt,
  });

  factory MatchSummary.fromJson(Map<String, dynamic> json) => MatchSummary(
        id: json['id'] as int,
        otherUser:
            PublicProfile.fromJson(json['other_user'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ChatMessage {
  final int id;
  final int matchId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        matchId: json['match_id'] as int,
        senderId: json['sender_id'] as int,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
