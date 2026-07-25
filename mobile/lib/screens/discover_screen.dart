import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/api_client.dart';
import '../services/discovery_repository.dart';
import '../widgets/mingla_mark.dart';
import '../widgets/profile_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<PublicProfile> _profiles = [];
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
      final profiles = await context.read<DiscoveryRepository>().discover();
      setState(() => _profiles = profiles);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _swipe(PublicProfile profile, bool liked) async {
    setState(() => _profiles.removeWhere((p) => p.id == profile.id));
    try {
      final result = await context
          .read<DiscoveryRepository>()
          .swipe(swipedId: profile.id, liked: liked);
      if (result.matched && mounted) {
        _showMatchDialog(profile);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showMatchDialog(PublicProfile profile) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MinglaMark(size: 48),
            SizedBox(height: 12),
            Text("It's a match!"),
          ],
        ),
        content: Text(
          'You and ${profile.name} liked each other. Say hi in Matches.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Nice!')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.wifi_off_rounded, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_profiles.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Center(child: MinglaMark(size: 48)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "You're all caught up",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Check back later for new people.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    final top = _profiles.first;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Dismissible(
              key: ValueKey(top.id),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) =>
                  _swipe(top, direction == DismissDirection.startToEnd),
              background: _swipeHint(Icons.favorite_rounded, scheme.primary, Alignment.centerLeft),
              secondaryBackground:
                  _swipeHint(Icons.close_rounded, scheme.onSurfaceVariant, Alignment.centerRight),
              child: ProfileCard(profile: top),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'pass',
                elevation: 1,
                onPressed: () => _swipe(top, false),
                child: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant, size: 28),
              ),
              const SizedBox(width: 28),
              FloatingActionButton.large(
                heroTag: 'like',
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 2,
                onPressed: () => _swipe(top, true),
                child: const Icon(Icons.favorite_rounded, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swipeHint(IconData icon, Color color, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Icon(icon, color: color, size: 44),
    );
  }
}
