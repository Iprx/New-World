import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../services/api_client.dart';
import '../services/discovery_repository.dart';
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
        title: const Text("It's a match!"),
        content: Text('You and ${profile.name} liked each other. Say hi in Matches.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Nice!')),
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
          Center(child: Text(_error!)),
          const SizedBox(height: 12),
          Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_profiles.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text("You're all caught up. Check back later!")),
        ],
      );
    }

    final top = _profiles.first;
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
              background: _swipeHint(Icons.favorite, Colors.green, Alignment.centerLeft),
              secondaryBackground: _swipeHint(Icons.close, Colors.red, Alignment.centerRight),
              child: ProfileCard(profile: top),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'pass',
                backgroundColor: Colors.white,
                onPressed: () => _swipe(top, false),
                child: const Icon(Icons.close, color: Colors.red),
              ),
              FloatingActionButton(
                heroTag: 'like',
                backgroundColor: Colors.white,
                onPressed: () => _swipe(top, true),
                child: const Icon(Icons.favorite, color: Colors.green),
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
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 48),
    );
  }
}
