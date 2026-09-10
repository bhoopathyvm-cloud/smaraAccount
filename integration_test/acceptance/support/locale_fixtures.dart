/// Test-authored strings the acceptance suite types into the app during a
/// run - a new group/account name, a first-week-setup account name, a
/// recurring-template name, a payee name, and a description/search-term
/// pair. None of these have an existing `AppLocalizations` entry (unlike
/// the app's own seeded system names - "Salary", "Cash & Bank", etc. -
/// which the suite resolves directly via `lib/l10n/system_name_localizer.dart`
/// instead of duplicating a translation here). Only the curated locale set
/// (acceptance-tests-multi-locale design.md Decision 5) gets a translated
/// entry; every other tag falls back to the original English literals, so
/// this file only needs to grow when the curated set does.
class AcceptanceFixtures {
  const AcceptanceFixtures({
    required this.newGroupName,
    required this.newGroupAccountName,
    required this.newCreditCardName,
    required this.newCashAccountName,
    required this.recurringTemplateName,
    required this.payeeName,
    required this.payeeSearchQuery,
    required this.coffeeRunDescription,
    required this.coffeeSearchTerm,
    required this.brokerageAccountName,
    required this.stockInstrumentName,
  });

  /// A new EUR-currency account group created through the real "Create
  /// group" dialog (currency_transfers group).
  final String newGroupName;

  /// A new account created inside [newGroupName].
  final String newGroupAccountName;

  /// A new credit-card account created via the first-week-setup wizard.
  final String newCreditCardName;

  /// A new cash account created via the first-week-setup wizard.
  final String newCashAccountName;

  /// A recurring template's own name (distinct from the "Rent/Mortgage"
  /// system category).
  final String recurringTemplateName;

  /// A payee name typed while recording a transaction.
  final String payeeName;

  /// A partial-match query typed into the payee autocomplete. MUST be a
  /// literal substring of [payeeName] in every locale.
  final String payeeSearchQuery;

  /// A transaction description typed while recording a transaction, used
  /// later to verify register search. [coffeeSearchTerm] MUST be a literal
  /// substring of this in every locale, since the register-search test
  /// types [coffeeSearchTerm] and expects it to match this description.
  final String coffeeRunDescription;

  /// The substring of [coffeeRunDescription] typed into register search.
  final String coffeeSearchTerm;

  /// A brokerage/investment account name created through the real "Create
  /// account" dialog (investment_holdings, investment_research groups).
  final String brokerageAccountName;

  /// A stock instrument name typed while recording a buy.
  final String stockInstrumentName;
}

const _english = AcceptanceFixtures(
  newGroupName: 'Euro Group',
  newGroupAccountName: 'Euro Savings',
  newCreditCardName: 'My Card',
  newCashAccountName: 'Pocket Cash',
  recurringTemplateName: 'Rent',
  payeeName: 'Starbucks',
  payeeSearchQuery: 'Star',
  coffeeRunDescription: 'Coffee run',
  coffeeSearchTerm: 'Coffee',
  brokerageAccountName: 'Brokerage',
  stockInstrumentName: 'Acme Stock',
);

/// The 9-locale curated set (acceptance-tests-multi-locale design.md
/// Decision 5): two RTL locales, a complex-conjunct-script locale, the
/// three CJK BIP39-wordlist locales, one Latin BIP39-wordlist locale, one
/// long-compound-word stress locale, and one lower-review-confidence
/// locale. Kept as an explicit `const` list (not derived at runtime) so
/// changing it is a deliberate, reviewable decision.
const kCuratedAcceptanceLocales = <String>[
  'ar', // RTL, Arabic script, no BIP39 wordlist (English-fallback notice)
  'ur', // RTL, different script/digit conventions, no BIP39 wordlist
  'hi', // Devanagari, complex conjunct script, no BIP39 wordlist
  'ja', // CJK, BIP39 wordlist, zero-decimal JPY formatting
  'zh', // CJK, BIP39 wordlist
  'ko', // CJK, BIP39 wordlist
  'fr', // BIP39 wordlist, accented Latin script
  'de', // long compound words - layout/overflow stress, no wordlist
  'as', // lower-review-confidence / AI-drafted translation, no wordlist
];

