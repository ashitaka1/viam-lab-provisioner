import 'package:flutter_test/flutter_test.dart';
import 'package:viam_provisioner/core/disk_utils.dart';

void main() {
  group('diffDisks', () {
    test('returns only newly-attached disks', () {
      const a = DiskInfo(device: '/dev/disk0', description: 'int', sizeBytes: 1);
      const b = DiskInfo(device: '/dev/disk4', description: 'sd', sizeBytes: 32);
      expect(diffDisks(const [a], const [a, b]), [b]);
    });

    test('returns empty when nothing new attached', () {
      const a = DiskInfo(device: '/dev/disk0', description: 'int', sizeBytes: 1);
      expect(diffDisks(const [a], const [a]), isEmpty);
    });
  });

  group('DiskInfo.sizeHuman', () {
    test('formats GB', () {
      const d = DiskInfo(
        device: '/dev/disk4',
        description: 'sd',
        sizeBytes: 32 * 1024 * 1024 * 1024,
      );
      expect(d.sizeHuman, '32.0 GB');
    });

    test('formats MB', () {
      const d = DiskInfo(
        device: '/dev/disk4',
        description: 'sd',
        sizeBytes: 512 * 1024 * 1024,
      );
      expect(d.sizeHuman, '512.0 MB');
    });
  });
}
