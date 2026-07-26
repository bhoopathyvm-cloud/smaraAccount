import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/exchange_rate_provider.dart';

/// The app's first Settings surface: the reference exchange-rate lookup's
/// enable/disable toggle and predefined-provider selection (design.md
/// Decision 5). Deliberately minimal - not a general preferences screen.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository {
    _load();
  }

  final SettingsRepository _settingsRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _referenceRateLookupEnabled = false;
  bool get referenceRateLookupEnabled => _referenceRateLookupEnabled;

  ExchangeRateProvider _selectedProvider = ExchangeRateProvider.values.first;
  ExchangeRateProvider get selectedProvider => _selectedProvider;

  Future<void> _load() async {
    _referenceRateLookupEnabled = await _settingsRepository
        .isReferenceRateLookupEnabled();
    _selectedProvider = await _settingsRepository.selectedProvider();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setReferenceRateLookupEnabled(bool value) async {
    _referenceRateLookupEnabled = value;
    notifyListeners();
    await _settingsRepository.setReferenceRateLookupEnabled(value);
  }

  Future<void> setSelectedProvider(ExchangeRateProvider provider) async {
    _selectedProvider = provider;
    notifyListeners();
    await _settingsRepository.setSelectedProvider(provider);
  }
}
