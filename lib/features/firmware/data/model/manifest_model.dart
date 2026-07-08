class ManifestModel {
  const ManifestModel({
    required this.formatVersion,
    required this.time,
    required this.files,
  });

  final int formatVersion;
  final int time;
  final List<ManifestFileModel> files;

  factory ManifestModel.fromJson(Map<String, dynamic> json) {
    final files = (json['files'] as List<dynamic>)
        .map((e) => ManifestFileModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (files.length > 1) {
      for (final file in files) {
        if (file.imageIndex == null) {
          throw const FormatException(
            'imageIndex is required for multi-image firmware',
          );
        }
      }
    }

    return ManifestModel(
      formatVersion: json['format-version'] as int,
      time: json['time'] as int,
      files: files,
    );
  }
}

class ManifestFileModel {
  const ManifestFileModel({
    required this.file,
    this.type,
    this.board,
    this.soc,
    this.loadAddress,
    this.versionMcuboot,
    this.serialRecoveryIndex,
    this.size,
    this.modtime,
    this.version,
    this.imageIndex,
  });

  final String? type;
  final String? board;
  final String? soc;
  final int? loadAddress;
  final String? versionMcuboot;
  final String? serialRecoveryIndex;
  final int? size;
  final int? modtime;
  final String? version;
  final String file;
  final String? imageIndex;

  int get image => int.parse(imageIndex ?? '0');

  factory ManifestFileModel.fromJson(Map<String, dynamic> json) {
    return ManifestFileModel(
      type: json['type'] as String?,
      board: json['board'] as String?,
      soc: json['soc'] as String?,
      loadAddress: json['load_address'] as int?,
      versionMcuboot: json['version_MCUBOOT'] as String?,
      serialRecoveryIndex: json['serial_recovery_index'] as String?,
      size: json['size'] as int?,
      modtime: json['modtime'] as int?,
      version: json['version'] as String?,
      file: json['file'] as String,
      imageIndex: json['image_index'] as String?,
    );
  }
}
