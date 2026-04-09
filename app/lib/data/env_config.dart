class EnvConfig {
  static Map<String, String> parse(String contents) {
    final result = <String, String>{};
    for (final line in contents.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex < 0) continue;
      final key = trimmed.substring(0, eqIndex).trim();
      var value = trimmed.substring(eqIndex + 1).trim();
      // Strip surrounding quotes
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      result[key] = value;
    }
    return result;
  }

  static String serialize(Map<String, String> values) {
    final sections = <String, List<String>>{
      '# --- OS account ---': ['USERNAME', 'PASSWORD'],
      '# --- Network ---': ['WIFI_SSID', 'WIFI_PASSWORD', 'TIMEZONE'],
      '# --- SSH ---': ['SSH_PUBLIC_KEY_FILE'],
      '# --- Viam Cloud ---': [
        'PROVISION_MODE',
        'VIAM_API_KEY_ID',
        'VIAM_API_KEY',
        'VIAM_ORG_ID',
        'VIAM_LOCATION_ID',
      ],
      '# --- Tailscale ---': ['TAILSCALE_AUTH_KEY'],
    };

    final buf = StringBuffer();
    final written = <String>{};

    for (final entry in sections.entries) {
      buf.writeln(entry.key);
      for (final key in entry.value) {
        final value = values[key] ?? '';
        buf.writeln('$key=$value');
        written.add(key);
      }
      buf.writeln();
    }

    // Write any remaining keys not in known sections
    for (final entry in values.entries) {
      if (!written.contains(entry.key)) {
        buf.writeln('${entry.key}=${entry.value}');
      }
    }

    return buf.toString();
  }
}
