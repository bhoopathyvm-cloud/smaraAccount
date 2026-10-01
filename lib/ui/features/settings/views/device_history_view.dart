import '../../../core/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/membership_notice.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';
import '../view_models/device_history_view_model.dart';

/// Lists Continuation and membership notices in household wording.
class DeviceHistoryView extends StatelessWidget {
  const DeviceHistoryView({super.key, required this.viewModel});

  final DeviceHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final dateFormat = mediumDateFormatFor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deviceHistoryTitle, style: AppTypography.headerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cardBackground,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final items = viewModel.items;
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Text(l10n.deviceHistoryEmpty, style: AppTypography.body),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.large),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              final item = items[index];
              return Text(
                _labelFor(l10n, dateFormat, item),
                style: AppTypography.body,
              );
            },
          );
        },
      ),
    );
  }

  String _labelFor(
    AppLocalizations l10n,
    DateFormat dateFormat,
    DeviceHistoryItem item,
  ) {
    switch (item.kind) {
      case DeviceHistoryKind.continuation:
        final continued = dateFormat.format(item.continuedAt!.toLocal());
        return item.copySavedAt == null
            ? l10n.deviceHistoryContinuedOn(continued)
            : l10n.deviceHistoryContinuedFromCopy(
                continued,
                dateFormat.format(item.copySavedAt!.toLocal()),
              );
      case DeviceHistoryKind.membershipNotice:
        return membershipNoticeLabel(l10n, dateFormat, item.notice!);
    }
  }
}

String membershipNoticeLabel(
  AppLocalizations l10n,
  DateFormat dateFormat,
  MembershipNotice notice,
) {
  final name = notice.relatedDisplayName ?? notice.relatedDeviceId ?? '';
  return switch (notice.kind) {
    MembershipNoticeKind.deviceAdded => l10n.membershipNoticeDeviceAdded(name),
    MembershipNoticeKind.deviceRemoved => l10n.membershipNoticeDeviceRemoved(
      name,
    ),
    MembershipNoticeKind.erasePending => l10n.membershipNoticeErasePending(
      name,
    ),
    MembershipNoticeKind.erased => l10n.membershipNoticeErased(
      name,
      notice.detail != null
          ? dateFormat.format(DateTime.parse(notice.detail!).toLocal())
          : dateFormat.format(notice.createdAt.toLocal()),
    ),
    MembershipNoticeKind.soleOwnerClaimed =>
      l10n.membershipNoticeSoleOwnerClaimed(name),
    MembershipNoticeKind.soleOwnerClaimCancelled =>
      l10n.membershipNoticeSoleOwnerCancelled(name),
    MembershipNoticeKind.soleOwnerClaimEffective =>
      l10n.membershipNoticeSoleOwnerEffective(name),
    MembershipNoticeKind.entryNotAccepted =>
      notice.detail ?? l10n.membershipNoticeEntryNotAccepted(name),
    MembershipNoticeKind.ownerVerificationAlert =>
      notice.detail ?? l10n.membershipNoticeOwnerVerificationAlert(name),
    MembershipNoticeKind.competingFixCheck =>
      notice.detail ?? l10n.membershipNoticeCompetingFixCheck,
  };
}
