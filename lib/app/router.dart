import 'package:flutter/material.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/channels/channel_list_page.dart';
import '../features/peers/peers_page.dart';
import '../features/settings/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import '../mesh/permissions.dart';
import 'dart:async';
import '../features/channels/channel_state.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(builder: (_) => const _RootShell());
      default:
        return MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Center(child: Text('Not found'))));
    }
  }
}

class _RootShell extends ConsumerStatefulWidget {
  const _RootShell();

  @override
  ConsumerState<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<_RootShell> {
  int _idx = 0;
  final List<Widget> _tabs = const <Widget>[
    ChannelListPage(),
    PeersPage(),
    SettingsPage(),
    OnboardingPage(),
  ];
  Timer? _rekeyTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlePermissions.ensureGranted();
      ref.read(advertiserProvider).start();
      ref.read(linkServiceProvider).start();
      ref.read(channelsProvider.notifier).rotateDueKeys();
      _rekeyTimer = Timer.periodic(const Duration(hours: 6), (_) {
        ref.read(channelsProvider.notifier).rotateDueKeys();
      });
    });
  }

  @override
  void dispose() {
    _rekeyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (int i) => setState(() => _idx = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.wifi_tethering), label: 'Peers'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Onboard'),
        ],
      ),
    );
  }
}