const Map<String, AcceptanceFixtures> _fixturesByTag = {
  'ar': AcceptanceFixtures(
    newGroupName: 'مجموعة اليورو',
    newGroupAccountName: 'مدخرات اليورو',
    newCreditCardName: 'بطاقتي',
    newCashAccountName: 'نقد الجيب',
    recurringTemplateName: 'الإيجار',
    payeeName: 'ستاربكس',
    payeeSearchQuery: 'ستار',
    coffeeRunDescription: 'شراء قهوة',
    coffeeSearchTerm: 'قهوة',
    brokerageAccountName: 'حساب الوساطة',
    stockInstrumentName: 'سهم أكمي',
  ),
  'ur': AcceptanceFixtures(
    newGroupName: 'یورو گروپ',
    newGroupAccountName: 'یورو بچت',
    newCreditCardName: 'میرا کارڈ',
    newCashAccountName: 'جیب نقدی',
    recurringTemplateName: 'کرایہ',
    payeeName: 'اسٹار بکس',
    payeeSearchQuery: 'اسٹار',
    coffeeRunDescription: 'کافی خریداری',
    coffeeSearchTerm: 'کافی',
    brokerageAccountName: 'بروکریج اکاؤنٹ',
    stockInstrumentName: 'ایکمی اسٹاک',
  ),
  'hi': AcceptanceFixtures(
    newGroupName: 'यूरो समूह',
    newGroupAccountName: 'यूरो बचत',
    newCreditCardName: 'मेरा कार्ड',
    newCashAccountName: 'जेब नकद',
    recurringTemplateName: 'किराया',
    payeeName: 'स्टारबक्स',
    payeeSearchQuery: 'स्टार',
    coffeeRunDescription: 'कॉफी खरीद',
    coffeeSearchTerm: 'कॉफी',
    brokerageAccountName: 'ब्रोकरेज खाता',
    stockInstrumentName: 'एक्मी स्टॉक',
  ),
  'ja': AcceptanceFixtures(
    newGroupName: 'ユーログループ',
    newGroupAccountName: 'ユーロ貯蓄',
    newCreditCardName: 'マイカード',
    newCashAccountName: '財布の現金',
    recurringTemplateName: '家賃',
    payeeName: 'スターバックス',
    payeeSearchQuery: 'スター',
    coffeeRunDescription: 'コーヒー購入',
    coffeeSearchTerm: 'コーヒー',
    brokerageAccountName: '証券口座',
    stockInstrumentName: 'アクメ株',
  ),
  'zh': AcceptanceFixtures(
    newGroupName: '欧元组',
    newGroupAccountName: '欧元储蓄',
    newCreditCardName: '我的卡',
    newCashAccountName: '零钱现金',
    recurringTemplateName: '房租',
    payeeName: '星巴克',
    payeeSearchQuery: '星巴',
    coffeeRunDescription: '买咖啡',
    coffeeSearchTerm: '咖啡',
    brokerageAccountName: '证券账户',
    stockInstrumentName: '爱克米股票',
  ),
  'ko': AcceptanceFixtures(
    newGroupName: '유로 그룹',
    newGroupAccountName: '유로 저축',
    newCreditCardName: '내 카드',
    newCashAccountName: '지갑 현금',
    recurringTemplateName: '월세',
    payeeName: '스타벅스',
    payeeSearchQuery: '스타',
    coffeeRunDescription: '커피 구매',
    coffeeSearchTerm: '커피',
    brokerageAccountName: '증권 계좌',
    stockInstrumentName: '아크미 주식',
  ),
  'fr': AcceptanceFixtures(
    newGroupName: 'Groupe Euro',
    newGroupAccountName: 'Épargne Euro',
    newCreditCardName: 'Ma carte',
    newCashAccountName: 'Argent de poche',
    recurringTemplateName: 'Loyer',
    payeeName: 'Starbucks',
    payeeSearchQuery: 'Star',
    coffeeRunDescription: 'Achat de café',
    coffeeSearchTerm: 'café',
    brokerageAccountName: 'Compte de courtage',
    stockInstrumentName: 'Action Acme',
  ),
  'de': AcceptanceFixtures(
    newGroupName: 'Eurogruppe',
    newGroupAccountName: 'Eurosparkonto',
    newCreditCardName: 'Meine Karte',
    newCashAccountName: 'Taschengeld',
    recurringTemplateName: 'Miete',
    payeeName: 'Starbucks',
    payeeSearchQuery: 'Star',
    coffeeRunDescription: 'Kaffee kaufen',
    coffeeSearchTerm: 'Kaffee',
    brokerageAccountName: 'Maklerkonto',
    stockInstrumentName: 'Acme-Aktie',
  ),
  'as': AcceptanceFixtures(
    newGroupName: 'ইউৰো গোট',
    newGroupAccountName: 'ইউৰো সঞ্চয়',
    newCreditCardName: 'মোৰ কাৰ্ড',
    newCashAccountName: 'পকেট নগদ',
    recurringTemplateName: 'ভাড়া',
    payeeName: 'ষ্টাৰবাকচ',
    payeeSearchQuery: 'ষ্টাৰ',
    coffeeRunDescription: 'কফী কিনা',
    coffeeSearchTerm: 'কফী',
    brokerageAccountName: 'ব্ৰোকাৰেজ একাউণ্ট',
    stockInstrumentName: 'একমি ষ্টক',
  ),
};

/// The fixture set for [tag], falling back to the original English
/// literals for any tag outside [kCuratedAcceptanceLocales].
AcceptanceFixtures fixturesForTag(String tag) =>
    _fixturesByTag[tag] ?? _english;
