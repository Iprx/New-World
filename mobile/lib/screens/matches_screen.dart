import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/match.dart';
import '../services/api_client.dart';
import '../services/matches_repository.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<MatchSummary> _matches = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await context.read<MatchesRepository>().listMatches();
      setState(() => _matches = matches);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(_error!)),
        ],
      );
    }
    if (_matches.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No matches yet. Keep swiping!')),
        ],
      );
    }
    return ListView.separated(
      itemCount: _matches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final match = _matches[index];
        final photoUrl = match.otherUser.photos.isNotEmpty
            ? '$apiBaseUrl${match.otherUser.photos.first.url}'
            : null;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text('${match.otherUser.name}, ${match.otherUser.age}'),
          subtitle: Text(match.otherUser.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(matchId: match.id, otherUserName: match.otherUser.name),
            ),
          ),
        );
      },
    );
  }
}
