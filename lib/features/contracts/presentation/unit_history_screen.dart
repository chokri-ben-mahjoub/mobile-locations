import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';

/// Historique de tous les locataires qui sont passés par un local donné.
class UnitHistoryScreen extends ConsumerWidget {
  final String unitNumber;

  const UnitHistoryScreen({super.key, required this.unitNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final history = ref.watch(contractsForUnitProvider(unitNumber)).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unitHistoryTitle(unitNumber))),
      body: history.isEmpty
          ? Center(child: Text(l10n.noUnitHistory))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final c = history[index];
                final isCurrent = !c.archived &&
                    c.endDate.isAfter(DateTime.now()) &&
                    index == 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => context.push('/contracts/${c.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (c.archived ? scheme.onSurfaceVariant : scheme.primary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                c.archived
                                    ? Icons.history_toggle_off_rounded
                                    : Icons.person_rounded,
                                color: c.archived ? scheme.onSurfaceVariant : scheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.tenantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${FormatUtils.shortDate.format(c.startDate)} → '
                                    '${FormatUtils.shortDate.format(c.endDate)} · '
                                    '${FormatUtils.currency(c.monthlyAmount, currency)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (c.archived ? Colors.grey : Colors.green)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                c.archived
                                    ? l10n.unitHistoryStatusOld
                                    : (isCurrent ? l10n.unitHistoryStatusCurrent : l10n.statusActive),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.archived ? Colors.grey.shade700 : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
