import 'package:equatable/equatable.dart';

class FirmwareChangelog extends Equatable {
  const FirmwareChangelog({
    this.titleVi,
    this.titleEn,
    this.bodyVi = const [],
    this.bodyEn = const [],
    this.imageUrl,
    this.youtubeUrl,
  });

  final String? titleVi;
  final String? titleEn;
  final List<String> bodyVi;
  final List<String> bodyEn;
  final String? imageUrl;
  final String? youtubeUrl;

  @override
  List<Object?> get props => [
    titleVi,
    titleEn,
    bodyVi,
    bodyEn,
    imageUrl,
    youtubeUrl,
  ];
}

class FirmwareInfo extends Equatable {
  const FirmwareInfo({
    required this.versionName,
    required this.buildNumber,
    required this.downloadUrl,
    required this.changelog,
  });

  final String versionName;
  final int buildNumber;
  final String downloadUrl;
  final FirmwareChangelog changelog;

  bool isUpdateAvailable(String currentVersion) {
    final latest = _parseVersion(versionName);
    final current = _parseVersion(currentVersion);
    if (latest == null || current == null) return false;
    return latest > current;
  }

  double? _parseVersion(String value) {
    try {
      return double.parse(value.trim());
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [versionName, buildNumber, downloadUrl, changelog];
}

class FirmwareCheckResult extends Equatable {
  const FirmwareCheckResult({
    required this.firmwareInfo,
    required this.updateAvailable,
  });

  final FirmwareInfo firmwareInfo;
  final bool updateAvailable;

  @override
  List<Object?> get props => [firmwareInfo, updateAvailable];
}
