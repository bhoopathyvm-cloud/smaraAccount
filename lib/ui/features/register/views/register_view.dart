import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../view_models/register_view_model.dart';
import 'register_row_tile.dart';

/// Views are lean. No business logic, no Repository calls. Listen to the
/// ViewModel; render what it exposes (smara-tech-guidelines.md).
class RegisterView extends StatelessWidget {
  const RegisterView({
    super.key,
    required this.viewModel,
    this.onAddTransaction,
  });

  final RegisterViewModel viewModel;
  final VoidCallback? onAddTransaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'register-fab',
        onPressed: onAddTransaction,
        backgroundColor: AppColors.primary,
        child: const Icon(TablerIcons.plus, color: AppColors.cardBackground),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.rows.isEmpty) {
            return Center(
              child: Text(
                'No transactions yet',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: viewModel.rows.length,
            itemBuilder: (context, index) {
              final row = viewModel.rows[index];
              return RegisterRowTile(
                row: row,
                onReverse: () => viewModel.reverseEntry(row.entryId),
              );
            },
          );
        },
      ),
    );
  }
}
