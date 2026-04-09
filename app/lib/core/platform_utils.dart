import 'dart:io';

Future<ProcessResult> runPrivileged(
  String executable,
  List<String> arguments,
) async {
  final command = [executable, ...arguments]
      .map((a) => a.contains(' ') ? "'$a'" : a)
      .join(' ');

  return Process.run(
    'osascript',
    ['-e', 'do shell script "$command" with administrator privileges'],
  );
}

Future<List<String>> listNetworkInterfaces() async {
  final result = await Process.run(
    'networksetup',
    ['-listallhardwareports'],
  );
  final lines = (result.stdout as String).split('\n');
  final interfaces = <String>[];
  for (final line in lines) {
    if (line.startsWith('Device: ')) {
      interfaces.add(line.substring(8).trim());
    }
  }
  return interfaces;
}

Future<String?> defaultEthernetInterface() async {
  final result = await Process.run(
    'networksetup',
    ['-listallhardwareports'],
  );
  final output = result.stdout as String;
  final sections = output.split('\n\n');
  for (final section in sections) {
    if (section.contains('Ethernet') || section.contains('Thunderbolt')) {
      final deviceMatch = RegExp(r'Device:\s*(\S+)').firstMatch(section);
      if (deviceMatch != null) return deviceMatch.group(1);
    }
  }
  return null;
}
