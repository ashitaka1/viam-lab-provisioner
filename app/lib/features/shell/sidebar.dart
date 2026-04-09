import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/environment_providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEnv = ref.watch(activeEnvironmentProvider);

    return Container(
      color: CupertinoTheme.of(context).barBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Batch header — placeholder until Phase 2
          Expanded(
            child: activeEnv.when(
              data: (env) {
                if (env == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No batch',
                        style: TextStyle(
                          color: CupertinoColors.tertiaryLabel,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No active batch',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a new batch to begin provisioning.',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: CupertinoColors.separator, width: 0.5),
              ),
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(8),
              onPressed: null, // Enabled in Phase 2
              child: const Text(
                'New Batch',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
