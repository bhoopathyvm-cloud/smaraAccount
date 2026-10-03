import 'package:flutter/material.dart';
import 'package:smara_accounting/l10n/l10n.dart';

/// Personal / company claim limits list (tasks 6.3 + Claimant "my limits").
///
/// Owner viewing another person: [viewerIsOwner] true.
/// Claimant viewing self: [viewerIsOwner] false with [allowClaimantSelf] true.
/// Anyone else: refused.
class PersonalClaimLimitsPage extends StatelessWidget {
  const PersonalClaimLimitsPage({
    super.key,
    required this.personName,
    required this.lines,
    this.companyLines = const [],
    this.viewerIsOwner = true,
    this.allowClaimantSelf = false,
  });

  final String personName;

  /// Personal limit lines (e.g. "Hotel 120 per night").
  final List<String> lines;

  /// Company-wide limit lines shown to the Claimant alongside their own.
  final List<String> companyLines;

  final bool viewerIsOwner;

  /// When true, a non-Owner may view [lines] + [companyLines] for themselves.
  final bool allowClaimantSelf;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final allowed = viewerIsOwner || allowClaimantSelf;
    if (!allowed) {
      return Scaffold(
        appBar: AppBar(title: Text(personName)),
        body: Center(child: Text(l10n.actionCancel)),
      );
    }
    final title = allowClaimantSelf && !viewerIsOwner
        ? l10n.claimsMyLimitsTitle
        : l10n.claimsPersonalLimitsTitleFor(personName);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        key: const Key('personal-claim-limits-title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lines.isEmpty && companyLines.isEmpty)
            Center(child: Text(l10n.claimsNoPersonalLimits))
          else ...[
            if (lines.isNotEmpty) ...[
              Text(
                l10n.claimsPersonalLimitsHeading,
                key: const Key('personal-limits-heading'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final line in lines)
                ListTile(key: Key('limit-line-$line'), title: Text(line)),
            ],
            if (companyLines.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.claimsCompanyLimitsHeading,
                key: const Key('company-limits-heading'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final line in companyLines)
                ListTile(
                  key: Key('company-limit-line-$line'),
                  title: Text(line),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
