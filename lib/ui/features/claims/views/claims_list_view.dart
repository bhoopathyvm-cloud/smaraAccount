import 'package:flutter/material.dart';

import '../view_models/claims_list_view_model.dart';

/// Claimant home: own claims, balance copy, advances.
class ClaimsListView extends StatelessWidget {
  const ClaimsListView({super.key, required this.viewModel});

  final ClaimsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Claims')),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await viewModel.createDraft();
              await viewModel.load();
            },
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                viewModel.balanceCopy(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (viewModel.balanceMinor != 0)
                Text(
                  (viewModel.balanceMinor.abs() / 100).toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              const SizedBox(height: 16),
              if (viewModel.advances.isNotEmpty) ...[
                Text('Advances', style: Theme.of(context).textTheme.titleSmall),
                ...viewModel.advances.map(
                  (a) => ListTile(
                    title: Text((a.amountMinor / 100).toStringAsFixed(2)),
                    subtitle: Text(a.description ?? 'Advance'),
                  ),
                ),
                const Divider(),
              ],
              if (viewModel.items.isEmpty)
                const Text('No claims yet.')
              else
                ...viewModel.items.map(
                  (c) => ListTile(
                    title: Text(ClaimsListViewModel.statusLabel(c.status)),
                    subtitle: Text(
                      '${c.items.length} item(s) · ${c.id.substring(0, 8)}',
                    ),
                  ),
                ),
              if (viewModel.error != null)
                Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        );
      },
    );
  }
}
