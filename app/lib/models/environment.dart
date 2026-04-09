class Environment {
  const Environment({
    required this.name,
    this.username = 'viam',
    this.password = 'checkmate',
    this.wifiSsid = '',
    this.wifiPassword = '',
    this.timezone = 'America/New_York',
    this.sshPublicKeyFile = '~/.ssh/id_ed25519.pub',
    this.provisionMode = 'os-only',
    this.viamApiKeyId = '',
    this.viamApiKey = '',
    this.viamOrgId = '',
    this.viamLocationId = '',
    this.tailscaleAuthKey = '',
  });

  final String name;
  final String username;
  final String password;
  final String wifiSsid;
  final String wifiPassword;
  final String timezone;
  final String sshPublicKeyFile;
  final String provisionMode;
  final String viamApiKeyId;
  final String viamApiKey;
  final String viamOrgId;
  final String viamLocationId;
  final String tailscaleAuthKey;

  Map<String, String> toEnvMap() => {
        'USERNAME': username,
        'PASSWORD': password,
        'WIFI_SSID': wifiSsid,
        'WIFI_PASSWORD': wifiPassword,
        'TIMEZONE': timezone,
        'SSH_PUBLIC_KEY_FILE': sshPublicKeyFile,
        'PROVISION_MODE': provisionMode,
        'VIAM_API_KEY_ID': viamApiKeyId,
        'VIAM_API_KEY': viamApiKey,
        'VIAM_ORG_ID': viamOrgId,
        'VIAM_LOCATION_ID': viamLocationId,
        'TAILSCALE_AUTH_KEY': tailscaleAuthKey,
      };

  factory Environment.fromEnvMap(String name, Map<String, String> map) {
    return Environment(
      name: name,
      username: map['USERNAME'] ?? 'viam',
      password: map['PASSWORD'] ?? 'checkmate',
      wifiSsid: map['WIFI_SSID'] ?? '',
      wifiPassword: map['WIFI_PASSWORD'] ?? '',
      timezone: map['TIMEZONE'] ?? 'America/New_York',
      sshPublicKeyFile: map['SSH_PUBLIC_KEY_FILE'] ?? '~/.ssh/id_ed25519.pub',
      provisionMode: map['PROVISION_MODE'] ?? 'os-only',
      viamApiKeyId: map['VIAM_API_KEY_ID'] ?? '',
      viamApiKey: map['VIAM_API_KEY'] ?? '',
      viamOrgId: map['VIAM_ORG_ID'] ?? '',
      viamLocationId: map['VIAM_LOCATION_ID'] ?? '',
      tailscaleAuthKey: map['TAILSCALE_AUTH_KEY'] ?? '',
    );
  }

  Environment copyWith({
    String? name,
    String? username,
    String? password,
    String? wifiSsid,
    String? wifiPassword,
    String? timezone,
    String? sshPublicKeyFile,
    String? provisionMode,
    String? viamApiKeyId,
    String? viamApiKey,
    String? viamOrgId,
    String? viamLocationId,
    String? tailscaleAuthKey,
  }) {
    return Environment(
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      timezone: timezone ?? this.timezone,
      sshPublicKeyFile: sshPublicKeyFile ?? this.sshPublicKeyFile,
      provisionMode: provisionMode ?? this.provisionMode,
      viamApiKeyId: viamApiKeyId ?? this.viamApiKeyId,
      viamApiKey: viamApiKey ?? this.viamApiKey,
      viamOrgId: viamOrgId ?? this.viamOrgId,
      viamLocationId: viamLocationId ?? this.viamLocationId,
      tailscaleAuthKey: tailscaleAuthKey ?? this.tailscaleAuthKey,
    );
  }
}
