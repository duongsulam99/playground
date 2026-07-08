import 'package:flutter/material.dart';

import '../../domain/entity/firmware_info.dart';

class FirmwareChangelogSection extends StatelessWidget {
  const FirmwareChangelogSection({required this.changelog, super.key});

  final FirmwareChangelog changelog;

  @override
  Widget build(BuildContext context) {
    final title = _resolveTitle();
    final bullets = _resolveBullets();

    if (title == null && bullets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s new',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
            if (bullets.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...bullets.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _resolveTitle() {
    final en = changelog.titleEn?.trim();
    if (en != null && en.isNotEmpty) return en;
    final vi = changelog.titleVi?.trim();
    if (vi != null && vi.isNotEmpty) return vi;
    return null;
  }

  List<String> _resolveBullets() {
    if (changelog.bodyEn.isNotEmpty) return changelog.bodyEn;
    return changelog.bodyVi;
  }
}
