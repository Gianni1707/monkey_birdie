import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/profilo.dart';
import '../../l10n/app_localizations.dart';

/// Chip "Developer" mostrato sul profilo (proprio e pubblico) quando
/// `profilo.isDeveloper` (flag `developer` in dati_personali). Discreto.
class BadgeDeveloper extends StatelessWidget {
  const BadgeDeveloper({super.key, required this.profilo});
  final Profilo profilo;

  @override
  Widget build(BuildContext context) {
    if (!profilo.isDeveloper) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.code, size: 14, color: AppColors.onPrimary),
          const SizedBox(width: 5),
          Text(
            l10n.developerBadge,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
