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
  String get providerFrankfurter => 'Frankfurter (kurs ECB)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (kuotasi harian)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API grafik)';

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
  String get keystoreExportFailed =>
      'Tidak dapat mengekspor file keystore. Anda dapat melewati langkah ini.';

  @override
  String get enterPassphraseToProtect =>
      'Masukkan frasa sandi untuk melindungi file ini.';

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
  String get recoveryPhraseTitle => 'Frasa pemulihan Anda';

  @override
  String get recoveryPhraseConfirmTitle => 'Konfirmasi frasa Anda';

  @override
  String get recoveryPhraseBlurb =>
      '24 kata ini adalah satu-satunya cara untuk memulihkan riwayat transaksi Anda jika perangkat ini hilang, direset, atau diganti. Smara Pembukuan tidak memiliki server dan tidak dapat memulihkannya untuk Anda.\n\nJika Anda kehilangan perangkat ini beserta frasa ini, setiap transaksi yang telah Anda catat menjadi tidak dapat diverifikasi secara permanen.';

  @override
  String get recoveryPhraseWriteDown =>
      'Tuliskan kata-kata ini secara berurutan dan simpan di tempat yang aman, terpisah dari perangkat ini.';

  @override
  String get iveSavedRecoveryPhrase =>
      'Saya telah menyimpan frasa pemulihan saya';

  @override
  String get confirmPhraseBlurb =>
      'Masukkan kata-kata yang diminta dari frasa yang baru saja Anda simpan.';

  @override
  String wordNumber(String n) {
    return 'Kata #$n';
  }

  @override
  String get keystoreExportTitle => 'Ekspor file keystore';

  @override
  String get keystoreExportBlurb =>
      'Selain frasa pemulihan Anda, Anda dapat menyimpan file keystore terenkripsi yang dilindungi oleh frasa sandi pilihan Anda. Ini opsional - frasa pemulihan Anda saja selalu cukup untuk memulihkan kunci penandatanganan Anda.';

  @override
  String get keystorePassphrase => 'Frasa sandi';

  @override
  String get exportKeystoreFile => 'Ekspor file keystore';

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
  String get restoreTitle => 'Pulihkan kunci penandatanganan';

  @override
  String get restoreBlurb =>
      'Perangkat ini memiliki pembukuan yang sudah ada, tetapi tidak ada kunci penandatanganan yang cocok. Pulihkan dari frasa pemulihan atau file keystore yang tersimpan - data Anda akan terverifikasi secara normal, dan tidak ada yang akan ditandatangani ulang atau diubah.';

  @override
  String get recoveryPhrase24 => 'Frasa pemulihan (semua 24 kata)';

  @override
  String get keystoreFile => 'File keystore';

  @override
  String get keystoreFileContents => 'Isi file keystore';

  @override
  String get optionalBackupFile => 'File cadangan opsional';

  @override
  String get iDontHavePhrase =>
      'Saya tidak memiliki frasa pemulihan atau file keystore saya';

  @override
  String get migrationTitle => 'Migrasi ke kunci baru';

  @override
  String get migrationBlurb =>
      'Tanpa frasa pemulihan atau file keystore Anda, kunci penandatanganan perangkat ini tidak dapat dipulihkan. Anda dapat memulai kunci baru. Entri lama tetap terlihat tetapi dianggap digantikan.';

  @override
  String get iConfirmBooksValid =>
      'Saya mengonfirmasi bahwa pembukuan saat ini valid';

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
  String get errorSigningIdentityMismatch =>
      'Frasa pemulihan atau file keystore ini tidak cocok dengan identitas penandatanganan mana pun di database ini.';

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
  String get errorForeignBackupIdentity =>
      'Cadangan ini milik identitas penandatanganan yang berbeda dari yang ada di perangkat ini.';

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
  String get validationWrongKeystorePassphrase =>
      'Frasa sandi salah untuk file keystore ini.';

  @override
  String get validationInvalidKeystoreFile =>
      'Itu tampaknya bukan file keystore yang valid.';

  @override
  String get validationRestorePhraseFailed =>
      'Tidak dapat memulihkan dari frasa pemulihan tersebut.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Tidak dapat membuat kunci penandatanganan di perangkat ini: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Tidak dapat menyimpan mata uang ini: $detail';
  }

  @override
  String get validationMigrationFailed => 'Migrasi gagal. Silakan coba lagi.';

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
  String validationConfirmWordMismatch(String n) {
    return 'Kata $n tidak cocok dengan frasa tersimpan Anda. Periksa dan coba lagi.';
  }

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
  String get unlockBiometricReason => 'Buka kunci Smara Pembukuan';

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
}
