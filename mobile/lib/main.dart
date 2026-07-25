import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/discovery_repository.dart';
import 'services/matches_repository.dart';
import 'services/profile_repository.dart';

void main() {
  runApp(const MinglaApp());
}

class MinglaApp extends StatelessWidget {
  const MinglaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthService(apiClient)..bootstrap()),
        Provider(create: (_) => DiscoveryRepository(apiClient)),
        Provider(create: (_) => MatchesRepository(apiClient)),
        Provider(create: (_) => ProfileRepository(apiClient)),
      ],
      child: MaterialApp(
        title: 'Mingla',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.pinkAccent,
          useMaterial3: true,
        ),
        home: const _RootScreen(),
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.isAuthenticated) {
      return const HomeShell();
    }
    return const LoginScreen();
  }
}
