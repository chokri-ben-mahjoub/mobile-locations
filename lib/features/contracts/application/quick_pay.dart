import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import 'contracts_providers.dart';

/// Encaisse en un geste le loyer du mois en cours, avec retour haptique et
/// possibilité d'annuler depuis le snackbar.
Future<void> quickPayCurrentMonth(
  BuildContext context,
  WidgetRef ref,
  Contract contract,
) async {
  final controller = ref.read(paymentsControllerProvider);
  final currency = ref.read(currencyProvider);
  final now = DateTime.now();
  final month = DateTime(now.year, now.month, 1);
  final messenger = ScaffoldMessenger.of(context);

  await controller.markPaid(
    contractId: contract.id,
    month: month,
    amount: contract.monthlyAmount,
    paidDate: now,
  );
  HapticFeedback.heavyImpact();

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${contract.unitNumber} · ${FormatUtils.currency(contract.monthlyAmount, currency)} encaissé',
        ),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => controller.markUnpaid(contract.id, month),
        ),
      ),
    );
}
