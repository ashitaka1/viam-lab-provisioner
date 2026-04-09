import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/shell/app_shell.dart';
import 'theme/theme.dart';

class ViamProvisionerApp extends ConsumerWidget {
  const ViamProvisionerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return CupertinoApp(
      title: 'Viam Provisioner',
      theme: cupertinoTheme(brightness),
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
