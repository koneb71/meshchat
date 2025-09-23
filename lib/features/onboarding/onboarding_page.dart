import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/identity_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(identityProvider);
    _name.text = id?.displayName ?? _name.text;
    final String safety = id?.safetyNumber ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                FilledButton(
                  onPressed: () async {
                    final String name = _name.text.trim();
                    if (name.isEmpty) return;
                    await ref.read(identityProvider.notifier).setDisplayName(name);
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: safety.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: safety));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safety number copied')));
                          }
                        },
                  child: const Text('Copy Safety #'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Safety Number', style: TextStyle(fontWeight: FontWeight.w700)),
            if (safety.isNotEmpty) ...<Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(safety),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: QrImageView(data: safety, size: 180)),
            ] else
              const Text('Set a display name to generate a safety number.'),
            const Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Quick Setup', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    FutureBuilder<List<_CheckItem>>(
                      future: _checks(),
                      builder: (BuildContext _, AsyncSnapshot<List<_CheckItem>> snap) {
                        final List<_CheckItem> items = snap.data ?? const <_CheckItem>[];
                        return Column(children: items.map((e) => ListTile(leading: Icon(e.ok ? Icons.check_circle : Icons.error, color: e.ok ? Colors.green : Colors.orange), title: Text(e.title), trailing: e.action)).toList());
                      },
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Tip: Use Settings to edit later. Export/import identity coming next.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem {
  final String title;
  final bool ok;
  final Widget? action;
  const _CheckItem(this.title, this.ok, [this.action]);
}

Future<List<_CheckItem>> _checks() async {
  final List<_CheckItem> list = <_CheckItem>[];
  final bool btScan = await Permission.bluetoothScan.isGranted || (await Permission.bluetoothScan.request()).isGranted;
  final bool btConn = await Permission.bluetoothConnect.isGranted || (await Permission.bluetoothConnect.request()).isGranted;
  final bool btAdv = await Permission.bluetoothAdvertise.isGranted || (await Permission.bluetoothAdvertise.request()).isGranted;
  final bool loc = await Permission.location.isGranted || (await Permission.location.request()).isGranted;
  final bool ignoreBatt = await Permission.ignoreBatteryOptimizations.isGranted;
  list.add(_CheckItem('Bluetooth Scan permission', btScan));
  list.add(_CheckItem('Bluetooth Connect permission', btConn));
  list.add(_CheckItem('Bluetooth Advertise permission', btAdv));
  list.add(_CheckItem('Location permission (Android <12 or vendor‑required)', loc));
  list.add(_CheckItem('Battery optimization disabled', ignoreBatt, TextButton(onPressed: () => Permission.ignoreBatteryOptimizations.request(), child: const Text('Allow'))));
  return list;
}
