// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Smara Contabilidad';

  @override
  String get navHome => 'Inicio';

  @override
  String get navRegister => 'Registro';

  @override
  String get navSummary => 'Resumen';

  @override
  String get navAccounts => 'Cuentas';

  @override
  String get navCategories => 'Categorías';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionDismiss => 'Cerrar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionCloseApp => 'Cerrar la aplicación';

  @override
  String get actionUnlock => 'Desbloquear';

  @override
  String get actionSettle => 'Liquidar';

  @override
  String get actionFinish => 'Finalizar';

  @override
  String get actionPreview => 'Vista previa';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExportCsv => 'Exportar CSV';

  @override
  String get actionChooseFile => 'Elegir archivo';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionFix => 'Corregir';

  @override
  String get actionBuy => 'Comprar';

  @override
  String get actionSell => 'Vender';

  @override
  String get actionDividend => 'Dividendo';

  @override
  String get actionRecordBuy => 'Registrar compra';

  @override
  String get actionRecordSell => 'Registrar venta';

  @override
  String get actionRecordDividend => 'Registrar dividendo';

  @override
  String get actionPayCard => 'Pagar tarjeta';

  @override
  String get actionTransfer => 'Transferir';

  @override
  String get actionRecordTransaction => 'Registrar transacción';

  @override
  String get actionImportStatement => 'Importar extracto';

  @override
  String get actionClearDates => 'Borrar fechas';

  @override
  String get actionClearSearch => 'Borrar búsqueda y filtros';

  @override
  String get actionUseBiometrics => 'Usar biometría';

  @override
  String get actionSetPin => 'Establecer PIN';

  @override
  String get actionChangePin => 'Cambiar PIN';

  @override
  String get actionSaveBackup => 'Guardar copia de seguridad';

  @override
  String get actionRestoreBackup => 'Restaurar copia de seguridad';

  @override
  String get actionSaveRule => 'Guardar regla';

  @override
  String get actionConfirmFix => 'Confirmar corrección';

  @override
  String get captureSpent => 'Gastado';

  @override
  String get captureReceived => 'Recibido';

  @override
  String get captureMovedMoney => 'Dinero movido';

  @override
  String get captureImportStatement => 'Importar extracto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del dispositivo';

  @override
  String get settingsFetchFxRates => 'Obtener tipos de cambio de referencia';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Muestra un tipo de cambio orientativo junto al importe de destino en transferencias entre divisas, solo para comparar - nunca se usa para rellenar el importe.';

  @override
  String get settingsRateProvider => 'Proveedor de tipos de cambio';

  @override
  String get settingsFetchMarketPrices =>
      'Obtener precios de mercado para inversiones';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Consulta los últimos precios de los instrumentos que tienen un ticker o ISIN, para estimar el valor de la cartera. Nunca se usa para registrar una operación, y nunca envía cuántas unidades posees.';

  @override
  String get settingsMarketPriceProvider => 'Proveedor de precios de mercado';

  @override
  String get settingsFavouriteResearchTool =>
      'Herramienta de investigación favorita';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Al tocar el nombre de un instrumento en tus posiciones se abre esta herramienta en el navegador con una consulta de investigación — no es una integración ni un consejo.';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsBackupBlurb =>
      'Guarda una copia cifrada de tus libros en la ubicación que elijas, o restaura desde una. Esto es independiente de tu frase de recuperación o tu archivo de almacén de claves, que respaldan tu clave de firma, no tus libros.';

  @override
  String get settingsLock => 'Bloqueo';

  @override
  String get settingsLockBlurb =>
      'Exige un PIN, o biometría cuando esté disponible, para abrir la aplicación.';

  @override
  String get settingsRequireUnlock =>
      'Exigir desbloqueo para abrir la aplicación';

  @override
  String get settingsLockAfter => 'Bloquear después de';

  @override
  String get settingsLockImmediately => 'Inmediatamente';

  @override
  String get settingsLock1Minute => '1 minuto';

  @override
  String get settingsLock5Minutes => '5 minutos';

  @override
  String get settingsLock15Minutes => '15 minutos';

  @override
  String get settingsAllowBiometrics => 'Permitir también biometría';

  @override
  String get settingsHideSnapshot =>
      'Ocultar saldos en el selector de aplicaciones';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Difumina esta pantalla cuando cambias a otra aplicación, para que no sea visible de un vistazo en el selector de aplicaciones.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Ocultar saldos en el selector de aplicaciones no está disponible en esta plataforma.';

  @override
  String get settingsPayees => 'Beneficiarios';

  @override
  String get settingsManagePayees => 'Gestionar beneficiarios';

  @override
  String get settingsPayeesBlurb =>
      'Nombres de beneficiarios recordados junto con su categoría y cuenta predeterminadas, sugeridos por autocompletar al registrar una transacción.';

  @override
  String get settingsRecurring => 'Plantillas recurrentes';

  @override
  String get settingsManageRecurring => 'Gestionar plantillas recurrentes';

  @override
  String get settingsRecurringBlurb =>
      'Facturas o ingresos que se repiten cada mes, como el alquiler o una nómina. Una plantilla pendiente aparece en Inicio para que la registres con un toque - nunca se registra automáticamente.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get providerFrankfurter => 'Frankfurter (tasas del BCE)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (cotizaciones diarias)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API de gráficos)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents =>
      'Efectivo y equivalentes de efectivo';

  @override
  String get systemGroupPensionRetirement => 'Pensión y jubilación';

  @override
  String get systemGroupCreditShortTerm => 'Crédito y deuda a corto plazo';

  @override
  String get systemGroupLoansMortgages => 'Préstamos e hipotecas';

  @override
  String get systemGroupInvestments => 'Inversiones';

  @override
  String get systemAccountCashBank => 'Efectivo y banco';

  @override
  String get systemCategorySalary => 'Salario';

  @override
  String get systemCategoryOtherIncome => 'Otros ingresos';

  @override
  String get systemCategoryGroceries => 'Comestibles';

  @override
  String get systemCategoryRentMortgage => 'Alquiler/Hipoteca';

  @override
  String get systemCategoryUtilities => 'Servicios públicos';

  @override
  String get systemCategoryTransport => 'Transporte';

  @override
  String get systemCategoryFoodOut => 'Comer fuera';

  @override
  String get systemCategoryPhone => 'Teléfono';

  @override
  String get systemCategoryHealth => 'Salud';

  @override
  String get systemCategoryOtherExpense => 'Otros gastos';

  @override
  String get homeThisMonth => 'ESTE MES';

  @override
  String get homeMoneyInTransit => 'DINERO EN TRÁNSITO';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'LO QUE TIENES MENOS LO QUE DEBES';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Lo que tienes $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Lo que tienes $haveAmount $currency  •  Lo que debes $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Enviaste $amount $currency desde $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Enviaste $amount $currency a $name';
  }

  @override
  String get hiddenLabel => 'Oculto';

  @override
  String get allAccounts => 'Todas las cuentas';

  @override
  String savedToPath(String path) {
    return 'Guardado en $path';
  }

  @override
  String get keystoreExportFailed =>
      'No se pudo exportar el archivo de almacén de claves. Puedes omitir este paso.';

  @override
  String get enterPassphraseToProtect =>
      'Introduce una contraseña para proteger el archivo.';

  @override
  String get homeTapWhenArrived => 'Toca cuando sepas qué llegó';

  @override
  String homeReturnedTo(String name) {
    return 'Devuelto a $name';
  }

  @override
  String get homeDueToday => 'VENCE HOY';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · toca para registrar';
  }

  @override
  String get homeOverLimit => 'Por encima del límite';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Restante: $amount';
  }

  @override
  String get homeNoAccounts => 'Sin cuentas';

  @override
  String get homeCashRegister => 'Caja registradora';

  @override
  String get homeMarketEstimate => 'Estimación de mercado';

  @override
  String get registerTitle => 'Registro';

  @override
  String get registerSearchHint => 'Descripción, categoría o importe';

  @override
  String get registerNoTransactions => 'Aún no hay transacciones';

  @override
  String get registerNoEntries => 'Aún no se ha registrado ninguna entrada.';

  @override
  String get registerSpentOnly => 'Solo gastos';

  @override
  String get registerReceivedOnly => 'Solo ingresos';

  @override
  String get registerAll => 'Todo';

  @override
  String get registerUnverified => 'Sin verificar - excluido de los totales';

  @override
  String get registerSuperseded =>
      'Sustituido por una migración - excluido de los totales';

  @override
  String get summaryTitle => 'Resumen';

  @override
  String get summaryTotalIncome => 'Ingresos totales';

  @override
  String get summaryTotalExpense => 'Gastos totales';

  @override
  String summaryDateRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get renameAccount => 'Renombrar cuenta';

  @override
  String get renameCategory => 'Renombrar categoría';

  @override
  String get addCategory => 'Añadir categoría';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get kindLabel => 'Tipo';

  @override
  String get asset => 'Activo';

  @override
  String get liability => 'Pasivo';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get thisAccountHoldsInvestments => 'Esta cuenta contiene inversiones';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Efectivo más el inventario que registras con Comprar, Vender y Dividendo.';

  @override
  String get thisIsACreditCard => 'Esta es una tarjeta de crédito';

  @override
  String get openingBalanceOptional => 'Saldo inicial (opcional)';

  @override
  String get currencyIso => 'Moneda (ISO 4217)';

  @override
  String get currencyIsoExample => 'Moneda (ISO 4217, p. ej. USD)';

  @override
  String get hideAccountTitle => '¿Ocultar la cuenta de las nuevas entradas?';

  @override
  String get hideCategoryTitle =>
      '¿Ocultar la categoría de las nuevas entradas?';

  @override
  String get hideGroupTitle => '¿Ocultar el grupo de las nuevas entradas?';

  @override
  String get reassignGroup => 'Reasignar grupo';

  @override
  String get transferRemainingBalance => 'Transferir el saldo restante';

  @override
  String get monthlyLimit => 'Límite mensual';

  @override
  String get monthlyLimitHint => 'Límite (deja en blanco para borrarlo)';

  @override
  String get monthlyLimitBlurb =>
      'Una guía opcional del gasto acumulado en el mes para esta categoría de gasto.';

  @override
  String get manageCategoryRules => 'Gestionar reglas de categorías';

  @override
  String get amount => 'Importe';

  @override
  String get category => 'Categoría';

  @override
  String get account => 'Cuenta';

  @override
  String get fromAccount => 'Cuenta de origen';

  @override
  String get toAccount => 'Cuenta de destino';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get alsoRememberPayee => 'Recordar también como beneficiario';

  @override
  String get splitIntoCategories => 'Dividir en varias categorías';

  @override
  String categoryN(String n) {
    return 'Categoría $n';
  }

  @override
  String get destinationAmount => 'Importe de destino';

  @override
  String get destinationAmountOptional => 'Importe de destino (opcional)';

  @override
  String get accountCurrencyAmountOptional =>
      'Importe en la moneda de la cuenta (opcional)';

  @override
  String get transactionCurrencyOptional =>
      'Moneda de la transacción (opcional)';

  @override
  String get feeOptional => 'Comisión (opcional)';

  @override
  String get feeAmount => 'Importe de la comisión';

  @override
  String get feeCategory => 'Categoría de la comisión';

  @override
  String get feeDescriptionOptional => 'Descripción de la comisión (opcional)';

  @override
  String get feeDeducted => 'La comisión se descuenta del importe anterior';

  @override
  String get needTwoAccountsToTransfer =>
      'Crea al menos dos cuentas activas para hacer una transferencia.';

  @override
  String get whatArrivedTitle => '¿Qué llegó?';

  @override
  String get whatArrivedBlurb => 'Indícanos qué llegó realmente.';

  @override
  String get amountThatArrived => 'Importe que llegó';

  @override
  String get feeLossCategory => 'Categoría de comisión / pérdida';

  @override
  String get alreadySettled => 'Ya liquidado.';

  @override
  String get holdingsTitle => 'Posiciones';

  @override
  String get holdingsCash => 'Efectivo';

  @override
  String get holdingsInventory => 'INVENTARIO';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Contable (efectivo + coste) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Estimación de mercado $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Aún no hay posiciones. Registra una compra para añadir un instrumento.';

  @override
  String get holdingsQuotesBlurb =>
      'Las cotizaciones son estimaciones, no un precio de bróker. Esta aplicación no realiza órdenes.';

  @override
  String get holdingsTapNameToResearch =>
      'Toca el nombre para investigar. Las cotizaciones son estimaciones, no consejos.';

  @override
  String get instrument => 'Instrumento';

  @override
  String get newInstrument => 'Nuevo instrumento';

  @override
  String get renameInstrument => 'Renombrar instrumento';

  @override
  String get instrumentActions => 'Acciones del instrumento';

  @override
  String hideInstrumentTitle(String name) {
    return '¿Ocultar $name?';
  }

  @override
  String get tickerOptional => 'Ticker (opcional)';

  @override
  String get isinOptional => 'ISIN (opcional)';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unitPrice => 'Precio unitario';

  @override
  String get brokerageOptional => 'Comisión de corretaje (opcional)';

  @override
  String get brokerageExpenseCategory => 'Categoría de gasto de corretaje';

  @override
  String get incomeCategory => 'Categoría de ingreso';

  @override
  String get gainIncomeCategory => 'Categoría de ingreso por ganancia';

  @override
  String get lossExpenseCategory => 'Categoría de gasto por pérdida';

  @override
  String get nonCash => 'Sin efectivo';

  @override
  String get cash => 'Efectivo';

  @override
  String get locked => 'Bloqueado';

  @override
  String get lockUntilHint =>
      'Tu propia nota de una restricción, no una regla del bróker.';

  @override
  String get instrumentKindStock => 'Acción';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Fondo de inversión';

  @override
  String get instrumentKindBond => 'Bono';

  @override
  String get instrumentKindOther => 'Otro';

  @override
  String get quoteUseLive => 'Precio en vivo';

  @override
  String get quoteUseCached => 'Precio en caché';

  @override
  String get quoteUseStale => 'Precio desactualizado';

  @override
  String get quoteUseMissing => 'Usando el coste (sin precio)';

  @override
  String get quoteUseDisabled =>
      'Cotizaciones desactivadas — usando coste/caché';

  @override
  String get quoteUseCurrencyMismatch =>
      'Usando el coste (la moneda del precio difiere)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'No realizado $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty unidades · ';
  }

  @override
  String get recoveryPhraseTitle => 'Tu frase de recuperación';

  @override
  String get recoveryPhraseConfirmTitle => 'Confirma tu frase';

  @override
  String get recoveryPhraseBlurb =>
      'Estas 24 palabras son la única forma de recuperar tu historial de transacciones si este dispositivo se pierde, se restablece o se sustituye. Smara Accounting no tiene servidor y no puede recuperarlas por ti.\n\nSi pierdes este dispositivo y esta frase juntos, cada transacción que hayas registrado se vuelve permanentemente inverificable.';

  @override
  String get recoveryPhraseWriteDown =>
      'Escribe estas palabras en orden y guárdalas en un lugar seguro, separado de este dispositivo.';

  @override
  String get iveSavedRecoveryPhrase => 'He guardado mi frase de recuperación';

  @override
  String get confirmPhraseBlurb =>
      'Introduce las palabras solicitadas de la frase que acabas de guardar.';

  @override
  String wordNumber(String n) {
    return 'Palabra n.º $n';
  }

  @override
  String get keystoreExportTitle => 'Exportar archivo de almacén de claves';

  @override
  String get keystoreExportBlurb =>
      'Además de tu frase de recuperación, puedes guardar un archivo de almacén de claves cifrado protegido por una contraseña que elijas. Esto es opcional - tu frase de recuperación por sí sola siempre es suficiente para restaurar tu clave de firma.';

  @override
  String get keystorePassphrase => 'Contraseña';

  @override
  String get exportKeystoreFile => 'Exportar archivo de almacén de claves';

  @override
  String get chooseCurrencyTitle => 'Elige tu moneda';

  @override
  String get chooseCurrencyBlurb =>
      'Por ahora, cada grupo de cuentas (Efectivo y equivalentes de efectivo, Pensión y jubilación, etc.) usa esta única moneda. Más adelante podrás añadir cuentas en otra moneda creando un nuevo grupo para ella.';

  @override
  String get currencyBackfillTitle =>
      'Elige una moneda para los grupos existentes';

  @override
  String get currencyBackfillBlurb =>
      'Esta aplicación ahora admite varias monedas. Tus cuentas y grupos de cuentas existentes necesitan una moneda - como todos se crearon antes de que existiera esta función, una sola elección se aplica a todos ellos.';

  @override
  String get firstAccountTitle => 'Ponle nombre a tu cuenta';

  @override
  String get firstAccountBlurb =>
      'Esta es la cuenta que ya está creada para ti - dale un nombre que reconozcas, como tu banco. A continuación registrarás un gasto o un ingreso, y luego protegerás el dispositivo con tu frase de recuperación.';

  @override
  String get whatsMainAccountCalled => '¿Cómo se llama tu cuenta principal?';

  @override
  String get restoreTitle => 'Restaurar clave de firma';

  @override
  String get restoreBlurb =>
      'Este dispositivo tiene libros existentes, pero ninguna clave de firma coincidente. Restáurala desde tu frase de recuperación guardada o tu archivo de almacén de claves - tus datos se verificarán con normalidad y nada se volverá a firmar ni se alterará.';

  @override
  String get recoveryPhrase24 => 'Frase de recuperación (las 24 palabras)';

  @override
  String get keystoreFile => 'Archivo de almacén de claves';

  @override
  String get keystoreFileContents =>
      'Contenido del archivo de almacén de claves';

  @override
  String get optionalBackupFile => 'Archivo de copia de seguridad opcional';

  @override
  String get iDontHavePhrase =>
      'No tengo mi frase de recuperación ni el archivo de almacén de claves';

  @override
  String get migrationTitle => 'Migrar a una nueva clave';

  @override
  String get migrationBlurb =>
      'Sin tu frase de recuperación o tu archivo de almacén de claves, la clave de firma de este dispositivo no se puede recuperar. Puedes empezar con una clave nueva. Las entradas antiguas siguen visibles, pero quedan sustituidas.';

  @override
  String get iConfirmBooksValid =>
      'Confirmo que los libros actuales son válidos';

  @override
  String get whyWeDontEdit => 'Por qué no editamos las entradas antiguas';

  @override
  String get whyWeDontEditBody =>
      'Cuando corriges un error, conservamos la línea original y añadimos una corrección junto a ella en lugar de cambiar lo que ya introdujiste. Así tu historial siempre muestra exactamente qué sucedió y cuándo lo corregiste — nada cambia en silencio a tus espaldas.';

  @override
  String get lockTitle => 'Desbloquear';

  @override
  String get lockScreenTitle => 'Bloqueado';

  @override
  String get enterPinToContinue => 'Introduce el PIN para continuar';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Establecer un PIN';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get newPin => 'Nuevo PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get confirmNewPin => 'Confirmar nuevo PIN';

  @override
  String get firstWeekTitle => 'Configura tus cuentas';

  @override
  String get addCashAccount => 'Añadir una cuenta de efectivo';

  @override
  String get addCreditCard => 'Añadir una tarjeta de crédito';

  @override
  String get cashAccountName => 'Nombre de la cuenta de efectivo';

  @override
  String get cardName => 'Nombre de la tarjeta';

  @override
  String get paidFromBank => 'Pagado desde el banco';

  @override
  String get paidFromCard => 'Pagado desde la tarjeta';

  @override
  String get choosePassphraseTitle =>
      'Elige una contraseña para proteger esta copia de seguridad. No hay forma de recuperarla si la olvidas.';

  @override
  String get replaceBooksTitle => '¿Reemplazar tus libros locales?';

  @override
  String get replaceBooksBody =>
      'Esto reemplaza todo lo que hay actualmente en esta aplicación con la copia de seguridad. Cierra y vuelve a abrir la aplicación después.';

  @override
  String get chooseBackupFileFirst =>
      'Elige primero un archivo de copia de seguridad.';

  @override
  String get backupRestored => 'Copia de seguridad restaurada';

  @override
  String get backupRestoredBody =>
      'Tus libros se han restaurado. Cierra y vuelve a abrir la aplicación para continuar.';

  @override
  String get fixThisEntry => 'Corregir esta entrada';

  @override
  String get fixBlurb =>
      'La línea original permanece exactamente igual. Confirmar añade una línea de reversión y la corregida.';

  @override
  String get importStatementTitle => 'Importar extracto';

  @override
  String get importOfx => 'Importar OFX';

  @override
  String get importOfxQfxFile => 'Importar archivo OFX / QFX';

  @override
  String get importCsvFile => 'Importar archivo CSV';

  @override
  String get whatKindOfStatement => '¿Qué tipo de archivo de extracto tienes?';

  @override
  String get chooseAccountForFile =>
      'Elige a qué cuenta pertenece este archivo.';

  @override
  String get importIntoAccount => 'Importar a la cuenta';

  @override
  String get useSavedProfile => 'Usar un perfil guardado';

  @override
  String get saveMappingProfile =>
      'Guardar esta asignación como perfil (opcional)';

  @override
  String get renameProfile => 'Renombrar perfil';

  @override
  String get deleteProfileTitle => '¿Eliminar el perfil?';

  @override
  String get fileHasHeader => 'El archivo tiene una fila de encabezado';

  @override
  String get dateColumn => 'Columna de fecha';

  @override
  String get dateFormatHint => 'Formato de fecha (p. ej. dd/MM/aaaa)';

  @override
  String get amountColumn => 'Columna de importe';

  @override
  String get amountConvention => 'Convención de importe';

  @override
  String get signedAmountColumn => 'Columna de importe con signo';

  @override
  String get separateDebitCredit => 'Columnas separadas de débito / crédito';

  @override
  String get debitColumn => 'Columna de débito';

  @override
  String get creditColumn => 'Columna de crédito';

  @override
  String get decimalSeparator => 'Separador decimal (. o ,)';

  @override
  String get descriptionColumns => 'Columna(s) de descripción';

  @override
  String get referenceIdColumn =>
      'Columna de identificador de referencia (opcional)';

  @override
  String get skippedRows => 'Filas omitidas';

  @override
  String parsedTransactionCount(String count) {
    return '$count transacciones analizadas';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count omitidas o excluidas';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted registradas, $failed fallidas';
  }

  @override
  String get categoryForAll => 'Categoría para todas';

  @override
  String get saveAsRule => '¿Guardar como regla?';

  @override
  String get saveAsRuleBlurb =>
      'Las futuras importaciones cuya descripción contenga esta palabra clave usarán esta categoría.';

  @override
  String get keyword => 'Palabra clave';

  @override
  String get noSavedRules =>
      'Aún no hay reglas guardadas. Asigna una categoría a un grupo de filas para guardar una regla.';

  @override
  String get deleteRuleTitle => '¿Eliminar la regla?';

  @override
  String get editRule => 'Editar regla';

  @override
  String rowsGrouped(String count) {
    return '$count filas';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Selecciona un archivo de extracto $extensions para importar';
  }

  @override
  String get payeesTitle => 'Beneficiarios';

  @override
  String get addPayee => 'Añadir beneficiario';

  @override
  String get renamePayee => 'Renombrar beneficiario';

  @override
  String get deletePayeeTitle => '¿Eliminar el beneficiario?';

  @override
  String get noPayeesYet => 'Aún no hay beneficiarios';

  @override
  String get recurringTitle => 'Plantillas recurrentes';

  @override
  String get noRecurringYet => 'Aún no hay plantillas recurrentes';

  @override
  String get deleteTemplateTitle => '¿Eliminar la plantilla recurrente?';

  @override
  String get dayOfMonth => 'Día del mes (1-31)';

  @override
  String get dayOfMonthNote =>
      'Un mes con menos días usa su propio último día.';

  @override
  String dayOfMonthLine(String day) {
    return 'Día $day del mes - ';
  }

  @override
  String get name => 'Nombre';

  @override
  String get none => 'Ninguno';

  @override
  String get currency => 'Moneda';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get errorSigningIdentityMismatch =>
      'Esta frase de recuperación o archivo de almacén de claves no coincide con ninguna identidad de firma en esta base de datos.';

  @override
  String get errorInvalidLedgerBackup =>
      'Este archivo no es una copia de seguridad válida de Smara.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Esta copia de seguridad no tiene identidad de firma - no es una copia de seguridad válida de Smara.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Esta copia de seguridad no se verificó como libros íntegros, por lo que no se restauró.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Este archivo no se pudo abrir como copia de seguridad de Smara: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Esta copia de seguridad pertenece a una identidad de firma distinta a la de este dispositivo.';

  @override
  String get errorAccountNotFinancial => 'Esa no es una cuenta financiera.';

  @override
  String get errorAccountArchived => 'Esa cuenta está oculta.';

  @override
  String get errorAccountNotArchived => 'Esa cuenta no está oculta.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'No queda saldo por transferir.';

  @override
  String get errorAccountHasNoGroup => 'Esa cuenta no tiene un grupo asignado.';

  @override
  String get errorGroupHasNoCurrency =>
      'Ese grupo aún no tiene una moneda establecida.';

  @override
  String get errorGroupNotFound => 'No se encontró ese grupo de cuentas.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Solo las cuentas de activo se pueden marcar como cuentas de inversión.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Solo las cuentas de pasivo se pueden marcar como tarjetas de crédito.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'El saldo inicial debe ser positivo cuando se indica.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Ese tipo de cuenta no coincide con el grupo.';

  @override
  String get errorLastActiveAccount =>
      'No se puede ocultar la última cuenta financiera activa.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Se requiere una moneda para crear un grupo.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Los grupos de cuentas integrados no se pueden ocultar.';

  @override
  String get errorGroupAlreadyArchived => 'Ese grupo ya está oculto.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'No se puede ocultar un grupo que todavía tiene cuentas activas.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Los grupos de cuentas integrados nunca se ocultan.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Los grupos de cuentas no se pueden eliminar.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'No se puede mover esta cuenta a un grupo con una moneda diferente.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'No se puede cambiar la moneda mientras el grupo tenga cuentas activas.';

  @override
  String get errorAmountMustBePositive => 'El importe debe ser positivo.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'El importe en la moneda de la cuenta debe ser positivo.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'El importe en la moneda de la cuenta solo es para una entrada en moneda extranjera.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Una división necesita al menos dos líneas de categoría.';

  @override
  String get errorSplitLineMustBePositive =>
      'Cada línea de la división debe ser un importe positivo.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Las líneas de la división deben sumar el total de la transacción.';

  @override
  String get errorTransferAmountMustBePositive =>
      'El importe de la transferencia debe ser positivo.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Las cuentas de origen y destino deben ser diferentes.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Un cierre entre divisas necesita un importe de destino conocido.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'El importe de destino solo es para una transferencia entre divisas.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'El importe de destino debe ser positivo.';

  @override
  String get errorInvestmentCashExceeded =>
      'No se puede transferir más del efectivo de esta cuenta de inversión.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Liquida esta transferencia pendiente en lugar de revertirla.';

  @override
  String get errorAlreadyReversed =>
      'Esta entrada ya se ha corregido. La línea original permanece tal cual.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Elige una categoría de gasto activa.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Elige una categoría de ingreso activa.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'El importe que llegó no puede ser negativo.';

  @override
  String get errorPendingTransferNotFound =>
      'No se encontró esa transferencia pendiente.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Esa transferencia pendiente ya está liquidada.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Elige la cuenta de origen o destino original.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Una categoría de comisión solo se usa cuando el dinero se devuelve a la cuenta de origen.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Introduce un importe positivo para lo que llegó.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Ese importe es mayor que el enviado.';

  @override
  String get errorInstrumentNotFound => 'No se encontró ese instrumento.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Se requiere una categoría de ingreso activa para una adquisición sin efectivo.';

  @override
  String get errorInsufficientCash =>
      'No hay suficiente efectivo en esta cuenta de inversión para esa compra.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'La cantidad de venta y el precio unitario deben ser positivos.';

  @override
  String errorLockedUntil(String date) {
    return 'No se puede vender: algunas unidades están bloqueadas hasta $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'No se puede vender más de lo que actualmente posees sin bloquear.';

  @override
  String get errorIncomeRequiredForGain =>
      'Se requiere una categoría de ingreso activa para una ganancia realizada.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Se requiere una categoría de gasto activa para una pérdida realizada.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Compra registrada, pero la comisión de corretaje falló: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Venta registrada, pero la comisión de corretaje falló: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'El importe del dividendo debe ser positivo.';

  @override
  String get errorNotInvestmentAccount => 'Esa no es una cuenta de inversión.';

  @override
  String get errorNoInventoryCompanion =>
      'A esta cuenta de inversión le falta su cuenta de inventario asociada.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'No se puede revertir esta compra: hay ventas posteriores que dependen de sus unidades. Revierte primero las ventas dependientes: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'El límite mensual debe ser positivo.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'El importe de la plantilla debe ser positivo.';

  @override
  String get errorOfxUnrecognized =>
      'No se pudo reconocer este archivo como OFX.';

  @override
  String get errorCsvEmpty => 'El archivo seleccionado está vacío.';

  @override
  String get errorCsvUnreadable => 'No se pudo leer este archivo como CSV.';

  @override
  String get errorCsvNoRows => 'El archivo seleccionado no tiene filas.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'No se pudo crear la copia de seguridad: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'No se pudo restaurar esta copia de seguridad - contraseña incorrecta, o no es un archivo de copia de seguridad de Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'El importe, la cuenta y la categoría son obligatorios.';

  @override
  String get validationAmountAccountRequired =>
      'El importe y la cuenta son obligatorios.';

  @override
  String get validationSplitLineIncomplete =>
      'Cada línea de la división necesita una categoría y un importe.';

  @override
  String get validationSplitSumMismatch =>
      'Las líneas de la división deben sumar el total de la transacción.';

  @override
  String get validationFromToAmountRequired =>
      'La cuenta de origen, la cuenta de destino y el importe son obligatorios.';

  @override
  String get validationAmountArrivedRequired =>
      'El importe que llegó es obligatorio.';

  @override
  String get validationChooseReceivingAccount =>
      'Elige qué cuenta recibió los fondos.';

  @override
  String get validationAccountCategoryRequired =>
      'La cuenta y la categoría son obligatorias.';

  @override
  String get validationFixFailed => 'No se pudo guardar esta corrección.';

  @override
  String get validationNameRequired => 'Ponle nombre a tu cuenta principal.';

  @override
  String get validationStillLoading =>
      'Aún cargando - inténtalo de nuevo en un momento.';

  @override
  String get validationSaveAccountNameFailed =>
      'No se pudo guardar el nombre de la cuenta.';

  @override
  String get validationWrongPin => 'PIN incorrecto. Inténtalo de nuevo.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'La categoría debe ser de tipo Ingreso o Gasto.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Solo una categoría de gasto puede tener un límite mensual.';

  @override
  String get validationInvalidTemplate => 'Plantilla no válida.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Contraseña incorrecta para este archivo de almacén de claves.';

  @override
  String get validationInvalidKeystoreFile =>
      'Eso no parece un archivo de almacén de claves válido.';

  @override
  String get validationRestorePhraseFailed =>
      'No se pudo restaurar con esa frase de recuperación.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'No se pudo generar una clave de firma en este dispositivo: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'No se pudo guardar esta moneda: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'La migración falló. Inténtalo de nuevo.';

  @override
  String get validationChooseBackupFile =>
      'Elige primero un archivo de copia de seguridad.';

  @override
  String get validationPassphraseRequired => 'Introduce una contraseña.';

  @override
  String get validationPinsDoNotMatch => 'Los dos PIN no coinciden.';

  @override
  String get validationFeePositiveWithCategory =>
      'La comisión de la transferencia debe ser un importe positivo con una categoría de gasto seleccionada.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'La comisión debe ser menor que el importe en una transferencia con comisión deducida.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Transferencia guardada, pero la comisión no se pudo registrar: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Introduce un importe válido.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'La palabra $n no coincide con tu frase guardada. Compruébala e inténtalo de nuevo.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'La cantidad de compra y el precio unitario deben ser positivos.';

  @override
  String get errorInstrumentArchived =>
      'No se puede comprar un instrumento oculto.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Las adquisiciones sin efectivo no pueden incluir comisión de corretaje.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Se requiere una categoría de gasto activa cuando la comisión de corretaje es positiva.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'El importe de la venta debe ser al menos igual a la comisión de corretaje.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent de $limit este mes';
  }

  @override
  String get unlockBiometricReason => 'Desbloquear Smara Account';

  @override
  String get searchLabel => 'Buscar';

  @override
  String get openingBalance => 'Saldo inicial';

  @override
  String transferToName(String name) {
    return 'Transferencia: $name';
  }

  @override
  String get feeForTransfer => 'Comisión de la transferencia';

  @override
  String feeForTransferTo(String name) {
    return 'Comisión de la transferencia a $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'No se pudo abrir el selector de archivos: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Selecciona un archivo .$extensions';
  }

  @override
  String get currencyCodeIso => 'Código de moneda (ISO 4217, p. ej. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name y $count más';
  }

  @override
  String get dateLabel => 'Fecha';

  @override
  String get noneSelected => 'Ninguno';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Revisa las entradas siguientes ($count en total) antes de continuar.';
  }

  @override
  String youReceived(String amount) {
    return 'Recibiste $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Déjalo en blanco si aún no conoces el tipo de cambio.';

  @override
  String get recordTradeBlurb =>
      'Registra una operación que ya ha tenido lugar. Esta aplicación no realiza órdenes.';

  @override
  String get feeOnTopBlurb =>
      'Activado: el importe anterior es el total retirado de esta cuenta; la comisión se descuenta de él.';

  @override
  String get feeBankBlurb =>
      'Una comisión inicial cobrada por tu banco o un intermediario.';

  @override
  String get validationPinMinLength => 'El PIN debe tener al menos 4 dígitos.';

  @override
  String get restoreBackupBlurb =>
      'Esto reemplaza todo lo que hay actualmente en esta aplicación con la copia de seguridad — no combina los datos. Elige un archivo de copia de seguridad e introduce la contraseña con la que lo protegiste.';

  @override
  String get actionReplace => 'Reemplazar';

  @override
  String hideAccountBody(String name) {
    return '$name dejará de estar disponible para nuevas transacciones.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name ya no se ofrecerá al crear o reasignar cuentas.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name ya no se ofrecerá al registrar nuevas transacciones.';
  }

  @override
  String get hideInstrumentBody =>
      'Los instrumentos ocultos permanecen en las compras y ventas pasadas. Aún puedes registrar un dividendo para ellos.';

  @override
  String nameHidden(String name) {
    return '$name (oculto)';
  }

  @override
  String get noCurrencySet => 'Sin moneda establecida';

  @override
  String deletePayeeBody(String name) {
    return '$name y sus valores predeterminados recordados se eliminarán. Las transacciones pasadas no se ven afectadas.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name ya no se ofrecerá como pendiente. Las transacciones pasadas que ya registró no se ven afectadas.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'La asignación de columnas guardada \"$name\" se eliminará. Los extractos ya importados con ella no se ven afectados.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Las importaciones ya no se categorizarán automáticamente mediante \"$keyword\". Las transacciones ya categorizadas con esta regla no se ven afectadas.';
  }

  @override
  String get firstWeekBlurb =>
      'Opcionalmente, añade ahora una tarjeta de crédito o una cuenta de efectivo - siempre puedes añadir más cuentas más adelante desde Ajustes.';

  @override
  String get deliveredToDestination => 'Entregado al destino';

  @override
  String deliveredToName(String name) {
    return 'Entregado a $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Recibiste $amount $currency menos de lo esperado - elige una categoría para cubrir la diferencia.';
  }

  @override
  String get dateRangeLabel => 'Intervalo de fechas';

  @override
  String get addTemplate => 'Añadir plantilla';

  @override
  String get editTemplate => 'Editar plantilla';

  @override
  String get validationFillTemplateFields =>
      'Rellena todos los campos con un importe y un día válidos.';

  @override
  String get saveCsvExport => 'Guardar exportación CSV';

  @override
  String get referenceRate => 'Tipo de referencia';

  @override
  String get yourRate => 'Tu tipo de cambio';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Déjalo en blanco si esto estaba en $currency, la propia moneda de la cuenta.';
  }

  @override
  String get lockUntilOptional => 'Bloquear hasta (opcional)';

  @override
  String lockedUntilDate(String date) {
    return 'Bloqueado hasta $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Se copió una consulta de investigación — no hay una URL de navegador disponible, o estás sin conexión.';

  @override
  String get openedFavouriteResearchTool =>
      'Se abrió tu herramienta de investigación favorita.';

  @override
  String get looksLikeGain => 'Esto parece una ganancia';

  @override
  String get looksLikeLoss => 'Esto parece una pérdida';

  @override
  String get looksLikeBreakEven => 'Esto parece un punto de equilibrio';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty vendible)';
  }

  @override
  String columnN(String index) {
    return 'Columna $index';
  }

  @override
  String get importingLabel => 'Importando...';

  @override
  String get confirmImport => 'Confirmar importación';

  @override
  String get manageSavedCategoryRules =>
      'Gestionar reglas de categorías guardadas';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'La moneda de este archivo ($currency) no coincide con la moneda de la cuenta seleccionada.';
  }

  @override
  String get categoryRulesTitle => 'Reglas de categorías';

  @override
  String get possibleDuplicate => 'posible duplicado';

  @override
  String get unknownCategory => 'Categoría desconocida';
}
