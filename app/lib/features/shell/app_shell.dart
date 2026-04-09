import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/environment_providers.dart';
import '../settings/settings_drawer.dart';
import 'toolbar.dart';
import 'sidebar.dart';

final selectedStageProvider = StateProvider<int>((ref) => 0);
final settingsOpenProvider = StateProvider<bool>((ref) => false);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsOpen = ref.watch(settingsOpenProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          const Toolbar(),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 240, child: Sidebar()),
                Container(width: 1, color: CupertinoColors.separator),
                const Expanded(child: _MainPanel()),
                if (settingsOpen) ...[
                  Container(width: 1, color: CupertinoColors.separator),
                  const SizedBox(width: 320, child: SettingsDrawer()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainPanel extends ConsumerWidget {
  const _MainPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEnv = ref.watch(activeEnvironmentProvider);

    return activeEnv.when(
      data: (env) {
        if (env == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.gear_alt,
                    size: 48,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No environment selected',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Open Settings to create or select an environment.',
                    style: TextStyle(color: CupertinoColors.tertiaryLabel),
                  ),
                ],
              ),
            ),
          );
        }
        // Placeholder for batch stages — will be implemented in Phase 2
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.cube_box,
                size: 48,
                color: CupertinoColors.secondaryLabel,
              ),
              const SizedBox(height: 16),
              Text(
                'Environment: ${env.name}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Mode: ${env.provisionMode}',
                style: const TextStyle(color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create a new batch to get started.',
                style: TextStyle(color: CupertinoColors.tertiaryLabel),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
