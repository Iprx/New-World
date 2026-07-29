import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/match.dart';
import '../services/api_client.dart';
import '../services/matches_repository.dart';
import '../widgets/mingla_mark.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  List<MatchSummary> _matches = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Re-fetches the match list. Called by [HomeShell] when this tab is
  /// re-selected, since the list is otherwise only loaded once.
  Future<void> reload() => _load();

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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      );
    }
    if (_matches.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Center(child: MinglaMark(size: 48)),
          const SizedBox(height: 20),
          Center(child: Text('No matches yet', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 6),
          Center(child: Text('Keep swiping to find your people.', style: Theme.of(context).textTheme.bodySmall)),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _matches.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
      itemBuilder: (context, index) {
        final match = _matches[index];
        final photoUrl = match.otherUser.photos.isNotEmpty
            ? '$apiBaseUrl${match.otherUser.photos.first.url}'
            : null;
        final scheme = Theme.of(context).colorScheme;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: scheme.primary, width: 2)),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: scheme.surfaceContainerHighest,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? Icon(Icons.person, color: scheme.onSurfaceVariant) : null,
            ),
          ),
          title: Text('${match.otherUser.name}, ${match.otherUser.age}', style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            match.otherUser.bio.isEmpty ? 'Say hi!' : match.otherUser.bio,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
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
