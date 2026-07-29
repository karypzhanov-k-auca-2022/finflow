// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FinFlow';

  @override
  String get home => 'Главная';

  @override
  String get transactions => 'Операции';

  @override
  String get budgets => 'Бюджеты';

  @override
  String get analytics => 'Аналитика';

  @override
  String get settings => 'Настройки';

  @override
  String get pageNotFound => 'Страница не найдена';

  @override
  String routeDoesNotExist(String route) {
    return 'Маршрут $route не существует';
  }

  @override
  String get transactionNotFound => 'Операция не найдена';

  @override
  String get backToTransactions => 'Вернуться к операциям';

  @override
  String get loadingData => 'Загрузка данных…';

  @override
  String get failedToLoadData => 'Не удалось загрузить данные';

  @override
  String get pleaseTryAgain => 'Попробуйте ещё раз';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get saving => 'Сохранение…';

  @override
  String get edit => 'Изменить';

  @override
  String get add => 'Добавить';

  @override
  String get undo => 'Отменить';

  @override
  String get apply => 'Применить';

  @override
  String get refresh => 'Обновить';

  @override
  String get offlineTitle => 'Нет подключения к интернету';

  @override
  String get offlineMessage =>
      'Интернет недоступен. Сохранённые финансовые данные останутся доступны на этом устройстве.';

  @override
  String get continueOffline => 'Продолжить без сети';

  @override
  String get checkAgain => 'Проверить снова';

  @override
  String get offlineMode => 'Автономный режим';

  @override
  String get transactionsTitle => 'Операции';

  @override
  String get filters => 'Фильтры';

  @override
  String get addTransaction => 'Добавить операцию';

  @override
  String get searchTransactions => 'Поиск по названию или заметке';

  @override
  String get noTransactions => 'Операций пока нет';

  @override
  String get noTransactionsMessage =>
      'Добавьте первую операцию, чтобы начать учёт.';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get nothingFoundMessage => 'Измените запрос или фильтры.';

  @override
  String get filtersAndSorting => 'Фильтры и сортировка';

  @override
  String get all => 'Все';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get expenses => 'Расходы';

  @override
  String get category => 'Категория';

  @override
  String get allCategories => 'Все категории';

  @override
  String get period => 'Период';

  @override
  String get allTime => 'Всё время';

  @override
  String get currentMonth => 'Текущий месяц';

  @override
  String get threeMonths => '3 месяца';

  @override
  String get sixMonths => '6 месяцев';

  @override
  String get year => 'Год';

  @override
  String get month => 'Месяц';

  @override
  String get selectRange => 'Выбрать период';

  @override
  String get selectDateRange => 'Выберите диапазон дат';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get date => 'Дата';

  @override
  String get amount => 'Сумма';

  @override
  String get direction => 'Направление';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get deleteTransactionQuestion => 'Удалить операцию?';

  @override
  String transactionCannotBeRestored(String title) {
    return 'Операцию «$title» нельзя будет восстановить.';
  }

  @override
  String transactionDeleted(String title) {
    return 'Удалено: «$title»';
  }

  @override
  String get failedToSave => 'Не удалось сохранить';

  @override
  String get transactionSaved => 'Операция сохранена';

  @override
  String get exitWithoutSaving => 'Выйти без сохранения?';

  @override
  String get changesWillBeLost => 'Изменения будут потеряны.';

  @override
  String get stay => 'Остаться';

  @override
  String get exit => 'Выйти';

  @override
  String get newTransaction => 'Новая операция';

  @override
  String get title => 'Название';

  @override
  String get enterTitle => 'Введите название';

  @override
  String get enterPositiveAmount => 'Введите положительную сумму';

  @override
  String get createCategory => 'Создать категорию';

  @override
  String get noteOptional => 'Заметка (необязательно)';

  @override
  String get dashboardNoTransactions => 'Операций пока нет';

  @override
  String get dashboardNoTransactionsMessage =>
      'Добавьте первую операцию — здесь появится обзор.';

  @override
  String get currentBalance => 'Текущий баланс';

  @override
  String get budgetForPeriod => 'Бюджет за период';

  @override
  String spentOfLimit(String spent, String limit) {
    return '$spent из $limit';
  }

  @override
  String get expensesByCategory => 'Расходы по категориям';

  @override
  String get noExpenses => 'Расходов нет';

  @override
  String get noExpensesForPeriod => 'За выбранный период расходов пока нет.';

  @override
  String get recentTransactions => 'Последние операции';

  @override
  String get averageExpenses => 'Средние расходы';

  @override
  String get monthlyExpenses => 'Расходы по месяцам';

  @override
  String get topCategory => 'Главная категория';

  @override
  String get notEnoughData => 'Недостаточно данных';

  @override
  String get addExpensesForAnalytics =>
      'Добавьте расходы, чтобы увидеть аналитику.';

  @override
  String get byCategory => 'По категориям';

  @override
  String get account => 'Аккаунт';

  @override
  String get notLoggedIn => 'Вход не выполнен';

  @override
  String get guestAccount => 'Гостевой аккаунт';

  @override
  String get cloudSyncActive => 'Облачная синхронизация активна';

  @override
  String get signOut => 'Выйти';

  @override
  String get signIn => 'Войти';

  @override
  String get theme => 'Тема';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get manageCategories => 'Управление категориями';

  @override
  String get manageCategoriesSubtitle => 'Просмотр и создание категорий';

  @override
  String get data => 'Данные';

  @override
  String get exportTransactionsCsv => 'Экспорт операций в CSV';

  @override
  String get exportTransactionsCsvSubtitle =>
      'Сохранить или скопировать финансовые записи';

  @override
  String get clearData => 'Очистить данные';

  @override
  String get clear => 'Очистить';

  @override
  String get restore => 'Восстановить';

  @override
  String get dataCleared => 'Данные удалены';

  @override
  String get demoDataRestored => 'Демоданные восстановлены';

  @override
  String get clearDataSubtitle => 'Удалить операции и бюджеты';

  @override
  String get clearAllDataQuestion => 'Удалить все данные?';

  @override
  String get clearAllDataMessage =>
      'Операции, бюджеты и пользовательские категории будут удалены с устройства.';

  @override
  String get restoreDemoData => 'Восстановить демоданные';

  @override
  String get restoreDemoDataSubtitle =>
      'Заменить текущие данные демонстрационным набором';

  @override
  String get restoreDemoDataQuestion => 'Восстановить демоданные?';

  @override
  String get restoreDemoDataMessage =>
      'Текущие операции и бюджеты будут заменены.';

  @override
  String get about => 'О приложении';

  @override
  String get exportCsv => 'Экспорт CSV';

  @override
  String csvGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сформировано $count операции в формате CSV:',
      many: 'Сформировано $count операций в формате CSV:',
      few: 'Сформировано $count операции в формате CSV:',
      one: 'Сформирована 1 операция в формате CSV:',
      zero: 'Операций для экспорта нет',
    );
    return '$_temp0';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get copy => 'Копировать';

  @override
  String get csvCopied => 'CSV скопирован в буфер обмена!';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get categorySalary => 'Зарплата';

  @override
  String get categoryGroceries => 'Продукты';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryRent => 'Аренда';

  @override
  String get categoryCafe => 'Кафе';

  @override
  String get categorySubscriptions => 'Подписки';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryTransfers => 'Переводы';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get failedToLoadCategories => 'Не удалось загрузить категории';

  @override
  String get noCategories => 'Категорий пока нет';

  @override
  String get noCategoriesMessage =>
      'Создайте первую категорию для учёта финансов.';

  @override
  String get editCategory => 'Изменить категорию';

  @override
  String get categoryName => 'Название категории';

  @override
  String get enterCategoryName => 'Введите название категории';

  @override
  String get color => 'Цвет';

  @override
  String get icon => 'Значок';

  @override
  String get deleteCategoryQuestion => 'Удалить категорию?';

  @override
  String categoryWillBeDeleted(String name) {
    return 'Категория «$name» будет удалена.';
  }

  @override
  String get newBudget => 'Новый бюджет';

  @override
  String get editBudget => 'Изменить бюджет';

  @override
  String get editLimit => 'Изменить лимит';

  @override
  String get categoryTransactions => 'Операции категории';

  @override
  String get failedToLoadTransactions => 'Не удалось загрузить операции';

  @override
  String get noCategoryExpensesThisMonth =>
      'В этом месяце для категории нет расходных операций.';

  @override
  String get noBudgets => 'Бюджеты не заданы';

  @override
  String get noBudgetsMessage =>
      'Установите лимит для категории и следите за расходами.';

  @override
  String get createBudget => 'Создать бюджет';

  @override
  String get monthlyLimit => 'Месячный лимит';

  @override
  String get enterPositiveLimit => 'Введите положительный лимит';

  @override
  String get deleteBudget => 'Удалить бюджет';

  @override
  String get deleteBudgetQuestion => 'Удалить бюджет?';

  @override
  String budgetWillBeRemoved(String name) {
    return 'Лимит для категории «$name» будет удалён.';
  }

  @override
  String budgetDeleted(String name) {
    return 'Бюджет для «$name» удалён';
  }

  @override
  String get limitWillBeRemoved => 'Лимит для этой категории будет удалён.';

  @override
  String limitExceededBy(String amount) {
    return 'Лимит превышен на $amount';
  }

  @override
  String get budgetOverEightyPercent => 'Использовано больше 80% бюджета';

  @override
  String remainingAmount(String amount) {
    return 'Осталось $amount';
  }

  @override
  String get personalFinanceTracker => 'Трекер личных финансов • версия 1.0.0';

  @override
  String get aboutDescription =>
      'Трекер личных финансов с offline-first хранилищем, Clean Architecture, BLoC, GoRouter, Dio и автоматическими тестами.';

  @override
  String get login => 'Вход';

  @override
  String get registration => 'Регистрация';

  @override
  String get createAccountTitle => 'Создать аккаунт FinFlow';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get registerSubtitle =>
      'Зарегистрируйтесь для синхронизации бюджета между устройствами';

  @override
  String get loginSubtitle => 'Войдите, чтобы получить доступ к своим финансам';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email адрес';

  @override
  String get password => 'Пароль';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get invalidEmail => 'Введите корректный email';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать минимум 6 символов';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get loading => 'Загрузка…';

  @override
  String get registerAction => 'Зарегистрироваться';

  @override
  String get signInAction => 'Войти в аккаунт';

  @override
  String get or => 'ИЛИ';

  @override
  String get continueAsGuest => 'Продолжить как гость';

  @override
  String get continueAsGuestOffline => 'Продолжить как гость (офлайн-режим)';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get storageInitializationFailed =>
      'Не удалось подготовить локальное хранилище';
}
