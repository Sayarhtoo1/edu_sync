import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

class FinancialSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;

  const FinancialSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: '');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financialSummaryTitle,
              style: textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2C2C2C),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialDetailRow(
              l10n.totalIncomeLabel,
              currencyFormat.format(totalIncome),
              const Color(0xFF4CAF50),
              textTheme,
            ),
            const SizedBox(height: 8),
            _buildFinancialDetailRow(
              l10n.totalExpensesLabel,
              currencyFormat.format(totalExpenses),
              const Color(0xFFFFA726),
              textTheme,
            ),
            const Divider(height: 24, thickness: 1),
            _buildFinancialDetailRow(
              l10n.netBalanceLabel,
              currencyFormat.format(netBalance),
              netBalance >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFFA726),
              textTheme,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDetailRow(
    String label,
    String value,
    Color valueColor,
    TextTheme textTheme, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8C8C8C),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}