import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/summary.dart';
import '../../../../domain/shared_categories/category_merge.dart';
import '../../../../domain/shared_categories/category_translate_prompt.dart';
import '../../../../l10n/l10n.dart';

enum ResearchLaunchResult { opened, copied }

/// Rename/add/archive actions for Income/Expense categories. Always
/// watches all categories, including archived ones, so the management
/// screen can show both (Archive a category requirement: archived
/// categories stay visible, just excluded from new-transaction pickers).
///
/// Also the primary, always-available home for monthly-category-limits'
/// month-to-date spent-vs-limit progress (design.md Decision 2), plus
/// shared-category translations / merge / translate-with-AI (tasks 7.1–7.3).
class CategoryManagementViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  CategoryManagementViewModel({
    required CategoryRepository categoryRepository,
    SettingsRepository? settingsRepository,
    this.booksGeneration = 0,
    String? appLocaleTag,
    Future<bool> Function(Uri url)? launchUrlFn,
    Future<void> Function(String text)? copyTextFn,
  }) : _categoryRepository = categoryRepository,
       _settingsRepository = settingsRepository,
       _appLocaleTag = appLocaleTag ?? 'en',
       _launchUrl =
           launchUrlFn ??
           ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication)),
       _copyText =
           copyTextFn ??
           ((text) => Clipboard.setData(ClipboardData(text: text))) {
    _subscription = _categoryRepository
        .watchCategories(includeArchived: true)
        .listen(_onCategories);
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);
    _categoryTotalsSubscription = _categoryRepository
        .watchCategoryTotals(start: firstOfMonth, end: lastOfMonth)
        .listen((totals) {
          _spentByCategoryId = {
            for (final total in totals) total.categoryId: total.totalMinor,
          };
          notifyListeners();
        });
    _loadBooksSettings();
  }

  final CategoryRepository _categoryRepository;
  final SettingsRepository? _settingsRepository;
  final String _appLocaleTag;
  final Future<bool> Function(Uri url) _launchUrl;
  final Future<void> Function(String text) _copyText;

  /// Books-set generation this ViewModel was built for.
  final int booksGeneration;
  late final StreamSubscription<List<Account>> _subscription;
  late final StreamSubscription<List<CategoryTotal>>
  _categoryTotalsSubscription;

  List<Account> _categories = const [];
  List<Account> get categories => _categories;

  Map<String, int> _spentByCategoryId = const {};

  /// This calendar month's spend against [categoryId], or 0 if none yet.
  int monthToDateSpentFor(String categoryId) =>
      _spentByCategoryId[categoryId] ?? 0;

  String _defaultCategoryLocale = 'en';
  String get defaultCategoryLocale => _defaultCategoryLocale;

  Map<String, String> _displayNames = const {};
  Map<String, String> get displayNames => _displayNames;

  List<CategoryMergeCandidate> _suggestedMerges = const [];
  List<CategoryMergeCandidate> get suggestedMerges => _suggestedMerges;

  void _onCategories(List<Account> categories) {
    _categories = categories;
    unawaited(_refreshDisplayNames());
    unawaited(_refreshSuggestedMerges());
    notifyListeners();
  }

  Future<void> _loadBooksSettings() async {
    try {
      _defaultCategoryLocale = await _categoryRepository
          .defaultCategoryLocale();
    } catch (_) {
      _defaultCategoryLocale = 'en';
    }
    notifyListeners();
  }

  Future<void> _refreshDisplayNames() async {
    final names = <String, String>{};
    for (final category in _categories) {
      names[category.id] = await _categoryRepository.displayNameFor(
        category,
        appLocale: _appLocaleTag,
      );
    }
    _displayNames = names;
    notifyListeners();
  }

  Future<void> _refreshSuggestedMerges() async {
    _suggestedMerges = await _categoryRepository.suggestedMerges();
    notifyListeners();
  }

  /// Name shown in lists/pickers for [category] (app-locale then default).
  String displayNameFor(Account category) =>
      _displayNames[category.id] ?? category.name;

  Future<void> setDefaultCategoryLocale(String locale) async {
    await _categoryRepository.setDefaultCategoryLocale(locale);
    _defaultCategoryLocale = locale;
    notifyListeners();
  }

  Future<CategoryMergeCandidate?> setTranslation({
    required String categoryId,
    required String locale,
    required String name,
  }) async {
    final suggestion = await _categoryRepository.setTranslation(
      categoryId: categoryId,
      locale: locale,
      name: name,
    );
    await _refreshDisplayNames();
    await _refreshSuggestedMerges();
    return suggestion;
  }

  Future<void> mergeCategories({
    required String survivorCategoryId,
    required String absorbedCategoryId,
  }) async {
    await _categoryRepository.mergeCategories(
      survivorCategoryId: survivorCategoryId,
      absorbedCategoryId: absorbedCategoryId,
    );
    await _refreshSuggestedMerges();
  }

  /// Hands only the category name to the favourite Research Tool (or clipboard).
  Future<ResearchLaunchResult> translateWithAi(String categoryName) async {
    final settings = _settingsRepository;
    final prompt = buildCategoryTranslatePrompt(categoryName);
    if (settings == null) {
      await _copyText(prompt);
      return ResearchLaunchResult.copied;
    }
    final tool = await settings.selectedResearchTool();
    final uri = categoryTranslateQueryUri(tool, prompt);
    if (uri != null) {
      try {
        final opened = await _launchUrl(uri);
        if (opened) return ResearchLaunchResult.opened;
      } catch (_) {
        // Fall through to copy.
      }
    }
    await _copyText(prompt);
    return ResearchLaunchResult.copied;
  }

  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    try {
      await _categoryRepository.addCategory(name: name, type: type);
      clearFailure();
    } on ArgumentError {
      setFailure(
        const AppFailure(AppErrorCode.validationCategoryMustBeIncomeOrExpense),
      );
    }
  }

  Future<void> renameCategory({required String id, required String newName}) {
    return _categoryRepository.renameCategory(id: id, newName: newName);
  }

  Future<void> archiveCategory(String id) =>
      _categoryRepository.archiveCategory(id);

  Future<void> unarchiveCategory(String id) =>
      _categoryRepository.unarchiveCategory(id);

  /// Sets or clears (`monthlyLimitMinor: null`) a category's monthly
  /// limit. Returns whether it succeeded; a failure (wrong category type,
  /// non-positive amount) surfaces via [errorMessage].
  Future<bool> setCategoryMonthlyLimit({
    required String id,
    required int? monthlyLimitMinor,
  }) async {
    try {
      await _categoryRepository.setCategoryMonthlyLimit(
        id: id,
        monthlyLimitMinor: monthlyLimitMinor,
      );
      clearFailure();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      setFailure(e);
      return false;
    } on ArgumentError {
      setFailure(
        const AppFailure(AppErrorCode.validationOnlyExpenseHasMonthlyLimit),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _categoryTotalsSubscription.cancel();
    super.dispose();
  }
}
