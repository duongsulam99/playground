/// Raw dimension values. Mapped via [AppDimensions.standard].
class DimensionTokens {
  const DimensionTokens({
    required this.spacing4,
    required this.spacing8,
    required this.spacing12,
    required this.spacing16,
    required this.spacing20,
    required this.spacing24,
    required this.spacing32,
    required this.radius4,
    required this.radius8,
    required this.radius12,
    required this.radius16,
    required this.icon16,
    required this.icon20,
    required this.icon24,
  });

  final double spacing4;
  final double spacing8;
  final double spacing12;
  final double spacing16;
  final double spacing20;
  final double spacing24;
  final double spacing32;
  final double radius4;
  final double radius8;
  final double radius12;
  final double radius16;
  final double icon16;
  final double icon20;
  final double icon24;

  static const standard = DimensionTokens(
    spacing4: 4,
    spacing8: 8,
    spacing12: 12,
    spacing16: 16,
    spacing20: 20,
    spacing24: 24,
    spacing32: 32,
    radius4: 4,
    radius8: 8,
    radius12: 12,
    radius16: 16,
    icon16: 16,
    icon20: 20,
    icon24: 24,
  );
}
