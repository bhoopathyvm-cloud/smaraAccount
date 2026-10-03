import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../domain/linked_devices/join_code.dart';
import '../../../../domain/models/join_qr_payload.dart';
import '../../../../l10n/l10n.dart';
import '../../../core/app_spacing.dart';
import '../../../core/app_typography.dart';

/// Host-side join offer: QR image, optional short join code with countdown,
/// and shared check code (tasks 12.3 / 4.3).
class JoinQrOfferPanel extends StatelessWidget {
  const JoinQrOfferPanel({
    super.key,
    required this.payload,
    this.joinCode,
    this.subtitle,
    this.onCodesDontMatch,
  });

  final JoinQrPayload payload;
  final JoinCode? joinCode;
  final Widget? subtitle;

  /// When set, shows "They don't match" under the check code.
  final VoidCallback? onCodesDontMatch;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.settingsLinkedDevicesJoinSameWifi, style: AppTypography.body),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.small),
          subtitle!,
        ],
        const SizedBox(height: AppSpacing.medium),
        Center(
          child: QrImageView(
            data: payload.encode(),
            size: 220,
            backgroundColor: Colors.white,
          ),
        ),
        if (joinCode != null) ...[
          const SizedBox(height: AppSpacing.medium),
          Text(
            l10n.settingsLinkedDevicesJoinCodeLabel,
            style: AppTypography.metadata,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            joinCode!.display,
            key: const Key('join-code-display'),
            style: AppTypography.sectionLabel.copyWith(
              letterSpacing: 2,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          _JoinCodeCountdown(
            key: const Key('join-code-countdown'),
            expiresAt: joinCode!.expiresAt,
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        Text(
          l10n.settingsLinkedDevicesJoinCheckCode,
          style: AppTypography.metadata,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          payload.checkCode,
          key: const Key('join-qr-check-code'),
          style: AppTypography.sectionLabel.copyWith(
            letterSpacing: 4,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        if (onCodesDontMatch != null) ...[
          const SizedBox(height: AppSpacing.small),
          TextButton(
            key: const Key('join-codes-dont-match'),
            onPressed: onCodesDontMatch,
            child: Text(l10n.settingsLinkedDevicesCodesDontMatch),
          ),
        ],
      ],
    );
  }
}

class _JoinCodeCountdown extends StatefulWidget {
  const _JoinCodeCountdown({super.key, required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_JoinCodeCountdown> createState() => _JoinCodeCountdownState();
}

class _JoinCodeCountdownState extends State<_JoinCodeCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final left = widget.expiresAt.difference(DateTime.now().toUtc());
    setState(() {
      _remaining = left.isNegative ? Duration.zero : left;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final totalSeconds = _remaining.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return Text(
      l10n.settingsLinkedDevicesJoinCodeTimeLeft(minutes, seconds),
      style: AppTypography.metadata,
      textAlign: TextAlign.center,
    );
  }
}
