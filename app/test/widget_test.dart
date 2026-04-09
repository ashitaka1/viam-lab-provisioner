import 'package:flutter_test/flutter_test.dart';

import 'package:viam_provisioner/data/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('parse handles key=value pairs', () {
      const input = '''
# Comment
USERNAME=viam
PASSWORD=checkmate
WIFI_SSID=
''';
      final result = EnvConfig.parse(input);
      expect(result['USERNAME'], 'viam');
      expect(result['PASSWORD'], 'checkmate');
      expect(result['WIFI_SSID'], '');
    });

    test('parse strips quotes', () {
      const input = 'KEY="quoted value"';
      final result = EnvConfig.parse(input);
      expect(result['KEY'], 'quoted value');
    });

    test('serialize produces valid env file', () {
      final values = {
        'USERNAME': 'viam',
        'PASSWORD': 'checkmate',
        'WIFI_SSID': '',
        'WIFI_PASSWORD': '',
        'TIMEZONE': 'America/New_York',
        'SSH_PUBLIC_KEY_FILE': '~/.ssh/id_ed25519.pub',
        'PROVISION_MODE': 'os-only',
        'VIAM_API_KEY_ID': '',
        'VIAM_API_KEY': '',
        'VIAM_ORG_ID': '',
        'VIAM_LOCATION_ID': '',
        'TAILSCALE_AUTH_KEY': '',
      };
      final output = EnvConfig.serialize(values);
      final reparsed = EnvConfig.parse(output);
      expect(reparsed['USERNAME'], 'viam');
      expect(reparsed['PROVISION_MODE'], 'os-only');
    });
  });
}
