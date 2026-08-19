import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../domain/models/journal_entry.dart'
    show VerificationBreakReason;
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../../../core/money_formatter.dart';
import '../view_models/register_row.dart';

/// One row in the register. Direction is never color-coded (design
/// system): icon + sign + label only, rendered in neutral primary text
/// unless the account would go negative or the entry is quarantined. A
/// null [onTap] renders the row without a tap target at all (not just a
/// disabled one) - fix-this-correction-wizard only offers Fix on ordinary
/// category transactions, not transfers or opening balances.
class RegisterRowTile extends StatelessWidget {
  const RegisterRowTile({super.key, required this.row, this.onTap});

  final RegisterRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMoneyIn = row.direction == TransactionDirection.moneyIn;
    final amountText =
        '${isMoneyIn ? '+' : '−'}${formatAmountMinor(row.amountMinor, row.currency)}';
    final isNegativeBalance = row.runningBalanceMinor < 0;
    final isQuarantined = !row.isVerified;
    final isSuperseded = row.isSupersededByMigration;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.small,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isQuarantined || isNegativeBalance
                    ? AppColors.signal
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            children: [
              Icon(
                isMoneyIn ? TablerIcons.arrowDown : TablerIcons.arrowUp,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(row.categoryName, style: AppTypography.cardTitle),
                        if (row.isReversal) ...[
                          const SizedBox(width: AppSpacing.small),
                          Icon(
                            TablerIcons.cornerUpLeft,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ],
                        if (isQuarantined) ...[
                          const SizedBox(width: AppSpacing.small),
                          Icon(
                            TablerIcons.lock,
                            size: 14,
                            color: AppColors.signal,
                          ),
                        ],
                        if (isSuperseded) ...[
                          const SizedBox(width: AppSpacing.small),
                          Icon(
                            TablerIcons.history,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ],
                    ),
                    if (isQuarantined)
                      Text(
                        'Unverified - excluded from totals',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.signal,
                        ),
                      ),
                    if (isSuperseded)
                      Text(
                        'Superseded by migration - excluded from totals',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    Text(
                      '${row.transactionDate.year}-${row.transactionDate.month.toString().padLeft(2, '0')}-${row.transactionDate.day.toString().padLeft(2, '0')}'
                      '${row.description != null ? ' · ${row.description}' : ''}',
                      style: AppTypography.metadata,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amountText, style: AppTypography.body),
                  Text(
                    formatAmountMinor(row.runningBalanceMinor, row.currency),
                    style: AppTypography.metadata,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Register row - money in')
Widget registerRowMoneyInPreview() {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: RegisterRowTile(
      row: RegisterRow(
        entryId: '1',
        categoryName: 'Salary',
        counterpartAccountIds: const ['category-salary'],
        currency: 'USD',
        direction: TransactionDirection.moneyIn,
        amountMinor: 250000,
        transactionDate: DateTime(2026, 1, 15),
        description: 'January pay',
        runningBalanceMinor: 250000,
        isReversal: false,
        isVerified: true,
        breakReason: null,
        isSupersededByMigration: false,
      ),
    ),
  );
}

@Preview(name: 'Register row - negative balance')
Widget registerRowNegativeBalancePreview() {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: RegisterRowTile(
      row: RegisterRow(
        entryId: '2',
        categoryName: 'Rent/Mortgage',
        counterpartAccountIds: const ['category-rent'],
        currency: 'USD',
        direction: TransactionDirection.moneyOut,
        amountMinor: 300000,
        transactionDate: DateTime(2026, 1, 16),
        description: null,
        runningBalanceMinor: -50000,
        isReversal: false,
        isVerified: true,
        breakReason: null,
        isSupersededByMigration: false,
      ),
    ),
  );
}

@Preview(name: 'Register row - quarantined')
Widget registerRowQuarantinedPreview() {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: RegisterRowTile(
      row: RegisterRow(
        entryId: '3',
        categoryName: 'Groceries',
        counterpartAccountIds: const ['category-groceries'],
        currency: 'USD',
        direction: TransactionDirection.moneyOut,
        amountMinor: 4500,
        transactionDate: DateTime(2026, 1, 17),
        description: null,
        runningBalanceMinor: -50000,
        isReversal: false,
        isVerified: false,
        breakReason: VerificationBreakReason.hashMismatch,
        isSupersededByMigration: false,
      ),
    ),
  );
}

@Preview(name: 'Register row - superseded by migration')
Widget registerRowSupersededPreview() {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: RegisterRowTile(
      row: RegisterRow(
        entryId: '4',
        categoryName: 'Groceries',
        counterpartAccountIds: const ['category-groceries'],
        currency: 'USD',
        direction: TransactionDirection.moneyOut,
        amountMinor: 4500,
        transactionDate: DateTime(2026, 1, 10),
        description: null,
        runningBalanceMinor: -50000,
        isReversal: false,
        isVerified: true,
        breakReason: null,
        isSupersededByMigration: true,
      ),
    ),
  );
}
