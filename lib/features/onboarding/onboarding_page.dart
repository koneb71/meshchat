import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/identity_provider.dart';

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
