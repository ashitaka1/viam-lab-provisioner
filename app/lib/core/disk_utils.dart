import 'dart:io';

class DiskInfo {
  const DiskInfo({
    required this.device,
    required this.description,
    required this.sizeBytes,
  });

  final String device;
  final String description;
  final int sizeBytes;

  String get sizeHuman {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1 << 20) return '$sizeBytes B';
    if (sizeBytes < 1 << 30) {
      return '${(sizeBytes / (1 << 20)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1 << 30)).toStringAsFixed(1)} GB';
  }
}

/// Lists external physical whole disks on macOS (SD cards, USB sticks).
/// Excludes disk images, synthesized APFS containers, and the internal disk.
Future<List<DiskInfo>> listExternalDisks() async {
  final out = await Process.run('/usr/sbin/diskutil', ['list']);
  if (out.exitCode != 0) return const [];
  return _parseDiskutilList(out.stdout as String);
}

/// Parses `diskutil list` text output. Looks for block headers like
/// `/dev/disk4 (external, physical):` and reads the size from the next
/// `0:` entry (e.g. `0: GUID_partition_scheme *32.0 GB disk4`).
List<DiskInfo> _parseDiskutilList(String body) {
  final disks = <DiskInfo>[];
  final blocks = body.split(RegExp(r'(?=^/dev/disk)', multiLine: true));
  for (final block in blocks) {
    final header =
        RegExp(r'^/dev/(disk\d+)\s*\(([^)]*)\):', multiLine: true)
            .firstMatch(block);
    if (header == null) continue;
    final ident = header.group(1)!;
    final kind = header.group(2)!.toLowerCase();
    if (!kind.contains('external') || !kind.contains('physical')) continue;

    final row0 = RegExp(
      r'^\s*0:\s+\S+(?:\s+\S+)*?\s+[\*\+]?([\d.]+)\s+(B|KB|MB|GB|TB)\s+' +
          ident +
          r'\s*$',
      multiLine: true,
    ).firstMatch(block);
    final sizeBytes = row0 == null
        ? 0
        : _humanToBytes(row0.group(1)!, row0.group(2)!);

    disks.add(DiskInfo(
      device: '/dev/$ident',
      description: ident,
      sizeBytes: sizeBytes,
    ));
  }
  return disks;
}

int _humanToBytes(String value, String unit) {
  final n = double.tryParse(value) ?? 0;
  switch (unit.toUpperCase()) {
    case 'TB':
      return (n * (1 << 40)).round();
    case 'GB':
      return (n * (1 << 30)).round();
    case 'MB':
      return (n * (1 << 20)).round();
    case 'KB':
      return (n * 1024).round();
    default:
      return n.round();
  }
}

/// Returns disks present in [after] that weren't in [before] (by device path).
List<DiskInfo> diffDisks(List<DiskInfo> before, List<DiskInfo> after) {
  final beforeDevices = before.map((d) => d.device).toSet();
  return after.where((d) => !beforeDevices.contains(d.device)).toList();
}
