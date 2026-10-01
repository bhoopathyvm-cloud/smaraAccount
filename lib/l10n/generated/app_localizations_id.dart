// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Smara Pembukuan';

  @override
  String get navHome => 'Beranda';

  @override
  String get navRegister => 'Buku';

  @override
  String get navSummary => 'Ringkasan';

  @override
  String get navAccounts => 'Akun';

  @override
  String get navCategories => 'Kategori';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionDone => 'Selesai';

  @override
  String get actionContinue => 'Lanjutkan';

  @override
  String get actionDismiss => 'Tutup';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get actionSkip => 'Lewati';

  @override
  String get actionConfirm => 'Konfirmasi';

  @override
  String get actionAdd => 'Tambah';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRename => 'Ganti nama';

  @override
  String get actionHide => 'Sembunyikan';

  @override
  String get actionCreate => 'Buat';

  @override
  String get actionCloseApp => 'Tutup aplikasi';

  @override
  String get actionUnlock => 'Buka kunci';

  @override
  String get actionSettle => 'Selesaikan';

  @override
  String get actionFinish => 'Selesai';

  @override
  String get actionPreview => 'Pratinjau';

  @override
  String get actionImport => 'Impor';

  @override
  String get actionExportCsv => 'Ekspor CSV';

  @override
  String get actionChooseFile => 'Pilih file';

  @override
  String get actionRestore => 'Pulihkan';

  @override
  String get actionFix => 'Perbaiki';

  @override
  String get actionBuy => 'Beli';

  @override
  String get actionSell => 'Jual';

  @override
  String get actionDividend => 'Dividen';

  @override
  String get actionRecordBuy => 'Catat pembelian';

  @override
  String get actionRecordSell => 'Catat penjualan';

  @override
  String get actionRecordDividend => 'Catat dividen';

  @override
  String get actionPayCard => 'Bayar kartu';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionRecordTransaction => 'Catat transaksi';

  @override
  String get actionImportStatement => 'Impor rekening koran';

  @override
  String get actionClearDates => 'Hapus tanggal';

  @override
  String get actionClearSearch => 'Hapus pencarian dan filter';

  @override
  String get actionUseBiometrics => 'Gunakan biometrik';

  @override
  String get actionSetPin => 'Atur PIN';

  @override
  String get actionChangePin => 'Ubah PIN';

  @override
  String get actionSaveBackup => 'Simpan cadangan';

  @override
  String get actionRestoreBackup => 'Pulihkan cadangan';

  @override
  String get actionSaveRule => 'Simpan aturan';

  @override
  String get actionConfirmFix => 'Konfirmasi perbaikan';

  @override
  String get captureSpent => 'Pengeluaran';

  @override
  String get captureReceived => 'Pemasukan';

  @override
  String get captureMovedMoney => 'Uang dipindahkan';

  @override
  String get captureImportStatement => 'Impor rekening koran';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Bahasa perangkat';

  @override
  String get settingsFetchFxRates => 'Ambil kurs referensi';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Menampilkan kurs pasar indikatif di samping jumlah tujuan pada transfer lintas mata uang, hanya untuk perbandingan - tidak pernah digunakan untuk mengisi jumlah.';

  @override
  String get settingsRateProvider => 'Penyedia kurs';

  @override
  String get settingsFetchMarketPrices => 'Ambil harga pasar untuk investasi';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Mencari harga terakhir untuk instrumen yang memiliki ticker atau ISIN, untuk memperkirakan nilai portofolio. Tidak pernah digunakan untuk mencatat transaksi, dan tidak pernah mengirim berapa banyak yang Anda miliki.';

  @override
  String get settingsMarketPriceProvider => 'Penyedia harga pasar';

  @override
  String get settingsFavouriteResearchTool => 'Alat riset favorit';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Mengetuk nama instrumen pada kepemilikan akan membuka alat ini di browser dengan perintah riset — bukan integrasi, dan bukan saran.';

  @override
  String get settingsBackup => 'Cadangan';

  @override
  String get settingsBackupBlurb =>
      'Simpan salinan terenkripsi dari pembukuan Anda ke lokasi pilihan Anda, atau pulihkan dari sana. Ini terpisah dari frasa pemulihan atau file keystore Anda, yang mencadangkan kunci penandatanganan Anda, bukan pembukuan Anda.';

  @override
  String get settingsLock => 'Kunci';

  @override
  String get settingsLockBlurb =>
      'Wajibkan PIN, atau biometrik jika tersedia, untuk membuka aplikasi.';

  @override
  String get settingsRequireUnlock =>
      'Wajibkan buka kunci untuk membuka aplikasi';

  @override
  String get settingsLockAfter => 'Kunci setelah';

  @override
  String get settingsLockImmediately => 'Segera';

  @override
  String get settingsLock1Minute => '1 menit';

  @override
  String get settingsLock5Minutes => '5 menit';

  @override
  String get settingsLock15Minutes => '15 menit';

  @override
  String get settingsAllowBiometrics => 'Izinkan biometrik juga';

  @override
  String get settingsHideSnapshot => 'Sembunyikan saldo di app switcher';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Menyamarkan layar ini saat Anda beralih ke aplikasi lain, sehingga tidak terlihat sekilas di app switcher.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Menyembunyikan saldo di app switcher tidak tersedia di platform ini.';

  @override
  String get settingsPayees => 'Penerima';

  @override
  String get settingsManagePayees => 'Kelola penerima';

  @override
  String get settingsPayeesBlurb =>
      'Nama penerima yang diingat beserta kategori dan akun default-nya, disarankan oleh pelengkapan otomatis saat mencatat transaksi.';

  @override
  String get settingsRecurring => 'Templat berulang';

  @override
  String get settingsManageRecurring => 'Kelola templat berulang';

  @override
  String get settingsRecurringBlurb =>
      'Tagihan atau pemasukan yang berulang setiap bulan, seperti sewa atau gaji. Templat yang jatuh tempo muncul di Beranda untuk Anda catat dengan satu ketukan - tidak pernah diposting secara otomatis.';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Tidak dapat membuka kebijakan privasi di browser.';

  @override
  String get providerFrankfurter => 'Frankfurter (kurs ECB)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (kuotasi harian)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (chart API)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Kas & setara kas';

  @override
  String get systemGroupPensionRetirement => 'Pensiun & dana hari tua';

  @override
  String get systemGroupCreditShortTerm => 'Kredit & utang jangka pendek';

  @override
  String get systemGroupLoansMortgages => 'Pinjaman & KPR';

  @override
  String get systemGroupInvestments => 'Investasi';

  @override
  String get systemAccountCashBank => 'Kas & Bank';

  @override
  String get systemCategorySalary => 'Gaji';

  @override
  String get systemCategoryOtherIncome => 'Pemasukan lainnya';

  @override
  String get systemCategoryGroceries => 'Belanja bulanan';

  @override
  String get systemCategoryRentMortgage => 'Sewa/KPR';

  @override
  String get systemCategoryUtilities => 'Utilitas';

  @override
  String get systemCategoryTransport => 'Transportasi';

  @override
  String get systemCategoryFoodOut => 'Makan di luar';

  @override
  String get systemCategoryPhone => 'Telepon';

  @override
  String get systemCategoryHealth => 'Kesehatan';

  @override
  String get systemCategoryOtherExpense => 'Pengeluaran lainnya';

  @override
  String get systemDescriptionCsvImport => 'Impor CSV';

  @override
  String get systemDescriptionOfxImport => 'Impor OFX';

  @override
  String get homeThisMonth => 'BULAN INI';

  @override
  String get homeMoneyInTransit => 'UANG DALAM PERJALANAN';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'YANG ANDA MILIKI DIKURANGI YANG ANDA UTANG';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Yang Anda miliki $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Yang Anda miliki $haveAmount $currency  •  Yang Anda utang $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Anda mengirim $amount $currency dari $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Anda mengirim $amount $currency ke $name';
  }

  @override
  String get hiddenLabel => 'Tersembunyi';

  @override
  String get allAccounts => 'Semua akun';

  @override
  String savedToPath(String path) {
    return 'Disimpan ke $path';
  }

  @override
  String get homeTapWhenArrived => 'Ketuk saat Anda tahu apa yang tiba';

  @override
  String homeReturnedTo(String name) {
    return 'Dikembalikan ke $name';
  }

  @override
  String get homeDueToday => 'JATUH TEMPO HARI INI';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · ketuk untuk mencatat';
  }

  @override
  String get homeOverLimit => 'Melebihi batas';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent dari $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Sisa: $amount';
  }

  @override
  String get homeNoAccounts => 'Tidak ada akun';

  @override
  String get homeCashRegister => 'Kas register';

  @override
  String get homeMarketEstimate => 'Estimasi pasar';

  @override
  String get registerTitle => 'Buku';

  @override
  String get registerSearchHint => 'Deskripsi, kategori, atau jumlah';

  @override
  String get registerNoTransactions => 'Belum ada transaksi';

  @override
  String get registerNoEntries => 'Belum ada entri yang dicatat.';

  @override
  String get registerSpentOnly => 'Hanya pengeluaran';

  @override
  String get registerReceivedOnly => 'Hanya pemasukan';

  @override
  String get registerAll => 'Semua';

  @override
  String get registerUnverified =>
      'Belum terverifikasi - tidak termasuk dalam total';

  @override
  String get registerSuperseded =>
      'Digantikan oleh migrasi - tidak termasuk dalam total';

  @override
  String get summaryTitle => 'Ringkasan';

  @override
  String get summaryTotalIncome => 'Total pemasukan';

  @override
  String get summaryTotalExpense => 'Total pengeluaran';

  @override
  String summaryDateRange(String start, String end) {
    return '$start hingga $end';
  }

  @override
  String get accountsTitle => 'Akun';

  @override
  String get categoriesTitle => 'Kategori';

  @override
  String get accountName => 'Nama akun';

  @override
  String get createAccount => 'Buat akun';

  @override
  String get createGroup => 'Buat grup';

  @override
  String get editGroup => 'Edit grup';

  @override
  String get renameAccount => 'Ganti nama akun';

  @override
  String get renameCategory => 'Ganti nama kategori';

  @override
  String get addCategory => 'Tambah kategori';

  @override
  String get groupLabel => 'Grup';

  @override
  String get kindLabel => 'Jenis';

  @override
  String get asset => 'Aset';

  @override
  String get liability => 'Liabilitas';

  @override
  String get income => 'Pemasukan';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get thisAccountHoldsInvestments => 'Akun ini menyimpan investasi';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Kas ditambah inventaris yang Anda catat dengan Beli, Jual, dan Dividen.';

  @override
  String get thisIsACreditCard => 'Ini adalah kartu kredit';

  @override
  String get openingBalanceOptional => 'Saldo awal (opsional)';

  @override
  String get currencyIso => 'Mata uang (ISO 4217)';

  @override
  String get currencyIsoExample => 'Mata uang (ISO 4217, mis. USD)';

  @override
  String get hideAccountTitle => 'Sembunyikan akun dari entri baru?';

  @override
  String get hideCategoryTitle => 'Sembunyikan kategori dari entri baru?';

  @override
  String get hideGroupTitle => 'Sembunyikan grup dari entri baru?';

  @override
  String get reassignGroup => 'Tetapkan ulang grup';

  @override
  String get transferRemainingBalance => 'Transfer sisa saldo';

  @override
  String get monthlyLimit => 'Batas bulanan';

  @override
  String get monthlyLimitHint => 'Batas (kosongkan untuk menghapus)';

  @override
  String get monthlyLimitBlurb =>
      'Panduan pengeluaran opsional bulan-berjalan untuk kategori pengeluaran ini.';

  @override
  String get translateCategoryWithAi => 'Translate with AI';

  @override
  String get addCategoryTranslation => 'Add translation';

  @override
  String get categoryTranslationLocale => 'Language';

  @override
  String get categoryTranslationName => 'Translated name';

  @override
  String get mergeCategories => 'Merge categories';

  @override
  String get mergeCategoriesSuggested =>
      'These categories look the same. Merge them?';

  @override
  String get categoryDefaultLanguage => 'Default language for category names';

  @override
  String get categoryDefaultLanguageSubtitle =>
      'Shared across linked devices. Each device still shows its own language when a translation exists.';

  @override
  String get manageCategoryRules => 'Kelola aturan kategori';

  @override
  String get amount => 'Jumlah';

  @override
  String get category => 'Kategori';

  @override
  String get account => 'Akun';

  @override
  String get fromAccount => 'Dari akun';

  @override
  String get toAccount => 'Ke akun';

  @override
  String get descriptionOptional => 'Deskripsi (opsional)';

  @override
  String get alsoRememberPayee => 'Ingat juga sebagai penerima';

  @override
  String get splitIntoCategories => 'Bagi ke beberapa kategori';

  @override
  String categoryN(String n) {
    return 'Kategori $n';
  }

  @override
  String get destinationAmount => 'Jumlah tujuan';

  @override
  String get destinationAmountOptional => 'Jumlah tujuan (opsional)';

  @override
  String get accountCurrencyAmountOptional =>
      'Jumlah dalam mata uang akun (opsional)';

  @override
  String get transactionCurrencyOptional => 'Mata uang transaksi (opsional)';

  @override
  String get feeOptional => 'Biaya (opsional)';

  @override
  String get feeAmount => 'Jumlah biaya';

  @override
  String get feeCategory => 'Kategori biaya';

  @override
  String get feeDescriptionOptional => 'Deskripsi biaya (opsional)';

  @override
  String get feeDeducted => 'Biaya dipotong dari jumlah di atas';

  @override
  String get needTwoAccountsToTransfer =>
      'Buat setidaknya dua akun aktif untuk melakukan transfer.';

  @override
  String get whatArrivedTitle => 'Apa yang tiba?';

  @override
  String get whatArrivedBlurb => 'Beri tahu kami apa yang sebenarnya tiba.';

  @override
  String get amountThatArrived => 'Jumlah yang tiba';

  @override
  String get feeLossCategory => 'Kategori biaya / kerugian';

  @override
  String get alreadySettled => 'Sudah diselesaikan.';

  @override
  String get holdingsTitle => 'Kepemilikan';

  @override
  String get holdingsCash => 'Kas';

  @override
  String get holdingsInventory => 'INVENTARIS';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Buku (kas + biaya) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Estimasi pasar $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Belum ada kepemilikan. Catat pembelian untuk menambahkan instrumen.';

  @override
  String get holdingsQuotesBlurb =>
      'Kuotasi adalah perkiraan, bukan harga broker. Aplikasi ini tidak melakukan pemesanan.';

  @override
  String get holdingsTapNameToResearch =>
      'Ketuk nama untuk riset. Kuotasi adalah perkiraan, bukan saran.';

  @override
  String get instrument => 'Instrumen';

  @override
  String get newInstrument => 'Instrumen baru';

  @override
  String get renameInstrument => 'Ganti nama instrumen';

  @override
  String get instrumentActions => 'Tindakan instrumen';

  @override
  String hideInstrumentTitle(String name) {
    return 'Sembunyikan $name?';
  }

  @override
  String get tickerOptional => 'Ticker (opsional)';

  @override
  String get isinOptional => 'ISIN (opsional)';

  @override
  String get quantity => 'Kuantitas';

  @override
  String get unitPrice => 'Harga satuan';

  @override
  String get brokerageOptional => 'Biaya broker (opsional)';

  @override
  String get brokerageExpenseCategory => 'Kategori biaya broker';

  @override
  String get incomeCategory => 'Kategori pemasukan';

  @override
  String get gainIncomeCategory => 'Kategori pemasukan keuntungan';

  @override
  String get lossExpenseCategory => 'Kategori pengeluaran kerugian';

  @override
  String get nonCash => 'Non-tunai';

  @override
  String get cash => 'Tunai';

  @override
  String get locked => 'Terkunci';

  @override
  String get lockUntilHint =>
      'Ini adalah catatan Anda sendiri tentang suatu batasan, bukan aturan broker.';

  @override
  String get instrumentKindStock => 'Saham';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Reksa dana';

  @override
  String get instrumentKindBond => 'Obligasi';

  @override
  String get instrumentKindOther => 'Lainnya';

  @override
  String get quoteUseLive => 'Harga langsung';

  @override
  String get quoteUseCached => 'Harga tersimpan';

  @override
  String get quoteUseStale => 'Harga usang';

  @override
  String get quoteUseMissing => 'Menggunakan biaya (tidak ada harga)';

  @override
  String get quoteUseDisabled => 'Kuotasi nonaktif — menggunakan biaya/cache';

  @override
  String get quoteUseCurrencyMismatch =>
      'Menggunakan biaya (mata uang harga berbeda)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Belum terealisasi $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty unit · ';
  }

  @override
  String get chooseLanguageTitle => 'Pilih bahasa Anda';

  @override
  String get chooseLanguageBlurb =>
      'Semua yang ada di aplikasi akan ditampilkan dalam bahasa ini. Anda dapat mengubahnya nanti di Pengaturan.';

  @override
  String get chooseCurrencyTitle => 'Pilih mata uang Anda';

  @override
  String get chooseCurrencyBlurb =>
      'Setiap grup akun (Kas & setara kas, Pensiun & dana hari tua, dll.) untuk saat ini menggunakan satu mata uang ini. Anda masih dapat menambahkan akun dalam mata uang lain nanti dengan membuat grup baru untuknya.';

  @override
  String get currencyBackfillTitle =>
      'Pilih mata uang untuk grup yang sudah ada';

  @override
  String get currencyBackfillBlurb =>
      'Aplikasi ini sekarang mendukung banyak mata uang. Akun dan grup akun Anda yang sudah ada memerlukan mata uang - karena semuanya disiapkan sebelum fitur ini ada, satu pilihan berlaku untuk semuanya.';

  @override
  String get firstAccountTitle => 'Beri nama akun Anda';

  @override
  String get firstAccountBlurb =>
      'Ini adalah akun yang sudah disiapkan untuk Anda - beri nama yang Anda kenali, seperti nama bank Anda. Anda akan mencatat satu Pengeluaran atau Pemasukan berikutnya, lalu melindungi perangkat dengan frasa pemulihan Anda.';

  @override
  String get whatsMainAccountCalled => 'Apa nama akun utama Anda?';

  @override
  String get setupChoiceTitle => 'Welcome to Smara Accounting';

  @override
  String get setupChoiceBlurb =>
      'Starting fresh, or moving from another device?';

  @override
  String get actionNewSetup => 'New setup';

  @override
  String get continueBooksTitle => 'Continue my books on this phone';

  @override
  String get continueBooksBlurb =>
      'These books arrived on this phone without their signing key. You can continue them under a new key for this phone, or restore from a saved copy instead.';

  @override
  String get continueBooksAction => 'Continue my books on this phone';

  @override
  String get restoreFromCopyAction => 'Restore from a copy';

  @override
  String get saveBooksCopyAction => 'Save a copy of my books';

  @override
  String get deviceHistoryTitle => 'Device history';

  @override
  String get deviceHistoryEmpty =>
      'No Continuations yet. When you continue books on a new phone, they will show up here.';

  @override
  String deviceHistoryContinuedOn(String date) {
    return 'Your books continued on this phone on $date';
  }

  @override
  String deviceHistoryContinuedFromCopy(String continuedDate, String copyDate) {
    return 'Your books continued on this phone on $continuedDate (from a copy saved on $copyDate)';
  }

  @override
  String get backupReminderBannerTitle => 'Save a copy of your books';

  @override
  String get backupReminderSaveAction => 'Save a copy';

  @override
  String get backupReminderLaterAction => 'Later';

  @override
  String get settingsBackupReminder => 'Copy reminder';

  @override
  String get settingsBackupReminderBlurb =>
      'We\'ll gently remind you to save a copy of your books after a while, or after many new entries. A saved copy is the only way to recover books if this phone is lost.';

  @override
  String get settingsBackupReminderEnabled => 'Remind me to save a copy';

  @override
  String get settingsBackupReminderDays => 'Remind after this many days';

  @override
  String get settingsBackupReminderEntries =>
      'Remind after this many new entries';

  @override
  String get settingsBackupReminderSnoozeDays =>
      'Hide for this many days after Later';

  @override
  String get settingsBackupReminderSnoozeEntries =>
      'Hide for this many new entries after Later';

  @override
  String get settingsBooksSwitcher => 'Books on this device';

  @override
  String get settingsBooksSwitcherBlurb =>
      'Each set of books has its own signing key and history. Switching opens that set — Home and Register show only its entries.';

  @override
  String get settingsBooksSwitcherActive => 'Open now';

  @override
  String get settingsBooksSwitcherSwitch => 'Switch';

  @override
  String get settingsBooksSwitcherCreate => 'New books';

  @override
  String get settingsBooksSwitcherCreateTitle => 'Name these books';

  @override
  String get settingsBooksSwitcherNameLabel => 'Name';

  @override
  String get settingsBooksSwitcherRemoveTitle => 'Remove these books?';

  @override
  String settingsBooksSwitcherRemoveBody(String name) {
    return 'This deletes \"$name\" from this device, including its signing key. Other books on this device are not affected.';
  }

  @override
  String get settingsBooksSwitcherRemoveConfirm => 'Remove';

  @override
  String get settingsLinkedDevices => 'Linked devices';

  @override
  String get settingsLinkedDevicesCatchUp =>
      'Your devices catch up when both have Smara open on the same Wi-Fi.';

  @override
  String get settingsLinkedDevicesPermissionSentence =>
      'To share your books, Smara needs to find your other devices on this Wi-Fi. Nothing goes to the internet.';

  @override
  String get settingsLinkedDevicesAddDevice => 'Add a device';

  @override
  String get settingsLinkedDevicesContinue => 'Continue';

  @override
  String get settingsLinkedDevicesRoleOwner => 'Owner';

  @override
  String get settingsLinkedDevicesRoleMember => 'Member';

  @override
  String get settingsLinkedDevicesCanAdd => 'May add devices';

  @override
  String get settingsLinkedDevicesErasePending => 'Erase pending';

  @override
  String settingsLinkedDevicesErasedOn(String date) {
    return 'Erased on $date';
  }

  @override
  String get settingsLinkedDevicesSuggestSecondOwner =>
      'These books have only one Owner. Consider making another linked device an Owner too.';

  @override
  String get settingsLinkedDevicesJoinSameWifi =>
      'Both devices must be on the same Wi-Fi. Smara does not join over the internet.';

  @override
  String get settingsLinkedDevicesApproveJoin => 'Approve';

  @override
  String get settingsLinkedDevicesRefuseJoin => 'Refuse';

  @override
  String settingsLinkedDevicesPendingJoin(String name) {
    return '$name wants to join these books';
  }

  @override
  String get settingsLinkedDevicesEmpty => 'Only this device is linked so far.';

  @override
  String get settingsLinkedDevicesSyncNow => 'Sync now';

  @override
  String get settingsLinkedDevicesSyncNowBusy => 'Catching up…';

  @override
  String membershipNoticeDeviceAdded(String name) {
    return 'A device was added: $name';
  }

  @override
  String membershipNoticeDeviceRemoved(String name) {
    return 'A device was removed: $name';
  }

  @override
  String membershipNoticeErasePending(String name) {
    return 'Erase pending for $name';
  }

  @override
  String membershipNoticeErased(String name, String date) {
    return 'Erased $name on $date';
  }

  @override
  String membershipNoticeSoleOwnerClaimed(String name) {
    return '$name claimed sole ownership';
  }

  @override
  String membershipNoticeSoleOwnerCancelled(String name) {
    return 'Sole-Owner claim for $name was cancelled';
  }

  @override
  String membershipNoticeSoleOwnerEffective(String name) {
    return '$name is now an Owner';
  }

  @override
  String membershipNoticeEntryNotAccepted(String name) {
    return 'Not accepted: couldn\'t be verified (from $name)';
  }

  @override
  String membershipNoticeOwnerVerificationAlert(String name) {
    return 'A record from $name could not be verified and was not accepted';
  }

  @override
  String get membershipNoticeCompetingFixCheck =>
      'Two Fixes for the same entry were resolved — please check';

  @override
  String get whyWeDontEdit => 'Mengapa kami tidak mengedit entri lama';

  @override
  String get whyWeDontEditBody =>
      'Saat Anda memperbaiki kesalahan, kami mempertahankan baris lama dan menambahkan koreksi di sebelahnya alih-alih mengubah apa yang sudah Anda masukkan. Dengan begitu riwayat Anda selalu menunjukkan persis apa yang terjadi dan kapan Anda memperbaikinya — tidak ada yang diam-diam berubah di belakang Anda.';

  @override
  String get lockTitle => 'Buka kunci';

  @override
  String get lockScreenTitle => 'Terkunci';

  @override
  String get enterPinToContinue => 'Masukkan PIN untuk melanjutkan';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Atur PIN';

  @override
  String get currentPin => 'PIN saat ini';

  @override
  String get newPin => 'PIN baru';

  @override
  String get confirmPin => 'Konfirmasi PIN';

  @override
  String get confirmNewPin => 'Konfirmasi PIN baru';

  @override
  String get firstWeekTitle => 'Siapkan akun Anda';

  @override
  String get addCashAccount => 'Tambahkan akun kas';

  @override
  String get addCreditCard => 'Tambahkan kartu kredit';

  @override
  String get cashAccountName => 'Nama akun kas';

  @override
  String get cardName => 'Nama kartu';

  @override
  String get paidFromBank => 'Dibayar dari bank';

  @override
  String get paidFromCard => 'Dibayar dari kartu';

  @override
  String get choosePassphraseTitle =>
      'Pilih frasa sandi untuk melindungi cadangan ini. Tidak ada pemulihan jika Anda melupakannya.';

  @override
  String get replaceBooksTitle => 'Ganti pembukuan lokal Anda?';

  @override
  String get replaceBooksBody =>
      'Ini akan mengganti semua yang ada di aplikasi ini saat ini dengan cadangan. Tutup dan buka kembali aplikasi setelahnya.';

  @override
  String get chooseBackupFileFirst => 'Pilih file cadangan terlebih dahulu.';

  @override
  String get backupRestored => 'Cadangan dipulihkan';

  @override
  String get backupRestoredBody =>
      'Pembukuan Anda telah dipulihkan. Tutup dan buka kembali aplikasi untuk melanjutkan.';

  @override
  String get fixThisEntry => 'Perbaiki entri ini';

  @override
  String get fixBlurb =>
      'Baris lama tetap persis seperti semula. Konfirmasi menambahkan baris pembalik dan baris yang telah dikoreksi.';

  @override
  String get importStatementTitle => 'Impor Rekening Koran';

  @override
  String get importOfx => 'Impor OFX';

  @override
  String get importOfxQfxFile => 'Impor file OFX / QFX';

  @override
  String get importCsvFile => 'Impor file CSV';

  @override
  String get whatKindOfStatement =>
      'Jenis file rekening koran apa yang Anda miliki?';

  @override
  String get chooseAccountForFile =>
      'Pilih akun mana yang menjadi milik file ini.';

  @override
  String get importIntoAccount => 'Impor ke akun';

  @override
  String get useSavedProfile => 'Gunakan profil tersimpan';

  @override
  String get saveMappingProfile =>
      'Simpan pemetaan ini sebagai profil (opsional)';

  @override
  String get renameProfile => 'Ganti nama profil';

  @override
  String get deleteProfileTitle => 'Hapus profil?';

  @override
  String get fileHasHeader => 'File memiliki baris header';

  @override
  String get dateColumn => 'Kolom tanggal';

  @override
  String get dateFormatHint => 'Format tanggal (mis. dd/MM/yyyy)';

  @override
  String get amountColumn => 'Kolom jumlah';

  @override
  String get amountConvention => 'Konvensi jumlah';

  @override
  String get signedAmountColumn => 'Kolom jumlah bertanda';

  @override
  String get separateDebitCredit => 'Kolom debit / kredit terpisah';

  @override
  String get debitColumn => 'Kolom debit';

  @override
  String get creditColumn => 'Kolom kredit';

  @override
  String get decimalSeparator => 'Pemisah desimal (. atau ,)';

  @override
  String get descriptionColumns => 'Kolom deskripsi';

  @override
  String get referenceIdColumn => 'Kolom ID referensi (opsional)';

  @override
  String get skippedRows => 'Baris yang dilewati';

  @override
  String parsedTransactionCount(String count) {
    return '$count transaksi diproses';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count dilewati atau dikecualikan';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted diposting, $failed gagal';
  }

  @override
  String get categoryForAll => 'Kategori untuk semua';

  @override
  String get saveAsRule => 'Simpan sebagai aturan?';

  @override
  String get saveAsRuleBlurb =>
      'Impor di masa mendatang yang deskripsinya mengandung kata kunci ini akan menggunakan kategori ini.';

  @override
  String get keyword => 'Kata kunci';

  @override
  String get noSavedRules =>
      'Belum ada aturan tersimpan. Tetapkan kategori ke sekelompok baris untuk menyimpan aturan.';

  @override
  String get deleteRuleTitle => 'Hapus aturan?';

  @override
  String get editRule => 'Edit aturan';

  @override
  String rowsGrouped(String count) {
    return '$count baris';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Pilih file rekening koran $extensions untuk diimpor';
  }

  @override
  String get payeesTitle => 'Penerima';

  @override
  String get addPayee => 'Tambah penerima';

  @override
  String get renamePayee => 'Ganti nama penerima';

  @override
  String get deletePayeeTitle => 'Hapus penerima?';

  @override
  String get noPayeesYet => 'Belum ada penerima';

  @override
  String get recurringTitle => 'Templat berulang';

  @override
  String get noRecurringYet => 'Belum ada templat berulang';

  @override
  String get deleteTemplateTitle => 'Hapus templat berulang?';

  @override
  String get dayOfMonth => 'Tanggal dalam bulan (1-31)';

  @override
  String get dayOfMonthNote =>
      'Bulan dengan hari lebih sedikit menggunakan hari terakhirnya sendiri.';

  @override
  String dayOfMonthLine(String day) {
    return 'Tanggal $day setiap bulan - ';
  }

  @override
  String get name => 'Nama';

  @override
  String get none => 'Tidak ada';

  @override
  String get currency => 'Mata uang';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get errorInvalidLedgerBackup =>
      'File ini bukan cadangan Smara yang valid.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Cadangan ini tidak memiliki identitas penandatanganan - ini bukan cadangan Smara yang valid.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Cadangan ini tidak terverifikasi sebagai pembukuan yang utuh, sehingga tidak dipulihkan.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'File ini tidak dapat dibuka sebagai cadangan Smara: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'Itu bukan akun finansial.';

  @override
  String get errorAccountArchived => 'Akun tersebut disembunyikan.';

  @override
  String get errorAccountNotArchived => 'Akun tersebut tidak disembunyikan.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Tidak ada sisa saldo untuk ditransfer.';

  @override
  String get errorAccountHasNoGroup =>
      'Akun tersebut tidak memiliki grup yang ditetapkan.';

  @override
  String get errorGroupHasNoCurrency =>
      'Grup tersebut belum memiliki mata uang yang diatur.';

  @override
  String get errorGroupNotFound => 'Grup akun tersebut tidak ditemukan.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Hanya akun aset yang dapat ditandai sebagai akun investasi.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Hanya akun liabilitas yang dapat ditandai sebagai kartu kredit.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Jika diisi, saldo awal harus positif.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Jenis akun tersebut tidak cocok dengan grup.';

  @override
  String get errorLastActiveAccount =>
      'Akun finansial aktif terakhir tidak dapat disembunyikan.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Mata uang diperlukan untuk membuat grup.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Grup akun bawaan tidak dapat disembunyikan.';

  @override
  String get errorGroupAlreadyArchived => 'Grup tersebut sudah disembunyikan.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Tidak dapat menyembunyikan grup yang masih memiliki akun aktif.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Grup akun bawaan tidak pernah disembunyikan.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Grup akun tidak dapat dihapus.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Akun ini tidak dapat dipindahkan ke grup dengan mata uang yang berbeda.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Tidak dapat mengubah mata uang selama grup memiliki akun aktif.';

  @override
  String get errorAmountMustBePositive => 'Jumlah harus positif.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Jumlah dalam mata uang akun harus positif.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Jumlah dalam mata uang akun hanya untuk entri mata uang asing.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Pembagian memerlukan setidaknya dua baris kategori.';

  @override
  String get errorSplitLineMustBePositive =>
      'Setiap baris pembagian harus berupa jumlah positif.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Baris pembagian harus berjumlah sama dengan total transaksi.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Jumlah transfer harus positif.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Akun sumber dan tujuan harus berbeda.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Penutupan lintas mata uang memerlukan jumlah tujuan yang diketahui.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Jumlah tujuan hanya untuk transfer lintas mata uang.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Jumlah tujuan harus positif.';

  @override
  String get errorInvestmentCashExceeded =>
      'Tidak dapat mentransfer lebih dari kas akun investasi ini.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Selesaikan transfer tertunda ini alih-alih membatalkannya.';

  @override
  String get errorAlreadyReversed =>
      'Entri ini sudah dikoreksi. Baris aslinya tetap seperti semula.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Pilih kategori pengeluaran yang aktif.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Pilih kategori pemasukan yang aktif.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Jumlah yang tiba tidak boleh negatif.';

  @override
  String get errorPendingTransferNotFound =>
      'Transfer tertunda tersebut tidak ditemukan.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Transfer tertunda tersebut sudah diselesaikan.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Pilih akun sumber atau tujuan aslinya.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Kategori biaya hanya digunakan saat uang dikembalikan ke akun sumber.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Masukkan jumlah positif untuk apa yang tiba.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Jumlah tersebut lebih besar dari yang dikirim.';

  @override
  String get errorInstrumentNotFound => 'Instrumen tersebut tidak ditemukan.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Kategori pemasukan yang aktif diperlukan untuk akuisisi non-tunai.';

  @override
  String get errorInsufficientCash =>
      'Kas tidak cukup di akun investasi ini untuk pembelian tersebut.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Kuantitas jual dan harga satuan harus positif.';

  @override
  String errorLockedUntil(String date) {
    return 'Tidak dapat menjual: beberapa unit terkunci hingga $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Tidak dapat menjual lebih dari yang Anda miliki dan tidak terkunci saat ini.';

  @override
  String get errorIncomeRequiredForGain =>
      'Kategori pemasukan yang aktif diperlukan untuk keuntungan yang terealisasi.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Kategori pengeluaran yang aktif diperlukan untuk kerugian yang terealisasi.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Pembelian diposting, tetapi biaya broker gagal: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Penjualan diposting, tetapi biaya broker gagal: $detail';
  }

  @override
  String get errorDividendMustBePositive => 'Jumlah dividen harus positif.';

  @override
  String get errorNotInvestmentAccount => 'Itu bukan akun investasi.';

  @override
  String get errorNoInventoryCompanion =>
      'Akun investasi ini kehilangan pasangan inventarisnya.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Tidak dapat membatalkan pembelian ini: penjualan berikutnya bergantung pada unitnya. Batalkan penjualan yang bergantung terlebih dahulu: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive => 'Batas bulanan harus positif.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Jumlah templat harus positif.';

  @override
  String get errorOfxUnrecognized =>
      'File ini tidak dapat dikenali sebagai OFX.';

  @override
  String get errorCsvEmpty => 'File yang dipilih kosong.';

  @override
  String get errorCsvUnreadable => 'File ini tidak dapat dibaca sebagai CSV.';

  @override
  String get errorCsvNoRows => 'File yang dipilih tidak memiliki baris.';

  @override
  String get skipMissingDate => 'Tanggal tidak ada.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Tidak dapat mengurai tanggal \"$raw\" dengan pola \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Tanggal transaksi tidak ada atau tidak valid.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Tidak dapat mengurai tanggal transaksi \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Jumlah tidak ada.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Tidak dapat mengurai jumlah \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'Jumlah nol.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Tidak dapat mengurai jumlah debit atau kredit.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'Kolom debit dan kredit sama-sama memiliki jumlah.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Kolom debit dan kredit sama-sama nol.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Tidak dapat membuat cadangan: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Cadangan ini tidak dapat dipulihkan - frasa sandi salah, atau bukan file cadangan Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Jumlah, akun, dan kategori wajib diisi.';

  @override
  String get validationAmountAccountRequired => 'Jumlah dan akun wajib diisi.';

  @override
  String get validationSplitLineIncomplete =>
      'Setiap baris pembagian memerlukan kategori dan jumlah.';

  @override
  String get validationSplitSumMismatch =>
      'Baris pembagian harus berjumlah sama dengan total transaksi.';

  @override
  String get validationFromToAmountRequired =>
      'Akun asal, akun tujuan, dan jumlah wajib diisi.';

  @override
  String get validationAmountArrivedRequired => 'Jumlah yang tiba wajib diisi.';

  @override
  String get validationChooseReceivingAccount =>
      'Pilih akun mana yang menerima dana.';

  @override
  String get validationAccountCategoryRequired =>
      'Akun dan kategori wajib diisi.';

  @override
  String get validationFixFailed => 'Perbaikan ini tidak dapat disimpan.';

  @override
  String get validationNameRequired => 'Beri nama akun utama Anda.';

  @override
  String get validationStillLoading => 'Masih memuat - coba lagi sesaat lagi.';

  @override
  String get validationSaveAccountNameFailed =>
      'Nama akun tidak dapat disimpan.';

  @override
  String get validationWrongPin => 'PIN salah. Coba lagi.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Kategori harus Pemasukan atau Pengeluaran.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Hanya kategori Pengeluaran yang dapat memiliki batas bulanan.';

  @override
  String get validationInvalidTemplate => 'Templat tidak valid.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Tidak dapat membuat kunci penandatanganan di perangkat ini: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Tidak dapat menyimpan mata uang ini: $detail';
  }

  @override
  String get validationChooseBackupFile =>
      'Pilih file cadangan terlebih dahulu.';

  @override
  String get validationPassphraseRequired => 'Masukkan frasa sandi.';

  @override
  String get validationPinsDoNotMatch => 'Kedua PIN tidak cocok.';

  @override
  String get validationFeePositiveWithCategory =>
      'Biaya transfer harus berupa jumlah positif dengan kategori pengeluaran yang dipilih.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Biaya harus lebih kecil dari jumlah untuk transfer dengan biaya yang dipotong.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Transfer disimpan, tetapi biaya tidak dapat dicatat: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Masukkan jumlah yang valid.';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Kuantitas beli dan harga satuan harus positif.';

  @override
  String get errorInstrumentArchived =>
      'Tidak dapat membeli instrumen yang diarsipkan.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Akuisisi non-tunai tidak dapat menyertakan biaya broker.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Kategori pengeluaran yang aktif diperlukan saat biaya broker bernilai positif.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Hasil penjualan harus setidaknya menutupi jumlah biaya broker.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent dari $limit bulan ini';
  }

  @override
  String get unlockBiometricReason => 'Buka kunci Smara Account';

  @override
  String get searchLabel => 'Cari';

  @override
  String get openingBalance => 'Saldo awal';

  @override
  String transferToName(String name) {
    return 'Transfer: $name';
  }

  @override
  String get feeForTransfer => 'Biaya transfer';

  @override
  String feeForTransferTo(String name) {
    return 'Biaya transfer ke $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Tidak dapat membuka pemilih file: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Silakan pilih file .$extensions';
  }

  @override
  String get currencyCodeIso => 'Kode mata uang (ISO 4217, mis. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count lainnya';
  }

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get noneSelected => 'Tidak ada';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Tinjau entri di bawah ini ($count total) sebelum melanjutkan.';
  }

  @override
  String youReceived(String amount) {
    return 'Anda menerima $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Kosongkan jika kurs tukar belum diketahui.';

  @override
  String get recordTradeBlurb =>
      'Catat perdagangan yang sudah terjadi. Aplikasi ini tidak melakukan pemesanan.';

  @override
  String get feeOnTopBlurb =>
      'Aktif: jumlah di atas adalah total yang diambil dari akun ini; biaya diambil darinya.';

  @override
  String get feeBankBlurb =>
      'Komisi di muka yang dikenakan oleh bank Anda atau perantara.';

  @override
  String get validationPinMinLength => 'PIN harus setidaknya 4 digit.';

  @override
  String get restoreBackupBlurb =>
      'Ini akan mengganti semua yang ada di aplikasi ini saat ini dengan cadangan — bukan menggabungkan. Pilih file cadangan dan masukkan frasa sandi yang Anda gunakan untuk melindunginya.';

  @override
  String get actionReplace => 'Ganti';

  @override
  String hideAccountBody(String name) {
    return '$name tidak akan tersedia lagi untuk transaksi baru.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name tidak akan ditawarkan lagi saat membuat atau menetapkan ulang akun.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name tidak akan ditawarkan lagi saat mencatat transaksi baru.';
  }

  @override
  String get hideInstrumentBody =>
      'Instrumen yang disembunyikan tetap ada pada pembelian dan penjualan sebelumnya. Anda masih dapat mencatat dividen untuknya.';

  @override
  String nameHidden(String name) {
    return '$name (tersembunyi)';
  }

  @override
  String get noCurrencySet => 'Belum ada mata uang yang diatur';

  @override
  String deletePayeeBody(String name) {
    return '$name dan default yang diingat untuknya akan dihapus. Transaksi sebelumnya tidak terpengaruh.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name tidak akan ditawarkan lagi sebagai jatuh tempo. Transaksi yang sudah dicatat olehnya tidak terpengaruh.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Pemetaan kolom tersimpan \"$name\" akan dihapus. Rekening koran yang sudah diimpor dengannya tidak terpengaruh.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Impor tidak akan lagi dikategorikan otomatis dengan \"$keyword\". Transaksi yang sudah dikategorikan menggunakan aturan ini tidak terpengaruh.';
  }

  @override
  String get firstWeekBlurb =>
      'Secara opsional tambahkan kartu kredit atau akun kas sekarang - Anda selalu dapat menambahkan akun lain nanti dari Pengaturan.';

  @override
  String get deliveredToDestination => 'Terkirim ke tujuan';

  @override
  String deliveredToName(String name) {
    return 'Terkirim ke $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Anda menerima $amount $currency lebih sedikit dari yang diharapkan - pilih kategori untuk menutupi selisihnya.';
  }

  @override
  String get dateRangeLabel => 'Rentang tanggal';

  @override
  String get addTemplate => 'Tambah templat';

  @override
  String get editTemplate => 'Edit templat';

  @override
  String get validationFillTemplateFields =>
      'Isi setiap kolom dengan jumlah dan tanggal yang valid.';

  @override
  String get saveCsvExport => 'Simpan ekspor CSV';

  @override
  String get referenceRate => 'Kurs referensi';

  @override
  String get yourRate => 'Kurs Anda';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Kosongkan jika ini dalam $currency, mata uang akun itu sendiri.';
  }

  @override
  String get lockUntilOptional => 'Terkunci hingga (opsional)';

  @override
  String lockedUntilDate(String date) {
    return 'Terkunci hingga $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Perintah riset disalin — tidak ada URL browser yang tersedia, atau Anda sedang offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Alat riset favorit Anda telah dibuka.';

  @override
  String get looksLikeGain => 'Ini terlihat seperti keuntungan';

  @override
  String get looksLikeLoss => 'Ini terlihat seperti kerugian';

  @override
  String get looksLikeBreakEven => 'Ini terlihat seperti impas';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty dapat dijual)';
  }

  @override
  String columnN(String index) {
    return 'Kolom $index';
  }

  @override
  String get importingLabel => 'Mengimpor...';

  @override
  String get confirmImport => 'Konfirmasi impor';

  @override
  String get manageSavedCategoryRules => 'Kelola aturan kategori tersimpan';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Mata uang file ini ($currency) tidak cocok dengan mata uang akun yang dipilih.';
  }

  @override
  String get categoryRulesTitle => 'Aturan kategori';

  @override
  String get possibleDuplicate => 'kemungkinan duplikat';

  @override
  String get unknownCategory => 'Kategori tidak diketahui';

  @override
  String get researchPromptIntro =>
      'Riset instrumen yang terdaftar secara publik ini untuk investor rumah tangga. Identifikasi penerbitnya, ringkas berita terbaru beserta tanggalnya jika diketahui, dan uraikan risiko penurunan serta pendorong kenaikan. Pisahkan fakta dari spekulasi. Jangan berikan rekomendasi beli, jual, atau tahan. Ini bukan nasihat keuangan.';

  @override
  String researchPromptNameLine(String name) {
    return 'Nama: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Kode saham: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided =>
      'Kode saham: (tidak disediakan)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (tidak disediakan)';

  @override
  String get identifyPromptIntro =>
      'I want to add this security to my portfolio tracker. Give me its ISIN, its primary listing exchange and ticker, the trading currency, the exact market-data symbol (for example the Yahoo Finance symbol), and — if it is cross-listed — each venue with its own currency. Facts only, with the source if you can. Do not give buy, sell, or hold advice. This is not financial advice.';

  @override
  String get instrumentLookUp => 'Look up identifiers';

  @override
  String get instrumentLookUpCopied =>
      'Copied an identifier look-up prompt — no browser URL available, or you are offline.';

  @override
  String get instrumentLookUpOpened =>
      'Opened your favourite tool to look up the identifiers.';

  @override
  String get isinInvalid =>
      'This does not look like an ISIN (12 letters/digits starting with a country code).';

  @override
  String get isinCheckDigitWarning =>
      'This ISIN looks mistyped — its check digit does not add up.';

  @override
  String instrumentCurrencyMismatchWithHint(
    String inferred,
    String account,
    String suffix,
  ) {
    return 'Automatic quotes may not match: this looks like a $inferred listing but the account is in $account. For $account quotes, use the $suffix listing.';
  }

  @override
  String instrumentCurrencyMismatch(String inferred, String account) {
    return 'Automatic quotes may not match: this looks like a $inferred listing but the account is in $account.';
  }

  @override
  String get settingsDefaultExchange => 'Default exchange';

  @override
  String get settingsDefaultExchangeSubtitle =>
      'Biases which listing a new instrument resolves to, and supplies its currency. A fixed list — pick the venue you trade on most.';

  @override
  String get confirmListingTitle => 'Confirm the listing';

  @override
  String get confirmListingBlurb =>
      'Pick the listing that matches your holding. Its currency is what automatic quotes will use.';

  @override
  String confirmListingCurrencyLine(String exchange, String currency) {
    return '$exchange · $currency';
  }

  @override
  String get confirmListingSkip => 'Skip — save as typed';

  @override
  String get resolveDeferredSaved =>
      'Saved. The exact market symbol will be resolved on the next price refresh.';

  @override
  String get booksCopyPassphrase => 'Frasa sandi';

  @override
  String replaceBooksWarning(String counts) {
    return 'This will replace all entries and the books\' settings on this phone ($counts). It does not merge. Your language and unlock settings stay on this phone.';
  }

  @override
  String get saveCopyFirstAction => 'Save a copy first';

  @override
  String replaceCountEntries(int count) {
    return '$count entries';
  }

  @override
  String replaceCountAccounts(int count) {
    return '$count accounts';
  }

  @override
  String replaceCountCategories(int count) {
    return '$count categories';
  }

  @override
  String replaceCountGroups(int count) {
    return '$count account groups';
  }

  @override
  String replaceCountPayees(int count) {
    return '$count payees';
  }

  @override
  String replaceCountCategoryRules(int count) {
    return '$count category rules';
  }

  @override
  String replaceCountCsvProfiles(int count) {
    return '$count import profiles';
  }

  @override
  String replaceCountRecurringTemplates(int count) {
    return '$count recurring templates';
  }

  @override
  String replaceCountInstruments(int count) {
    return '$count instruments';
  }

  @override
  String get claimsTitle => 'Claims';

  @override
  String get claimsReviewTitle => 'Review claims';

  @override
  String get claimsStatusDraft => 'Draft';

  @override
  String get claimsStatusSubmitted => 'Submitted';

  @override
  String get claimsStatusPartlyApproved => 'Partly approved';

  @override
  String get claimsStatusApproved => 'Approved';

  @override
  String get claimsStatusPaid => 'Paid';

  @override
  String get claimsStatusRejected => 'Rejected';

  @override
  String get claimsApprove => 'Approve';

  @override
  String get claimsApproveDifferent => 'Approve different amount';

  @override
  String get claimsReject => 'Reject';

  @override
  String get claimsReasonRequired => 'A reason is required';

  @override
  String get claimsAdvances => 'Advances';

  @override
  String get claimsAddPerson => 'Add a person';

  @override
  String get claimsRoleApprover => 'Approver';

  @override
  String get claimsRoleClaimant => 'Claimant';

  @override
  String claimsBalanceCompanyOwesYou(String company) {
    return '$company owes you';
  }

  @override
  String claimsBalanceYouOweCompany(String company) {
    return 'You owe $company';
  }

  @override
  String claimsBalanceSettled(String company) {
    return 'Settled with $company';
  }

  @override
  String get claimsReceiptRequired =>
      'A receipt is required for this claim item';

  @override
  String get claimsReceiptPdfTooLarge =>
      'This PDF is larger than 5 MB. Choose a smaller file.';

  @override
  String claimsSpendingHint(String amount, String unit) {
    return 'Hint: at most $amount per $unit';
  }

  @override
  String get claimsNoClaimsYet => 'No claims yet.';

  @override
  String get claimsNoClaimsToReview => 'No claims to review.';

  @override
  String get claimsAdvanceDefault => 'Advance';

  @override
  String claimsItemCount(int count) {
    return '$count item(s)';
  }

  @override
  String get claimsRejectReasonTitle => 'Reject reason';

  @override
  String get claimsApproveDifferentReasonTitle =>
      'Approve different amount reason';

  @override
  String get claimsPersonNameLabel => 'Person name';

  @override
  String get claimsRemovePerson => 'Remove';

  @override
  String claimsRemovePersonTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String claimsRemovePersonWarning(String name, int openClaims) {
    return '$name has $openClaims open Claims and a non-zero owed balance. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningOpenOnly(String name, int openClaims) {
    return '$name has $openClaims open Claims. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningBalanceOnly(String name) {
    return '$name has a non-zero owed balance. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningClean(String name) {
    return 'Remove $name? History and receipts stay in these books.';
  }

  @override
  String get claimsRemovePersonConfirm => 'Remove';
}
