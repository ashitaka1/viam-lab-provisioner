import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/environment.dart';
import 'env_config.dart';

class EnvironmentRepository {
  EnvironmentRepository(this.repoRoot);

  final String repoRoot;

  String get _configDir => p.join(repoRoot, 'config');
  String get _envDir => p.join(_configDir, 'environments');
  String get _siteEnvPath => p.join(_configDir, 'site.env');

  Future<void> ensureDirectories() async {
    await Directory(_envDir).create(recursive: true);
  }

  Future<List<String>> listEnvironments() async {
    await ensureDirectories();
    final dir = Directory(_envDir);
    final entries = await dir.list().toList();
    return entries
        .whereType<File>()
        .where((f) => f.path.endsWith('.env'))
        .map((f) => p.basenameWithoutExtension(f.path))
        .toList()
      ..sort();
  }

  Future<String?> getActiveEnvironment() async {
    final link = Link(_siteEnvPath);
    if (!await link.exists()) {
      // Check if it's a regular file (not a symlink)
      if (await File(_siteEnvPath).exists()) return null;
      return null;
    }
    final target = await link.target();
    return p.basenameWithoutExtension(target);
  }

  Future<void> setActiveEnvironment(String name) async {
    final link = Link(_siteEnvPath);
    final target = p.join('environments', '$name.env');

    // Remove existing symlink or file
    if (await link.exists() || await File(_siteEnvPath).exists()) {
      await File(_siteEnvPath).delete();
    }

    await link.create(target);
  }

  Future<Environment> loadEnvironment(String name) async {
    final file = File(p.join(_envDir, '$name.env'));
    if (!await file.exists()) {
      return Environment(name: name);
    }
    final contents = await file.readAsString();
    final map = EnvConfig.parse(contents);
    return Environment.fromEnvMap(name, map);
  }

  Future<void> saveEnvironment(Environment env) async {
    await ensureDirectories();
    final file = File(p.join(_envDir, '${env.name}.env'));
    final contents = EnvConfig.serialize(env.toEnvMap());
    await file.writeAsString(contents);
  }

  Future<void> deleteEnvironment(String name) async {
    final file = File(p.join(_envDir, '$name.env'));
    if (await file.exists()) {
      await file.delete();
    }
    // If this was the active env, remove the symlink
    final active = await getActiveEnvironment();
    if (active == name) {
      final link = Link(_siteEnvPath);
      if (await link.exists()) await link.delete();
    }
  }
}
