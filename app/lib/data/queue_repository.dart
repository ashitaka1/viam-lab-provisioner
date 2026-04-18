import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/queue_entry.dart';

class QueueRepository {
  QueueRepository(this.repoRoot);
  final String repoRoot;

  String get machinesDir => p.join(repoRoot, 'http-server', 'machines');
  String get _queuePath => p.join(machinesDir, 'queue.json');
  String get _batchMetaPath => p.join(machinesDir, 'batch.json');

  Future<List<QueueEntry>> loadQueue() async {
    final file = File(_queuePath);
    if (!await file.exists()) return const [];
    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list
          .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return const [];
    }
  }

  Future<String?> loadTargetType() async {
    final file = File(_batchMetaPath);
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['target_type'] as String?;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveTargetType(String targetType) async {
    await Directory(machinesDir).create(recursive: true);
    final file = File(_batchMetaPath);
    await file.writeAsString(jsonEncode({'target_type': targetType}));
  }

  /// Marks the named machine as assigned in queue.json. Used by the Pi
  /// flash flow (x86 machines get marked by the PXE watcher instead).
  Future<void> markAssigned(String name) async {
    final entries = await loadQueue();
    final updated = [
      for (final e in entries)
        {
          'name': e.name,
          'assigned': e.name == name ? true : e.assigned,
          if (e.mac != null) 'mac': e.mac,
          if (e.slotId != null) 'slot_id': e.slotId,
        },
    ];
    await File(_queuePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(updated),
    );
  }
}
