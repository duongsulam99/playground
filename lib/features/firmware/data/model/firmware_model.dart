import '../../domain/entity/firmware_info.dart';

class FirmwareModel {
  const FirmwareModel({
    required this.versionName,
    required this.buildNumber,
    required this.downloadUrl,
    this.youtubeUrl,
    this.titleVi,
    this.titleEn,
    this.bodyVi = const [],
    this.bodyEn = const [],
    this.imageUrl,
  });

  final String versionName;
  final int buildNumber;
  final String downloadUrl;
  final String? youtubeUrl;
  final String? titleVi;
  final String? titleEn;
  final List<String> bodyVi;
  final List<String> bodyEn;
  final String? imageUrl;

  factory FirmwareModel.fromJson(Map<String, dynamic> json) {
    return FirmwareModel(
      versionName: json['version_name'] as String? ?? '',
      buildNumber: (json['build_number'] as num?)?.toInt() ?? 0,
      downloadUrl: json['path'] as String? ?? '',
      youtubeUrl: (json['youtube_link'] as String?)?.trim(),
      titleVi: json['title_vn'] as String?,
      titleEn: json['title_en'] as String?,
      bodyVi: _parseBody(json['body_vn']),
      bodyEn: _parseBody(json['body_en']),
      imageUrl: json['image_link'] as String?,
    );
  }

  factory FirmwareModel.fromFirestore(Map<String, dynamic> data) {
    return FirmwareModel(
      versionName: data['version_name'] as String? ?? '',
      buildNumber: (data['build_number'] as num?)?.toInt() ?? 0,
      downloadUrl: data['path'] as String? ?? '',
      youtubeUrl: (data['youtube_link'] as String?)?.trim(),
      titleVi: data['title_vn'] as String?,
      titleEn: data['title_en'] as String?,
      bodyVi: _parseBody(data['body_vn']),
      bodyEn: _parseBody(data['body_en']),
      imageUrl: data['image_link'] as String?,
    );
  }

  static List<String> _parseBody(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  FirmwareInfo toEntity() {
    return FirmwareInfo(
      versionName: versionName,
      buildNumber: buildNumber,
      downloadUrl: downloadUrl,
      changelog: FirmwareChangelog(
        titleVi: titleVi,
        titleEn: titleEn,
        bodyVi: bodyVi,
        bodyEn: bodyEn,
        imageUrl: imageUrl,
        youtubeUrl: youtubeUrl,
      ),
    );
  }
}
